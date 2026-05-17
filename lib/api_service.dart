import 'dart:convert';

import 'package:http/http.dart' as http;

import 'task_model.dart';

class ApiService {
  // Nueva URL del servidor en la nube (Render)
  static const String baseUrl = "https://overunidad4.onrender.com/api";

  // --- AUTENTICACIÓN Y USUARIOS ---

  Future<bool> registerUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- PREFERENCIAS (TEMA Y COLOR) ---

  Future<Map<String, dynamic>?> getPrefs(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/prefs/$username'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> updatePrefs(String username, bool isDark, int color) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/prefs'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "isDarkMode": isDark,
          "primaryColor": color,
        }),
      );
    } catch (e) {
      // Silencioso
    }
  }

  // --- TAREAS ---

  Future<List<TaskModel>> getTasks(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tasks/$username'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => TaskModel.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar tareas');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 201) {
      return TaskModel.fromJson(jsonDecode(response.body));
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Error desconocido');
    }
  }

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar tarea');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar tarea');
    }
  }

  Future<void> deleteAllTasks(String username) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/all/$username'),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al limpiar historial');
    }
  }
}
