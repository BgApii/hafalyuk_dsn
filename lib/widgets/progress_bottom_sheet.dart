import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hafalyuk_dsn/models/setoran_model.dart';
import 'package:hafalyuk_dsn/widgets/info_item_widget.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgressBottomSheet extends StatelessWidget {
  final Ringkasan ringkasan;
  final String title;

  const ProgressBottomSheet({
    super.key,
    required this.ringkasan,
    required this.title,
  });

  String formatPercentage(double? value) {
    if (value == null) return '0%';
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    } else {
      return '${value.toStringAsFixed(1)}%';
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
              percent: (ringkasan.persentaseProgresSetor?.toDouble() ?? 0.0) / 100,
              center: Text(
                formatPercentage(ringkasan.persentaseProgresSetor),
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
              value: '${ringkasan.totalSudahSetor ?? 0.0}',
            ),
            InfoItem(
              icon: Icons.pending,
              label: 'Total Belum Setor',
              value: '${ringkasan.totalBelumSetor ?? 0.0}',
            ),
          ],
        ),
      ),
    );
  }
}