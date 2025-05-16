import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hafalyuk_dsn/models/setoran_model.dart';
import 'package:hafalyuk_dsn/services/auth_service.dart';
import 'package:hafalyuk_dsn/services/pa_service.dart';
import 'package:dio/dio.dart';
import 'package:hafalyuk_dsn/pages/login_page.dart';

class SetoranDetailPage extends StatefulWidget {
  final String nim;

  const SetoranDetailPage({super.key, required this.nim});

  @override
  _SetoranDetailPageState createState() => _SetoranDetailPageState();
}

class _SetoranDetailPageState extends State<SetoranDetailPage> {
  final AuthService _authService = AuthService();
  late final PaService _paService;
  SetoranRespons? _setoranResponse;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _paService = PaService(Dio(), _authService);
    _fetchSetoranData();
  }

  Future<void> _checkTokenAndNavigate() async {
    final token = await _authService.getToken();
    if (token == null) {
      await _authService.logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi Anda telah berakhir. Silakan login kembali.'),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
      return;
    }
  }

  Future<void> _fetchSetoranData() async {
    await _checkTokenAndNavigate();
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _paService.getSetoranData(widget.nim);
      if (mounted) {
        setState(() {
          _setoranResponse = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleSetoranStatus(Detail detail, int index) async {
    await _checkTokenAndNavigate();
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (detail.sudahSetor == true) {
        // Mark as Belum Setor (DELETE)
        await _paService.markAsBelumSetor(
          widget.nim,
          detail.infoSetoran?.id ?? '',
          detail.id ?? '',
          detail.nama ?? '',
        );
      } else {
        // Mark as Sudah Setor (POST)
        await _paService.markAsSudahSetor(
          widget.nim,
          detail.id ?? '',
          detail.nama ?? '',
        );
      }
      // Refresh data after update
      await _fetchSetoranData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Setoran',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildSetoranContent(),
    );
  }

  Widget _buildSetoranContent() {
    final data = _setoranResponse?.data;
    final info = data?.info;
    final setoran = data?.setoran;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Mahasiswa',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Nama: ${info?.nama ?? '-'}'),
                  Text('NIM: ${info?.nim ?? '-'}'),
                  Text('Email: ${info?.email ?? '-'}'),
                  Text('Angkatan: ${info?.angkatan ?? '-'}'),
                  Text('Semester: ${info?.semester ?? '-'}'),
                  if (info?.dosenPa != null)
                    Text('Dosen PA: ${info?.dosenPa?.nama ?? '-'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (setoran?.infoDasar != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progres Setoran',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Total Wajib: ${setoran?.infoDasar?.totalWajibSetor}'),
                    Text('Sudah Setor: ${setoran?.infoDasar?.totalSudahSetor}'),
                    Text('Belum Setor: ${setoran?.infoDasar?.totalBelumSetor}'),
                    Text(
                        'Progres: ${setoran?.infoDasar?.persentaseProgresSetor}%'),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (setoran?.ringkasan != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan Setoran',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...setoran!.ringkasan!.map((ringkasan) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(ringkasan.label ?? '-'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Wajib: ${ringkasan.totalWajibSetor}'),
                            Text('Sudah: ${ringkasan.totalSudahSetor}'),
                            Text('Belum: ${ringkasan.totalBelumSetor}'),
                            Text('Progres: ${ringkasan.persentaseProgresSetor}%'),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          const SizedBox(height: 16),
          if (setoran?.detail != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Setoran',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...setoran!.detail!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final detail = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(detail.nama ?? '-'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nama Arab: ${detail.namaArab ?? '-'}'),
                          Text(
                              'Status: ${detail.sudahSetor != false ? 'Sudah Setor' : 'Belum Setor'}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            detail.sudahSetor != false
                                ? Icons.check_circle
                                : Icons.pending,
                            color: detail.sudahSetor != false ? Colors.green : Colors.grey,
                          ),
                          IconButton(
                            icon: Icon(
                              detail.sudahSetor != false
                                  ? Icons.delete
                                  : Icons.check,
                              color: detail.sudahSetor != false ? Colors.red : Colors.green,
                            ),
                            onPressed: () => _toggleSetoranStatus(detail, index),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }
}