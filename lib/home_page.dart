import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'main.dart';
import 'preferences_service.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _prefs = PreferencesService();

  List<Map<String, dynamic>> _records = [];
  String _selectedCategory = 'General';
  final List<String> _categories = [
    'General',
    'Trabajo',
    'Personal',
    'Importante',
  ];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await _prefs.getRecords(widget.username);
    setState(() => _records = records);
  }

  void _saveOrUpdateRecord() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final record = {
        'text': _dataController.text,
        'category': _selectedCategory,
        'date': DateFormat('dd/MM/yyyy HH:mm').format(now),
      };

      setState(() {
        if (_editingIndex == null) {
          _records.insert(0, record);
        } else {
          _records[_editingIndex!] = record;
          _editingIndex = null;
        }
      });

      await _prefs.saveRecords(widget.username, _records);
      _dataController.clear();
      _showSnackBar('Registro guardado correctamente');
    }
  }

  void _startEditing(int index) {
    setState(() {
      _editingIndex = index;
      _dataController.text = _records[index]['text'];
      _selectedCategory = _records[index]['category'];
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
      _dataController.clear();
      _selectedCategory = 'General';
    });
  }

  void _deleteRecord(int index) async {
    setState(() {
      _records.removeAt(index);
      if (_editingIndex == index) _editingIndex = null;
    });
    await _prefs.saveRecords(widget.username, _records);
    _showSnackBar('Registro eliminado');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Registros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(colorScheme),
      body: Column(
        children: [
          // Formulario de entrada
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 0,
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _editingIndex == null
                                ? Icons.add_circle_outline
                                : Icons.edit_note,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _editingIndex == null
                                ? 'Nuevo Registro'
                                : 'Editando Registro',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          if (_editingIndex != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: _cancelEditing,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dataController,
                        decoration: const InputDecoration(
                          hintText: 'Descripción del dato...',
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Escribe algo'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                        ),
                        items: _categories
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val!),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _saveOrUpdateRecord,
                          icon: Icon(
                            _editingIndex == null ? Icons.save : Icons.update,
                          ),
                          label: Text(
                            _editingIndex == null ? 'GUARDAR' : 'ACTUALIZAR',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Text(
                  'Historial',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _records.isEmpty
                ? const Center(child: Text('No hay registros guardados'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final item = _records[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              _getCategoryIcon(item['category']),
                              color: colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item['text'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Categoría: ${item['category']}',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item['date'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => _startEditing(index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _deleteRecord(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Trabajo':
        return Icons.work_outline;
      case 'Personal':
        return Icons.person_outline;
      case 'Importante':
        return Icons.priority_high_rounded;
      default:
        return Icons.notes_rounded;
    }
  }

  Widget _buildDrawer(ColorScheme colorScheme) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              widget.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('Sesión Activa'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: colorScheme.onPrimary,
              child: Text(
                widget.username[0].toUpperCase(),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            decoration: BoxDecoration(color: colorScheme.primary),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () => MyApp.of(context)?.logout(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
