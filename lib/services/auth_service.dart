import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Méthode simplifiée pour sauvegarder l'utilisateur
  Future<bool> saveUser({
    required String firstName,
    required String lastName,
    required String deviceId,
  }) async {
    try {
      // Créer un document dans la collection users
      await _firestore.collection('users').doc(deviceId).set({
        'firstName': firstName,
        'lastName': lastName,
        'deviceId': deviceId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
      return false;
    }
  }

  // Vérifier si l'utilisateur existe
  Future<bool> userExists(String firstName, String lastName) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('firstName', isEqualTo: firstName)
          .where('lastName', isEqualTo: lastName)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
      return null;
    }
  }

  // Sauvegarder les données utilisateur
  Future<bool> saveUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Erreur lors de la sauvegarde des données: $e');
      return false;
    }
  }
}
