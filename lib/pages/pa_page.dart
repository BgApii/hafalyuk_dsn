// pages/pa_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hafalyuk_dsn/models/pa_model.dart';
import 'package:hafalyuk_dsn/services/auth_service.dart';
import 'package:hafalyuk_dsn/services/pa_service.dart';
import 'package:hafalyuk_dsn/pages/login_page.dart';
import 'package:hafalyuk_dsn/pages/setoran_detail_page.dart';
import 'package:dio/dio.dart';

class PaPage extends StatefulWidget {
  const PaPage({super.key});

  @override
  _PaPageState createState() => _PaPageState();
}

class _PaPageState extends State<PaPage> {
  final AuthService _authService = AuthService();
  late final PaService _paService;
  PaRespons? _paResponse;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _paService = PaService(Dio(), _authService);
    _fetchPaData();
  }

  Future<void> _fetchPaData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _paService.getPaData();
      setState(() {
        _paResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PA Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildPaContent(),
    );
  }

  Widget _buildPaContent() {
    final data = _paResponse?.data;
    final infoMahasiswaPa = data?.infoMahasiswaPa;

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
                    'Dosen PA',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Nama: ${data?.nama ?? '-'}'),
                  Text('NIP: ${data?.nip ?? '-'}'),
                  Text('Email: ${data?.email ?? '-'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ringkasan Mahasiswa',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (infoMahasiswaPa?.ringkasan != null)
            ...infoMahasiswaPa!.ringkasan!.map((ringkasan) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('Tahun ${ringkasan.tahun}'),
                    subtitle: Text('Total Mahasiswa: ${ringkasan.total}'),
                  ),
                )),
          const SizedBox(height: 16),
          Text(
            'Daftar Mahasiswa',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (infoMahasiswaPa?.daftarMahasiswa != null)
            ...infoMahasiswaPa!.daftarMahasiswa!.map((mahasiswa) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(mahasiswa.nama ?? '-'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NIM: ${mahasiswa.nim ?? '-'}'),
                        Text('Angkatan: ${mahasiswa.angkatan ?? '-'}'),
                        Text('Semester: ${mahasiswa.semester ?? '-'}'),
                        if (mahasiswa.infoSetoran != null)
                          Text(
                              'Progres: ${mahasiswa.infoSetoran!.persentaseProgresSetor?.toStringAsFixed(1)}%'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SetoranDetailPage(nim: mahasiswa.nim!),
                        ),
                      );
                    },
                  ),
                )),
        ],
      ),
    );
  }
}