import 'package:flutter/material.dart';

import 'main.dart';
import 'preferences_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _prefs = PreferencesService();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isDark = false;
  bool _obscurePass = true;
  Color _currentColor = const Color(0xFF6750A4);
  String? _oldUsername;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final currentUsername = await _prefs.getCurrentUser();
    if (currentUsername != null) {
      final userData = await _prefs.getUser(currentUsername);
      final dark = await _prefs.isDarkMode(currentUsername);
      final colorVal = await _prefs.getPrimaryColor(currentUsername);

      setState(() {
        _oldUsername = currentUsername;
        _userController.text = userData['username'] ?? '';
        _passController.text = userData['password'] ?? '';
        _isDark = dark;
        if (colorVal != null) _currentColor = Color(colorVal);
      });
    }
  }

  void _updateUser() async {
    final newUsername = _userController.text.trim();
    final newPassword = _passController.text.trim();

    if (newUsername.isEmpty || newPassword.isEmpty) {
      _showSnackBar('Los campos no pueden estar vacíos');
      return;
    }

    if (_oldUsername != null) {
      if (newUsername != _oldUsername) {
        // Migrar todos los datos al nuevo nombre de usuario
        await _prefs.migrateUserData(_oldUsername!, newUsername);
        // Actualizar la contraseña en el nuevo nombre
        await _prefs.registerUser(newUsername, newPassword);
        // Actualizar sesión actual
        await _prefs.setCurrentUser(newUsername);

        if (mounted) {
          MyApp.of(context)?.login(newUsername);
        }
        _oldUsername = newUsername;
      } else {
        // Solo actualizar contraseña si el nombre es el mismo
        await _prefs.registerUser(newUsername, newPassword);
      }

      if (mounted) {
        _showSnackBar('Perfil actualizado y datos migrados');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myApp = MyApp.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        children: [
          _buildSectionHeader(
            context,
            'Perfil de Usuario',
            Icons.person_outline,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _userController,
            decoration: const InputDecoration(
              labelText: 'Nombre de Usuario',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passController,
            obscureText: _obscurePass,
            decoration: InputDecoration(
              labelText: 'Nueva Contraseña',
              prefixIcon: const Icon(Icons.password_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _updateUser,
              icon: const Icon(Icons.save_as_rounded),
              label: const Text('GUARDAR CAMBIOS'),
            ),
          ),
          const SizedBox(height: 40),
          _buildSectionHeader(
            context,
            'Personalización',
            Icons.palette_outlined,
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            subtitle: Text(_isDark ? 'Activado' : 'Desactivado'),
            secondary: Icon(_isDark ? Icons.dark_mode : Icons.light_mode),
            value: _isDark,
            onChanged: (val) {
              setState(() => _isDark = val);
              myApp?.changeTheme(val);
            },
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
            child: Text(
              'Color de la aplicación',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Center(
            child: Wrap(
              spacing: 15,
              runSpacing: 15,
              children:
                  [
                    const Color(0xFF6750A4),
                    const Color(0xFF0061A4),
                    const Color(0xFF006A60),
                    const Color(0xFF984061),
                    const Color(0xFF705D00),
                    const Color(0xFF006874),
                  ].map((color) {
                    final isSelected = _currentColor.value == color.value;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _currentColor = color);
                        myApp?.changeColor(color);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: 20,
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
