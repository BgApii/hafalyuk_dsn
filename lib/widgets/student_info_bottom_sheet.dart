import 'package:flutter/material.dart';
import 'package:hafalyuk_dsn/models/setoran_model.dart';
import 'package:hafalyuk_dsn/widgets/info_item_widget.dart';

class StudentInfoBottomSheet extends StatelessWidget {
  final Info? info;

  const StudentInfoBottomSheet({super.key, this.info});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            InfoItem(
              icon: Icons.person,
              label: 'Nama',
              value: info?.nama ?? '-',
            ),
            InfoItem(icon: Icons.badge, label: 'NIM', value: info?.nim ?? '-'),
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
}
