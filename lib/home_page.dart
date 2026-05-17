import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'api_service.dart';
import 'main.dart';
import 'preferences_service.dart';
import 'settings_page.dart';
import 'task_model.dart';

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
  final _apiService = ApiService();

  List<TaskModel> _records = [];
  List<TaskModel> _filteredRecords = [];
  String _selectedCategory = 'General';
  String _filterCategory = 'Todas';
  String _searchQuery = '';
  final List<String> _categories = [
    'General',
    'Trabajo',
    'Estudio',
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
    try {
      final records = await _apiService.getTasks(widget.username);
      setState(() {
        _records = records;
        _applyFilters();
      });
    } catch (e) {
      debugPrint("DEBUG ERROR (load): $e");
      _showSnackBar('Error al conectar con el servidor');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredRecords = _records.where((record) {
        final matchesSearch = record.title.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final matchesCategory =
            _filterCategory == 'Todas' || record.category == _filterCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _saveOrUpdateRecord() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_editingIndex == null) {
          final newTask = TaskModel(
            username: widget.username,
            title: _dataController.text,
            category: _selectedCategory,
            date: '', // El servidor asigna la fecha
          );
          await _apiService.createTask(newTask);
        } else {
          final task = _records[_editingIndex!];
          await _apiService.updateTask(task.id!, {
            'title': _dataController.text,
            'category': _selectedCategory,
          });
          _editingIndex = null;
        }

        await _loadRecords();
        _dataController.clear();
        if (mounted) Navigator.pop(context);
        _showSnackBar('Tarea guardada');
      } catch (e) {
        debugPrint("DEBUG ERROR (save): $e");
        _showSnackBar('Error al guardar en el servidor: $e');
      }
    }
  }

  void _toggleComplete(int index) async {
    final item = _filteredRecords[index];
    try {
      await _apiService.updateTask(item.id!, {
        'isCompleted': !item.isCompleted,
      });
      await _loadRecords();
    } catch (e) {
      _showSnackBar('Error al actualizar tarea');
    }
  }

  void _startEditing(int index) {
    final actualItem = _filteredRecords[index];
    setState(() {
      _editingIndex = _records.indexOf(actualItem);
      _dataController.text = actualItem.title;
      _selectedCategory = actualItem.category;
    });
    _showTaskSheet();
  }

  void _deleteRecord(int index) async {
    final item = _filteredRecords[index];
    try {
      await _apiService.deleteTask(item.id!);
      await _loadRecords();
      _showSnackBar('Tarea eliminada');
    } catch (e) {
      _showSnackBar('Error al eliminar tarea');
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

  void _showTaskSheet() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _editingIndex == null ? 'Nueva Tarea' : 'Editar Tarea',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _dataController,
                autofocus: true,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: const InputDecoration(
                  labelText: '¿Qué vas a hacer?',
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Ingresa una descripción' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: colorScheme.surface,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveOrUpdateRecord,
                  child: Text(_editingIndex == null ? 'CREAR' : 'ACTUALIZAR'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ).then((_) {
      if (_editingIndex != null) {
        setState(() {
          _editingIndex = null;
          _dataController.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final completedCount = _records.where((r) => r.isCompleted).length;
    final totalCount = _records.length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Enfoque'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ).then((_) => _loadRecords()),
          ),
        ],
      ),
      drawer: _buildDrawer(colorScheme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTaskSheet,
        label: const Text('Nueva Tarea'),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildHeader(colorScheme, progress, completedCount, totalCount),
          _buildSearchBar(colorScheme),
          _buildCategoryFilters(),
          Expanded(
            child: _filteredRecords.isEmpty
                ? const Center(child: Text('No hay tareas pendientes'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, index) {
                      final item = _filteredRecords[index];
                      final isCompleted = item.isCompleted;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: colorScheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: isCompleted,
                            onChanged: (_) => _toggleComplete(index),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? colorScheme.outline
                                  : colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            '${item.category} • ${item.date != "" ? DateFormat('dd/MM HH:mm').format(DateTime.parse(item.date)) : ""}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.outline,
                            ),
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Editar'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                            onSelected: (val) {
                              if (val == 'edit') _startEditing(index);
                              if (val == 'delete') _deleteRecord(index);
                            },
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

  Widget _buildHeader(
    ColorScheme colorScheme,
    double progress,
    int completed,
    int total,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola, ${widget.username} 👋',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tienes $completed de $total tareas completadas',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        onChanged: (val) {
          setState(() => _searchQuery = val);
          _applyFilters();
        },
        decoration: InputDecoration(
          hintText: 'Buscar tareas...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final filterOptions = ['Todas', ..._categories];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: filterOptions.map((cat) {
          final isSelected = _filterCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) {
                setState(() => _filterCategory = cat);
                _applyFilters();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
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
            accountEmail: const Text('Planificando tu éxito'),
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
            title: const Text('Configuración y Perfil'),
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
