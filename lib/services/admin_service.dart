import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  static const String _adminStatusKey = 'admin_status';
  static const String _defaultUsername = 'admin';
  static const String _defaultPassword = 'admin';

  Future<void> initializeDefaultAdmin() async {
    // Cette méthode pourrait être utilisée pour initialiser les données admin dans une base de données
    // Pour l'instant, nous utilisons des valeurs codées en dur
  }

  Future<bool> checkAdminCredentials(String username, String password) async {
    // Vérifier si les identifiants correspondent aux valeurs par défaut
    return username == _defaultUsername && password == _defaultPassword;
  }

  Future<void> setAdminStatus(bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adminStatusKey, isAdmin);
  }

  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adminStatusKey) ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adminStatusKey, false);
  }
}
