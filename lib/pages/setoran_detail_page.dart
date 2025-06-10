import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hafalyuk_dsn/models/setoran_model.dart';
import 'package:hafalyuk_dsn/services/auth_service.dart';
import 'package:hafalyuk_dsn/services/pa_service.dart';
import 'package:dio/dio.dart';
import 'package:hafalyuk_dsn/pages/login_page.dart';
import 'package:hafalyuk_dsn/widgets/detail_bottom_sheet.dart';
import 'package:hafalyuk_dsn/widgets/toggle_confirmation_dialog.dart';
import 'package:hafalyuk_dsn/widgets/student_info_bottom_sheet.dart';
import 'package:hafalyuk_dsn/widgets/progress_bottom_sheet.dart';
import 'package:hafalyuk_dsn/widgets/progress_card.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentPage = 0;
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Sudah Setor', 'Belum Setor'];

  bool _isMultiSelectMode = false;
  String? _multiSelectType;
  Set<int> _selectedIndices = {};

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
      _isMultiSelectMode = false;
      _selectedIndices.clear();
      _multiSelectType = null;
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

  Future<void> _performToggleSetoranStatus(Detail detail, int index) async {
    await _checkTokenAndNavigate();
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (detail.sudahSetor == true) {
        await _paService.markAsBelumSetor(
          widget.nim,
          detail.infoSetoran?.id ?? '',
          detail.id ?? '',
          detail.nama ?? '',
        );
      } else {
        await _paService.markAsSudahSetor(
          widget.nim,
          detail.id ?? '',
          detail.nama ?? '',
        );
      }
      await _fetchSetoranData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Perubahan berhasil disimpan!',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _toggleSetoranStatus(Detail detail, int index) async {
    if (_isMultiSelectMode) {
      setState(() {
        if (_selectedIndices.contains(index)) {
          _selectedIndices.remove(index);
        } else {
          if (_multiSelectType == 'validate' && detail.sudahSetor != true ||
              _multiSelectType == 'cancel' && detail.sudahSetor == true) {
            _selectedIndices.add(index);
          }
        }
      });
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ToggleConfirmationDialog(
          detail: detail,
          isValidate: detail.sudahSetor != true,
          onConfirm: () => _performToggleSetoranStatus(detail, index),
        );
      },
    );
  }

  Future<void> _performSaveMultiSelectChanges() async {
    await _checkTokenAndNavigate();
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final details = _getFilteredDetails();
      for (int index in _selectedIndices) {
        final detail = details[index];
        if (_multiSelectType == 'validate' && detail.sudahSetor != true) {
          await _paService.markAsSudahSetor(
            widget.nim,
            detail.id ?? '',
            detail.nama ?? '',
          );
        } else if (_multiSelectType == 'cancel' && detail.sudahSetor == true) {
          await _paService.markAsBelumSetor(
            widget.nim,
            detail.infoSetoran?.id ?? '',
            detail.id ?? '',
            detail.nama ?? '',
          );
        }
      }
      await _fetchSetoranData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Perubahan berhasil disimpan!',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveMultiSelectChanges() async {
    if (_selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih setidaknya satu item untuk disimpan.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ToggleConfirmationDialog(
          detail: Detail(nama: 'terpilih'),
          isValidate: _multiSelectType == 'validate',
          onConfirm: _performSaveMultiSelectChanges,
        );
      },
    );
  }

  List<Detail> _getFilteredDetails() {
    final details = _setoranResponse?.data?.setoran?.detail ?? [];
    if (_selectedFilter == 'Semua') {
      return details;
    } else if (_selectedFilter == 'Sudah Setor') {
      return details.where((detail) => detail.sudahSetor == true).toList();
    } else {
      return details.where((detail) => detail.sudahSetor != true).toList();
    }
  }

  void _enterMultiSelectMode(String? type) {
    setState(() {
      _isMultiSelectMode = type != null;
      _multiSelectType = type;
      _selectedIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentName = _setoranResponse?.data?.info?.nama ?? '';
    final firstTwoWords = studentName.split(' ').take(2).join(' ');

    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          child: Text(
            firstTwoWords,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              builder: (context) => StudentInfoBottomSheet(info: _setoranResponse?.data?.info),
            );
          },
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (_multiSelectType == value) {
                  _enterMultiSelectMode(null);
                } else {
                  _enterMultiSelectMode(value);
                }
              });
            },
            color: Colors.white,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'validate',
                child: Row(
                  children: [
                    Checkbox(
                      value: _multiSelectType == 'validate',
                      onChanged: (_) {},
                      activeColor: const Color(0xFF4A4A4A),
                    ),
                    const Text('Pilih Banyak Validasi'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Checkbox(
                      value: _multiSelectType == 'cancel',
                      onChanged: (_) {},
                      activeColor: const Color(0xFF4A4A4A),
                    ),
                    const Text('Pilih Banyak Batalkan'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _isMultiSelectMode
          ? FloatingActionButton(
              onPressed: _saveMultiSelectChanges,
              backgroundColor: _multiSelectType == 'validate' ? Colors.green : Colors.red,
              child: const Icon(Icons.save, color: Colors.white),
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          color: Color(0xFFFFF8E7),
        ),
        height: double.infinity,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFC2E9D7)),
              )
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _buildSetoranContent(),
      ),
    );
  }

  Widget _buildSetoranContent() {
    final data = _setoranResponse?.data;
    final setoran = data?.setoran;
    final List<Widget> carouselItems = [
      if (setoran?.ringkasan != null && setoran!.ringkasan!.isNotEmpty)
        ProgressCard(
          ringkasan: setoran.ringkasan![0],
          title: 'KERJA PRAKTEK',
          onTap: () => showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) => ProgressBottomSheet(
              ringkasan: setoran.ringkasan![0],
              title: 'KERJA PRAKTEK',
            ),
          ),
        ),
      if (setoran?.ringkasan != null && setoran!.ringkasan!.length > 1)
        ProgressCard(
          ringkasan: setoran.ringkasan![1],
          title: 'SEMINAR KP',
          onTap: () => showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) => ProgressBottomSheet(
              ringkasan: setoran.ringkasan![1],
              title: 'SEMINAR KP',
            ),
          ),
        ),
      if (setoran?.ringkasan != null && setoran!.ringkasan!.length > 2)
        ProgressCard(
          ringkasan: setoran.ringkasan![2],
          title: 'DAFTAR TA',
          onTap: () => showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) => ProgressBottomSheet(
              ringkasan: setoran.ringkasan![2],
              title: 'DAFTAR TA',
            ),
          ),
        ),
      if (setoran?.ringkasan != null && setoran!.ringkasan!.length > 3)
        ProgressCard(
          ringkasan: setoran.ringkasan![3],
          title: 'SEMPRO',
          onTap: () => showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) => ProgressBottomSheet(
              ringkasan: setoran.ringkasan![3],
              title: 'SEMPRO',
            ),
          ),
        ),
      if (setoran?.ringkasan != null && setoran!.ringkasan!.length > 4)
        ProgressCard(
          ringkasan: setoran.ringkasan![4],
          title: 'SIDANG TA',
          onTap: () => showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) => ProgressBottomSheet(
              ringkasan: setoran.ringkasan![4],
              title: 'SIDANG TA',
            ),
          ),
        ),
    ].where((card) => card is! SizedBox).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Column(
          children: [
            SizedBox(
              height: 120,
              child: CarouselSlider(
                carouselController: _carouselController,
                options: CarouselOptions(
                  height: 100,
                  scrollDirection: Axis.horizontal,
                  enableInfiniteScroll: false,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                ),
                items: carouselItems,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: carouselItems.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _carouselController.animateToPage(entry.key),
                  child: Container(
                    width: _currentPage == entry.key ? 8.0 : 6.0,
                    height: _currentPage == entry.key ? 8.0 : 6.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == entry.key
                          ? const Color(0xFF4A4A4A)
                          : Colors.grey.withOpacity(0.4),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        filter,
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
                          color: isSelected ? Color(0xFF4A4A4A) : Color(0xFF888888),
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (setoran?.detail != null)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF4A4A4A), width: 1),
              ),
              child: ListView(
                children: _getFilteredDetails().asMap().entries.map((entry) {
                  final index = entry.key;
                  final detail = entry.value;
                  final isDisabled = _isMultiSelectMode &&
                      ((_multiSelectType == 'validate' && detail.sudahSetor == true) ||
                          (_multiSelectType == 'cancel' && detail.sudahSetor != true));
                  return Card(
                    color: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        detail.nama ?? '-',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: detail.sudahSetor != false
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: Text(
                              detail.sudahSetor != false ? 'Sudah' : 'Belum',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.description,
                              color: const Color(0xFF000000).withOpacity(0.5),
                            ),
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                              ),
                              builder: (context) => DetailBottomSheet(detail: detail),
                            ),
                          ),
                          _isMultiSelectMode
                              ? Checkbox(
                                  value: _selectedIndices.contains(index),
                                  onChanged: isDisabled
                                      ? null
                                      : (value) => _toggleSetoranStatus(detail, index),
                                  activeColor: const Color(0xFF4A4A4A),
                                )
                              : IconButton(
                                  icon: Icon(
                                    detail.sudahSetor != false ? Icons.delete : Icons.check,
                                    color: detail.sudahSetor != false ? Colors.red : Colors.green,
                                  ),
                                  onPressed: () => _toggleSetoranStatus(detail, index),
                                ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}