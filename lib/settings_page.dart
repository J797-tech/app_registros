import 'package:flutter/material.dart';

import 'main.dart';
import 'preferences_service.dart';
import 'api_service.dart';
import 'task_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _prefs = PreferencesService();
  final _apiService = ApiService();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isDark = false;
  bool _obscurePass = true;
  Color _currentColor = const Color(0xFF6750A4);
  String? _username;
  int _totalTasks = 0;
  int _completedTasks = 0;

  List<TaskModel> _taskHistory = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final currentUsername = await _prefs.getCurrentUser();
    if (currentUsername != null) {
      final userData = await _prefs.getUser(currentUsername);
      final dark = await _prefs.isDarkMode(currentUsername);
      final colorVal = await _prefs.getPrimaryColor(currentUsername);
      
      // Cargamos tareas desde el servidor
      try {
        _taskHistory = await _apiService.getTasks(currentUsername);
      } catch (e) {
        debugPrint("Error cargando historial: $e");
      }

      setState(() {
        _username = currentUsername;
        _userController.text = userData['username'] ?? '';
        _passController.text = userData['password'] ?? '';
        _isDark = dark;
        if (colorVal != null) _currentColor = Color(colorVal);

        _totalTasks = _taskHistory.length;
        _completedTasks = _taskHistory.where((r) => r.isCompleted).length;
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

    if (_username != null) {
      if (newUsername != _username) {
        await _prefs.migrateUserData(_username!, newUsername);
        await _prefs.registerUser(newUsername, newPassword);
        await _prefs.setCurrentUser(newUsername);
        if (mounted) MyApp.of(context)?.login(newUsername);
        _username = newUsername;
      } else {
        await _prefs.registerUser(newUsername, newPassword);
      }
      if (mounted) _showSnackBar('Perfil actualizado');
    }
  }

  void _clearAllTasks() async {
    if (_username != null) {
      try {
        await _apiService.deleteAllTasks(_username!);
        await _loadAllData();
        _showSnackBar('Todo el historial ha sido eliminado');
      } catch (e) {
        _showSnackBar('Error al limpiar historial');
      }
    }
  }

  void _deleteSingleTask(String id) async {
    try {
      await _apiService.deleteTask(id);
      await _loadAllData();
      _showSnackBar('Tarea eliminada');
    } catch (e) {
      _showSnackBar('Error al eliminar');
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
    final colorScheme = Theme.of(context).colorScheme;
    final productivity = _totalTasks == 0
        ? 0
        : ((_completedTasks / _totalTasks) * 100).toInt();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Rendimiento'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfileHeader(colorScheme, productivity),
          const SizedBox(height: 25),
          _buildStatsRow(colorScheme, productivity),
          const SizedBox(height: 30),
          _buildSectionTitle('Configuración de Cuenta'),
          _buildAccountCard(colorScheme),
          const SizedBox(height: 30),
          _buildSectionTitle('Personalización'),
          _buildAppearanceCard(colorScheme),
          const SizedBox(height: 30),
          _buildSectionTitle('Historial de Tareas'),
          _buildHistoryList(colorScheme),
          const SizedBox(height: 30),
          _buildSectionTitle('Acciones de Datos'),
          _buildDangerZone(colorScheme),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHistoryList(ColorScheme colorScheme) {
    if (_taskHistory.isEmpty) {
      return const Center(child: Text('No hay tareas en el historial'));
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _taskHistory.length > 5 ? 5 : _taskHistory.length, // Mostrar últimas 5
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final task = _taskHistory[index];
          return ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                fontSize: 14,
              ),
            ),
            subtitle: Text(task.category, style: const TextStyle(fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _deleteSingleTask(task.id!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ColorScheme colorScheme, int productivity) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: colorScheme.primary,
            child: Text(
              _username != null ? _username![0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _username ?? 'Usuario',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Nivel de Productividad: $productivity%',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ColorScheme colorScheme, int productivity) {
    return Row(
      children: [
        _buildStatCard(
          'Tareas',
          _totalTasks.toString(),
          Icons.list_alt,
          colorScheme,
        ),
        const SizedBox(width: 15),
        _buildStatCard(
          'Hechas',
          _completedTasks.toString(),
          Icons.check_circle_outline,
          colorScheme,
        ),
        const SizedBox(width: 15),
        _buildStatCard(
          'Efectividad',
          '$productivity%',
          Icons.bolt,
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAccountCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: const InputDecoration(
                labelText: 'Nombre de Usuario',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passController,
              obscureText: _obscurePass,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
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
              child: FilledButton(
                onPressed: _updateUser,
                child: const Text('Actualizar Datos'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: _isDark,
            onChanged: (val) {
              setState(() => _isDark = val);
              MyApp.of(context)?.changeTheme(val);
            },
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Color de Identidad',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Wrap(
              spacing: 12,
              children:
                  [
                    const Color(0xFF6750A4),
                    const Color(0xFF0061A4),
                    const Color(0xFF006A60),
                    const Color(0xFF984061),
                    const Color(0xFFFF5252),
                  ].map((color) {
                    final isSelected = _currentColor.value == color.value;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _currentColor = color);
                        MyApp.of(context)?.changeColor(color);
                      },
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 18,
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: Colors.red.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.redAccent, width: 0.5),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.delete_sweep_outlined,
          color: Colors.redAccent,
        ),
        title: const Text(
          'Limpiar Historial',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text('Borra todas tus tareas y reinicia estadísticas'),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('¿Estás seguro?'),
              content: const Text('Esta acción no se puede deshacer.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCELAR'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _clearAllTasks();
                  },
                  child: const Text(
                    'LIMPIAR TODO',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
