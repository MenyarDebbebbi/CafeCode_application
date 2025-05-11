import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Vérifier si un pointage existe déjà pour aujourd'hui
  Future<bool> hasCheckedInToday() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('attendances')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification du pointage: $e');
      return false;
    }
  }

  // Enregistrer un nouveau pointage
  Future<bool> recordAttendance() async {
    try {
      if (await hasCheckedInToday()) {
        return false; // Déjà pointé aujourd'hui
      }

      await _firestore.collection('attendances').add({
        'timestamp': FieldValue.serverTimestamp(),
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'time': DateFormat('HH:mm:ss').format(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Erreur lors de l\'enregistrement du pointage: $e');
      return false;
    }
  }

  // Récupérer l'historique des pointages
  Stream<QuerySnapshot> getAttendanceHistory() {
    return _firestore
        .collection('attendances')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<List<DocumentSnapshot>> getMonthlyAttendance(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    final querySnapshot = await _firestore
        .collection('attendances')
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .orderBy('date')
        .get();

    return querySnapshot.docs;
  }
}
