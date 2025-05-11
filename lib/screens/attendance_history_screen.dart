import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/attendance_service.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  final AttendanceService _attendanceService = AttendanceService();

  AttendanceHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historique des pointages',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFBE9E7E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _attendanceService.getAttendanceHistory(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final attendances = snapshot.data?.docs ?? [];

          if (attendances.isEmpty) {
            return const Center(
              child: Text('Aucun pointage enregistré'),
            );
          }

          return ListView.builder(
            itemCount: attendances.length,
            itemBuilder: (context, index) {
              final attendance =
                  attendances[index].data() as Map<String, dynamic>;
              final date = attendance['date'] as Timestamp;
              final dateTime = date.toDate();
              final dateFormatter = DateFormat('dd/MM/yyyy');
              final timeFormatter = DateFormat('HH:mm:ss');

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFBE9E7E),
                    child: Icon(
                      Icons.fingerprint,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    'Pointage du ${dateFormatter.format(dateTime)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Heure: ${timeFormatter.format(dateTime)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBE9E7E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      attendance['status'] ?? 'present',
                      style: const TextStyle(
                        color: Color(0xFFBE9E7E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
