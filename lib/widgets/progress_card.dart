import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hafalyuk_dsn/models/setoran_model.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgressCard extends StatelessWidget {
  final Ringkasan ringkasan;
  final String title;
  final VoidCallback onTap;

  const ProgressCard({
    super.key,
    required this.ringkasan,
    required this.title,
    required this.onTap,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Card(
        color: const Color(0xFFFFFFFF),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}