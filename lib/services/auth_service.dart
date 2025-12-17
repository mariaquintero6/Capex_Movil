import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

class AuthService {
  static const String baseUrl = 'https://capex-back.onrender.com/api';

  static Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      if (data['data'] != null && data['data']['token'] != null) {
        await prefs.setString('token', data['data']['token']);
      }
      if (data['data'] != null && data['data']['user'] != null) {
        await prefs.setString('user', jsonEncode(data['data']['user']));
        return {'success': true, 'user': Usuario.fromJson(data['data']['user'])};
      } else {
        return {'success': false, 'message': 'Usuario no encontrado'};
      }
    } else {
      final errorData = jsonDecode(response.body);
      return {'success': false, 'message': errorData['message'] ?? 'Error de autenticación'};
    }
  }

  static Future<Map<String, dynamic>> register(Usuario usuario) async {
    print('AuthService.register: sending request');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(usuario.toJson()),
      ).timeout(const Duration(seconds: 120));
      print('AuthService.register: response status ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('AuthService.register: response body $data');
        if (data['usuario'] != null) {
          return {'success': true, 'user': Usuario.fromJson(data['usuario'])};
        } else {
          return {'success': false, 'message': 'Error al registrar usuario'};
        }
      } else {
        final errorData = jsonDecode(response.body);
        print('AuthService.register: error $errorData');
        return {'success': false, 'message': errorData['message'] ?? 'Error de registro'};
      }
    } catch (e) {
      print('AuthService.register: exception $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> userData) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/usuarios/$id/profile'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['usuario'] != null) {
        // Update stored user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data['usuario']));
        return {'success': true, 'user': Usuario.fromJson(data['usuario'])};
      } else {
        return {'success': false, 'message': 'Error al actualizar usuario'};
      }
    } else {
      final errorData = jsonDecode(response.body);
      return {'success': false, 'message': errorData['message'] ?? 'Error al actualizar usuario'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Usuario?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return Usuario.fromJson(jsonDecode(userJson));
    }
    return null;
  }
}