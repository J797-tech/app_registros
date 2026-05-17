import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api_service.dart';
import 'home_page.dart';
import 'preferences_service.dart';
import 'welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _prefs = PreferencesService();
  final _apiService = ApiService();
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = const Color(0xFF6750A4);
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final loggedUser = await _prefs.getCurrentUser();

    if (loggedUser != null) {
      // Intentar sincronizar preferencias desde la API
      final apiPrefs = await _apiService.getPrefs(loggedUser);

      bool isDark = await _prefs.isDarkMode(loggedUser);
      int? colorVal = await _prefs.getPrimaryColor(loggedUser);

      if (apiPrefs != null) {
        if (apiPrefs['isDarkMode'] != null) isDark = apiPrefs['isDarkMode'];
        if (apiPrefs['primaryColor'] != null)
          colorVal = apiPrefs['primaryColor'];
      }

      setState(() {
        _username = loggedUser;
        _isLoggedIn = true;
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
        if (colorVal != null) _primaryColor = Color(colorVal);
      });
    }
    setState(() => _isLoading = false);
  }

  void changeTheme(bool isDark) {
    if (_username == null) return;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    _prefs.setDarkMode(_username!, isDark);
    _apiService.updatePrefs(_username!, isDark, _primaryColor.value);
  }

  void changeColor(Color color) {
    if (_username == null) return;
    setState(() {
      _primaryColor = color;
    });
    _prefs.setPrimaryColor(_username!, color.value);
    _apiService.updatePrefs(
      _username!,
      _themeMode == ThemeMode.dark,
      color.value,
    );
  }

  void login(String username) async {
    // Al iniciar sesión, traemos las preferencias del servidor
    final apiPrefs = await _apiService.getPrefs(username);

    bool isDark = false;
    int? colorVal;

    if (apiPrefs != null) {
      isDark = apiPrefs['isDarkMode'] ?? false;
      colorVal = apiPrefs['primaryColor'];

      // Actualizamos caché local
      await _prefs.setDarkMode(username, isDark);
      if (colorVal != null) await _prefs.setPrimaryColor(username, colorVal);
    }

    setState(() {
      _username = username;
      _isLoggedIn = true;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      if (colorVal != null) _primaryColor = Color(colorVal);
    });
    await _prefs.setCurrentUser(username);
  }

  void logout() async {
    setState(() {
      _isLoggedIn = false;
      _username = null;
      _themeMode = ThemeMode.system;
      _primaryColor = const Color(0xFF6750A4);
    });
    await _prefs.setCurrentUser(null);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'App Modern Registros',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(centerTitle: true),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(centerTitle: true),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
        ),
      ),
      themeMode: _themeMode,
      home: _isLoggedIn ? HomePage(username: _username!) : const WelcomePage(),
    );
  }
}
