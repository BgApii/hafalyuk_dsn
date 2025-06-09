import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hafalyuk_dsn/models/pa_model.dart';
import 'package:hafalyuk_dsn/widgets/info_item_widget.dart';

class DosenProfilePage extends StatelessWidget {
  final Data? data;

  const DosenProfilePage({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    String initials =
        data?.nama?.isNotEmpty == true
            ? data!.nama!
                .trim()
                .split(' ')
                .map((e) => e[0])
                .take(2)
                .join()
                .toUpperCase()
            : 'U';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundColor: const Color(0xFF4A4A4A),
                child: Text(
                  initials,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 60,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              color: Color(0xFFC2E9D7),
              thickness: 4,
              height: 20,
              indent: 50,
              endIndent: 50,
            ),
            SizedBox(height: 16.0),
            
            SizedBox(
              width: double.infinity,
              child: Card(
                color: const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoItem(
                        icon: Icons.person,
                        label: 'Nama',
                        value: data?.nama ?? '-',
                      ),
                      InfoItem(
                        icon: Icons.badge,
                        label: 'NIP',
                        value: data?.nip ?? '-',
                      ),
                      InfoItem(
                        icon: Icons.email,
                        label: 'Email',
                        value: data?.email ?? '-',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
