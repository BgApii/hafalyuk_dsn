import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hafalyuk_dsn/models/setoran_model.dart';

class ToggleConfirmationDialog extends StatelessWidget {
  final Detail detail;
  final bool isValidate;
  final VoidCallback onConfirm;

  const ToggleConfirmationDialog({
    super.key,
    required this.detail,
    required this.isValidate,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final String title = isValidate ? 'Konfirmasi Validasi' : 'Konfirmasi Pembatalan';
    final String content = isValidate
        ? 'Apakah Anda yakin ingin memvalidasi setoran ${detail.nama ?? '-'}?'
        : 'Apakah Anda yakin ingin membatalkan setoran ${detail.nama ?? '-'}?';

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
          onPressed: () => Navigator.of(context).pop(),
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
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
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
  }
}