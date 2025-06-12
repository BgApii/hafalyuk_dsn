import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hafalyuk_dsn/models/pa_model.dart';
import 'package:hafalyuk_dsn/pages/dosen_profile_page.dart';
import 'package:hafalyuk_dsn/pages/login_page.dart';
import 'package:hafalyuk_dsn/services/auth_service.dart';
import 'package:hafalyuk_dsn/services/pa_service.dart';
import 'package:hafalyuk_dsn/pages/mahasiswa_page.dart';
import 'package:dio/dio.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hafalyuk_dsn/widgets/logout_alert.dart';

class PaPage extends StatefulWidget {
  const PaPage({super.key});

  @override
  _PaPageState createState() => _PaPageState();
}

class _PaPageState extends State<PaPage> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late final PaService _paService;
  PaRespons? _paResponse;
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _paService = PaService(Dio(), _authService);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchPaData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

      if (_errorMessage!.contains('Session expired')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesi Anda telah berakhir. Silakan login kembali.'),
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF8E7),
      child: SafeArea(
        top: false,
        child: ClipRect(
          child: Scaffold(
            bottomNavigationBar: CurvedNavigationBar(
              height: 60,
              index: _tabController.index,
              onTap: (index) {
                _tabController.animateTo(index);
              },
              backgroundColor: const Color(0xFFFFF8E7),
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 300),
              items: const [
                Icon(Icons.list, color: Colors.black),
                Icon(Icons.person, color: Colors.black),
              ],
            ),
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF4A4A4A),
                  child: Text(
                    _paResponse?.data?.nama?.isNotEmpty == true
                        ? _paResponse!.data!.nama!
                            .trim()
                            .split(' ')
                            .map((e) => e[0])
                            .take(2)
                            .join()
                            .toUpperCase()
                        : 'U',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              centerTitle: true,
              title: Text(
                _tabController.index == 0 ? 'Mahasiswa PA' : 'Profile',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => showLogoutDialog(context, _authService),
                  ),
                ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                color: Color(0xFFFFF8E7),
              ),
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFC2E9D7),
                        ),
                      )
                      : _errorMessage != null &&
                          _errorMessage!.toLowerCase().contains(
                            'connection error',
                          )
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tidak ada koneksi internet, harap periksa koneksi internet anda',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Color(0xFF4A4A4A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Color(0xFF4A4A4A),
                                size: 30,
                              ),
                              onPressed: _fetchPaData,
                            ),
                          ],
                        ),
                      )
                      : _errorMessage != null &&
                          _errorMessage!.contains('Session expired')
                      ? const Center(
                        child: Text('Mengalihkan ke halaman login...'),
                      )
                      : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          MahasiswaPage(
                            daftarMahasiswa:
                                _paResponse
                                    ?.data
                                    ?.infoMahasiswaPa
                                    ?.daftarMahasiswa ??
                                [],
                          ),
                          DosenProfilePage(data: _paResponse?.data),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
