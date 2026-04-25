import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_page.dart';
import 'login_page.dart';
import 'welcome_page.dart';
import 'preferences_service.dart';

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
      final isDark = await _prefs.isDarkMode(loggedUser);
      final colorVal = await _prefs.getPrimaryColor(loggedUser);

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
  }

  void changeColor(Color color) {
    if (_username == null) return;
    setState(() {
      _primaryColor = color;
    });
    _prefs.setPrimaryColor(_username!, color.value);
  }

  void login(String username) async {
    final isDark = await _prefs.isDarkMode(username);
    final colorVal = await _prefs.getPrimaryColor(username);

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
        textTheme: GoogleFonts.poppinsTextTheme(),
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
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      themeMode: _themeMode,
      home: _isLoggedIn ? HomePage(username: _username!) : const WelcomePage(),
    );
  }
}
