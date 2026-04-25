import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyUsers = 'registered_users';
  static const String _keyCurrentLoggedUser = 'current_logged_user';

  // --- User Management ---

  Future<void> registerUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getAllUsers();
    users[username] = password;
    await prefs.setString(_keyUsers, json.encode(users));
  }

  Future<void> migrateUserData(String oldUsername, String newUsername) async {
    final prefs = await SharedPreferences.getInstance();

    // Migrar registros
    final String? records = prefs.getString('records_$oldUsername');
    if (records != null) {
      await prefs.setString('records_$newUsername', records);
      await prefs.remove('records_$oldUsername');
    }

    // Migrar modo oscuro
    if (prefs.containsKey('isDarkMode_$oldUsername')) {
      final bool dark = prefs.getBool('isDarkMode_$oldUsername') ?? false;
      await prefs.setBool('isDarkMode_$newUsername', dark);
      await prefs.remove('isDarkMode_$oldUsername');
    }

    // Migrar color primario
    if (prefs.containsKey('primaryColor_$oldUsername')) {
      final int color = prefs.getInt('primaryColor_$oldUsername') ?? 0;
      await prefs.setInt('primaryColor_$newUsername', color);
      await prefs.remove('primaryColor_$oldUsername');
    }

    // Eliminar usuario antiguo de la lista de credenciales
    final users = await _getAllUsers();
    final password = users[oldUsername];
    if (password != null) {
      users.remove(oldUsername);
      users[newUsername] = password; // Se mantiene la contraseña actual
      await prefs.setString(_keyUsers, json.encode(users));
    }
  }

  Future<Map<String, String>> _getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(_keyUsers);
    if (usersJson == null) return {};
    return Map<String, String>.from(json.decode(usersJson));
  }

  Future<bool> authenticate(String username, String password) async {
    final users = await _getAllUsers();
    return users.containsKey(username) && users[username] == password;
  }

  Future<void> setCurrentUser(String? username) async {
    final prefs = await SharedPreferences.getInstance();
    if (username == null) {
      await prefs.remove(_keyCurrentLoggedUser);
    } else {
      await prefs.setString(_keyCurrentLoggedUser, username);
    }
  }

  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentLoggedUser);
  }

  // --- User-Specific Settings ---

  Future<void> setDarkMode(String username, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode_$username', value);
  }

  Future<bool> isDarkMode(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode_$username') ?? false;
  }

  Future<void> setPrimaryColor(String username, int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor_$username', colorValue);
  }

  Future<int?> getPrimaryColor(String username) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('primaryColor_$username');
  }

  // --- User-Specific Records ---

  Future<void> saveRecords(
    String username,
    List<Map<String, dynamic>> records,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(records);
    await prefs.setString('records_$username', encodedData);
  }

  Future<List<Map<String, dynamic>>> getRecords(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('records_$username');
    if (encodedData == null) return [];
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.cast<Map<String, dynamic>>();
  }

  Future<Map<String, String>> getUser(String username) async {
    final users = await _getAllUsers();
    if (users.containsKey(username)) {
      return {'username': username, 'password': users[username]!};
    }
    return {};
  }
}
