import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hafalyuk_dsn/models/setoran_model.dart';
import 'package:hafalyuk_dsn/services/auth_service.dart';
import 'package:hafalyuk_dsn/services/pa_service.dart';
import 'package:dio/dio.dart';
import 'package:hafalyuk_dsn/pages/login_page.dart';
import 'package:hafalyuk_dsn/widgets/info_item_widget.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

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
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentPage = 0;
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Sudah Setor', 'Belum Setor'];

  // State variables for multi-select
  bool _isMultiSelectMode = false;
  String? _multiSelectType; // 'validate' or 'cancel'
  Set<int> _selectedIndices = {};

  String formatPercentage(double? value) {
    if (value == null) return '0%';
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    } else {
      return '${value.toStringAsFixed(1)}%';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      const List<String> monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showDetailBottomSheet(Detail detail) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      detail.sudahSetor == true
                          ? Icons.check_circle
                          : Icons.pending,
                      color:
                          detail.sudahSetor == true ? Colors.green : Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        detail.nama ?? '-',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4A4A4A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  detail.sudahSetor == true
                      ? 'Sudah menyetor surah ${detail.nama ?? '-'} pada tanggal ${_formatDate(detail.infoSetoran?.tglSetoran)} dan divalidasi oleh ${detail.infoSetoran?.dosenYangMengesahkan?.nama ?? '-'}.'
                      : 'Belum menyetor surah ${detail.nama ?? '-'}.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
    );
  }

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

  void _showToggleConfirmationDialog(
    Detail detail,
    int index,
    bool isValidate,
  ) {
    final String title =
        isValidate ? 'Konfirmasi Validasi' : 'Konfirmasi Pembatalan';
    final String content =
        isValidate
            ? 'Apakah Anda yakin ingin memvalidasi setoran ${detail.nama ?? '-'}?'
            : 'Apakah Anda yakin ingin membatalkan setoran ${detail.nama ?? '-'}?';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFFFFFF),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A4A4A),
            ),
          ),
          content: Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF888888),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF888888),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                await _performToggleSetoranStatus(detail, index);
              },
              child: Text(
                'Ya',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF4A4A4A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
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
          // Only allow selection based on multi-select type
          if (_multiSelectType == 'validate' && detail.sudahSetor != true ||
              _multiSelectType == 'cancel' && detail.sudahSetor == true) {
            _selectedIndices.add(index);
          }
        }
      });
      return;
    }

    // Show confirmation dialog for single item action
    _showToggleConfirmationDialog(detail, index, detail.sudahSetor != true);
  }

  void _showSaveConfirmationDialog() {
    final String title =
        _multiSelectType == 'validate'
            ? 'Konfirmasi Validasi'
            : 'Konfirmasi Pembatalan';
    final String content =
        _multiSelectType == 'validate'
            ? 'Apakah Anda yakin ingin memvalidasi setoran tersebut?'
            : 'Apakah Anda yakin ingin membatalkan setoran tersebut?';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFFFFFF),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A4A4A),
            ),
          ),
          content: Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF888888),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF888888),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                await _performSaveMultiSelectChanges();
              },
              child: Text(
                'Ya',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF4A4A4A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
    _showSaveConfirmationDialog();
  }

  void _showStudentInfoBottomSheet() {
    final info = _setoranResponse?.data?.info;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                InfoItem(
                  icon: Icons.person,
                  label: 'Nama',
                  value: info?.nama ?? '-',
                ),
                InfoItem(
                  icon: Icons.badge,
                  label: 'NIM',
                  value: info?.nim ?? '-',
                ),
                InfoItem(
                  icon: Icons.calendar_today,
                  label: 'Semester',
                  value: '${info?.semester ?? '-'}',
                ),
              ],
            ),
          ),
    );
  }

  void _showProgressBottomSheet(int ringkasanIndex, String title) {
    final setoran = _setoranResponse?.data?.setoran;
    if (setoran == null ||
        setoran.ringkasan == null ||
        ringkasanIndex >= setoran.ringkasan!.length) {
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 16),
                LinearPercentIndicator(
                  animation: true,
                  animationDuration: 1200,
                  lineHeight: 20.0,
                  percent:
                      (setoran.ringkasan![ringkasanIndex].persentaseProgresSetor
                              ?.toDouble() ??
                          0.0) /
                      100,
                  center: Text(
                    formatPercentage(
                      setoran.ringkasan![ringkasanIndex].persentaseProgresSetor,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  progressColor: const Color(0xFFC2E9D7),
                  backgroundColor: const Color(0xFFD9D9D9),
                  barRadius: const Radius.circular(10),
                ),
                const SizedBox(height: 16),
                InfoItem(
                  icon: Icons.check_circle,
                  label: 'Total Sudah Setor',
                  value:
                      '${setoran.ringkasan![ringkasanIndex].totalSudahSetor ?? 0.0}',
                ),
                InfoItem(
                  icon: Icons.pending,
                  label: 'Total Belum Setor',
                  value:
                      '${setoran.ringkasan![ringkasanIndex].totalBelumSetor ?? 0.0}',
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildProgressCard(int ringkasanIndex, String title) {
    final setoran = _setoranResponse?.data?.setoran;
    if (setoran == null ||
        setoran.ringkasan == null ||
        ringkasanIndex >= setoran.ringkasan!.length) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Card(
        color: const Color(0xFFFFFFFF),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showProgressBottomSheet(ringkasanIndex, title),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 8.0,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4A4A4A),
                        ),
                      ),
                      const Icon(Icons.info),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  animation: true,
                  animationDuration: 1200,
                  lineHeight: 20.0,
                  percent:
                      (setoran.ringkasan![ringkasanIndex].persentaseProgresSetor
                              ?.toDouble() ??
                          0.0) /
                      100,
                  center: Text(
                    formatPercentage(
                      setoran.ringkasan![ringkasanIndex].persentaseProgresSetor,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  progressColor: const Color(0xFFC2E9D7),
                  backgroundColor: const Color(0xFFD9D9D9),
                  barRadius: const Radius.circular(10),
                ),
              ],
            ),
          ),
        ),
      ),
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
            _showStudentInfoBottomSheet();
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
            itemBuilder:
                (BuildContext context) => [
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
      floatingActionButton:
          _isMultiSelectMode
              ? FloatingActionButton(
                onPressed: _saveMultiSelectChanges,
                backgroundColor:
                    _multiSelectType == 'validate' ? Colors.green : Colors.red,
                child: const Icon(Icons.save, color: Colors.white),
              )
              : null,
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          color: Color(0xFFFFF8E7),
        ),
        height: double.infinity,
        child:
            _isLoading
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
    final List<Widget> carouselItems =
        [
          _buildProgressCard(0, 'KP'),
          _buildProgressCard(1, 'SEMINAR KP'),
          _buildProgressCard(2, 'DAFTAR TA'),
          _buildProgressCard(3, 'SEMPRO'),
          _buildProgressCard(4, 'SIDANG TA'),
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
              children:
                  carouselItems.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _carouselController.animateToPage(entry.key),
                      child: Container(
                        width: _currentPage == entry.key ? 8.0 : 6.0,
                        height: _currentPage == entry.key ? 8.0 : 6.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPage == entry.key
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
                children:
                    _filters.map((filter) {
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
                              color:
                                  isSelected
                                      ? Color(0xFF4A4A4A)
                                      : Color(0xFF888888),
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
                children:
                    _getFilteredDetails().asMap().entries.map((entry) {
                      final index = entry.key;
                      final detail = entry.value;
                      final isDisabled =
                          _isMultiSelectMode &&
                          ((_multiSelectType == 'validate' &&
                                  detail.sudahSetor == true) ||
                              (_multiSelectType == 'cancel' &&
                                  detail.sudahSetor != true));
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
                                color:
                                    detail.sudahSetor != false
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
                                  detail.sudahSetor != false
                                      ? 'Sudah'
                                      : 'Belum',
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
                                  color: const Color(
                                    0xFF000000,
                                  ).withOpacity(0.5),
                                ),
                                onPressed: () => _showDetailBottomSheet(detail),
                              ),
                              _isMultiSelectMode
                                  ? Checkbox(
                                    value: _selectedIndices.contains(index),
                                    onChanged:
                                        isDisabled
                                            ? null
                                            : (value) => _toggleSetoranStatus(
                                              detail,
                                              index,
                                            ),
                                    activeColor: const Color(0xFF4A4A4A),
                                  )
                                  : IconButton(
                                    icon: Icon(
                                      detail.sudahSetor != false
                                          ? Icons.delete
                                          : Icons.check,
                                      color:
                                          detail.sudahSetor != false
                                              ? Colors.red
                                              : Colors.green,
                                    ),
                                    onPressed:
                                        () =>
                                            _toggleSetoranStatus(detail, index),
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
