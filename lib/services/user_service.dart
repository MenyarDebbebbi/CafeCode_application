import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtenir les données de l'utilisateur courant
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      print('Erreur lors de la récupération des données: $e');
      return null;
    }
  }

  // Mettre à jour les données de l'utilisateur
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Aucun utilisateur connecté');

      await _firestore.collection('users').doc(user.uid).update(data);
    } catch (e) {
      print('Erreur lors de la mise à jour des données: $e');
    }
  }

  // Obtenir l'historique des pointages de l'utilisateur
  Stream<QuerySnapshot> getUserPointages() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Aucun utilisateur connecté');

    return _firestore
        .collection('pointages')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Obtenir les statistiques de pointage de l'utilisateur
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Aucun utilisateur connecté');

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final querySnapshot = await _firestore
          .collection('pointages')
          .where('userId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      int totalPointages = querySnapshot.docs.length;
      int retards = 0;
      // TODO: Implémenter la logique de calcul des retards

      return {
        'totalPointages': totalPointages,
        'retards': retards,
        'moisEnCours': '${now.month}/${now.year}',
      };
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      throw e;
    }
  }

  // Vérifier si l'utilisateur est en retard
  bool isRetard(DateTime pointageTime) {
    final hour = pointageTime.hour;
    final minute = pointageTime.minute;

    // Considérer comme retard si arrivée après 9h00
    return hour > 9 || (hour == 9 && minute > 0);
  }

  Future<Map<String, dynamic>?> getUserByDeviceId(String deviceId) async {
    try {
      final doc = await _firestore.collection('users').doc(deviceId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  Future<bool> saveUser({
    required String deviceId,
    required String firstName,
    required String lastName,
  }) async {
    try {
      await _firestore.collection('users').doc(deviceId).set({
        'firstName': firstName,
        'lastName': lastName,
        'deviceId': deviceId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Erreur lors de l\'enregistrement de l\'utilisateur: $e');
      return false;
    }
  }

  Future<bool> updateLastLogin(String deviceId) async {
    try {
      await _firestore.collection('users').doc(deviceId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du dernier login: $e');
      return false;
    }
  }
}
