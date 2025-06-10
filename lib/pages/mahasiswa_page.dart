import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hafalyuk_dsn/models/pa_model.dart';
import 'package:hafalyuk_dsn/pages/setoran_detail_page.dart';

class MahasiswaPage extends StatefulWidget {
  final List<DaftarMahasiswa> daftarMahasiswa;

  const MahasiswaPage({super.key, required this.daftarMahasiswa});

  @override
  _MahasiswaPageState createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {
  String _selectedYear = 'Semua';
  final List<String> _years = [
    'Semua',
    '2019',
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
  ];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<DaftarMahasiswa> _getFilteredMahasiswa() {
    return widget.daftarMahasiswa.where((mahasiswa) {
      final matchesYear =
          _selectedYear == 'Semua' || mahasiswa.angkatan == _selectedYear;
      final matchesSearch =
          mahasiswa.nama?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
          false;
      return matchesYear && matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMahasiswa = _getFilteredMahasiswa();

    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
      },
      child: Scaffold(
        body: Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            color: Color(0xFFFFF8E7),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mahasiswa PA',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  style: GoogleFonts.poppins(color: Color(0xFF4A4A4A)),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Cari mahasiswa...',
                    hintStyle: GoogleFonts.poppins(color: Color(0xFF888888)),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _searchFocusNode.hasFocus
                                ? Color(0xFF98C1A9)
                                : Color(0xFF4A4A4A),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _searchFocusNode.hasFocus
                                ? Color(0xFF98C1A9)
                                : Color(0xFF4A4A4A),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF98C1A9),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _years.map((year) {
                            final isSelected = _selectedYear == year;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  year,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: Color(0xFFC2E9D7),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color:
                                        isSelected
                                            ? Color(0xFF4A4A4A)
                                            : Color(0xFF888888),
                                  ),
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedYear = year;
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4A4A4A),
                        width: 1,
                      ),
                    ),
                    child:
                        filteredMahasiswa.isEmpty
                            ? Center(
                              child: Text(
                                'Tidak ada mahasiswa "${_searchController.text}" di $_selectedYear',
                                style: GoogleFonts.poppins(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            )
                            : ListView(
                              shrinkWrap: true,
                              children:
                                  filteredMahasiswa.map((mahasiswa) {
                                    return Card(
                                      color: Colors.transparent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                  ) => SetoranDetailPage(
                                                    nim: mahasiswa.nim!,
                                                  ),
                                              transitionsBuilder: (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                                child,
                                              ) {
                                                const begin = Offset(
                                                  1.0,
                                                  0.0,
                                                );
                                                const end =
                                                    Offset
                                                        .zero;
                                                const curve = Curves.easeInOut;

                                                var tween = Tween(
                                                  begin: begin,
                                                  end: end,
                                                ).chain(
                                                  CurveTween(curve: curve),
                                                );
                                                var offsetAnimation = animation
                                                    .drive(tween);

                                                return SlideTransition(
                                                  position: offsetAnimation,
                                                  child: child,
                                                );
                                              },
                                              transitionDuration:
                                                  const Duration(
                                                    milliseconds: 300,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: ListTile(
                                          trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                          ),
                                          title: Text(
                                            mahasiswa.nama ?? '-',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'NIM: ${mahasiswa.nim ?? '-'}',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
