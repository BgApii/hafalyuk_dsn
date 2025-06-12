import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hafalyuk_dsn/models/setoran_model.dart';

class DetailBottomSheet extends StatelessWidget {
  final Detail detail;

  const DetailBottomSheet({super.key, required this.detail});

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
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
                  color: detail.sudahSetor == true ? Colors.green : Colors.red,
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
}
