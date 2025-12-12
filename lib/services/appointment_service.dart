import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/servicio.dart';
import '../models/cita.dart';
import 'auth_service.dart';

class AppointmentService {
  // URL base de tu API desplegada
  static const String baseUrl = 'https://capex-back.onrender.com/api';

  // Obtener servicios
  static Future<List<Servicio>> getServices() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/servicios'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('GET Servicios - Status: ${response.statusCode}');
      print('GET Servicios - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data['success'] == true && data['data'] is List) {
          list = data['data'];
        } else {
          throw Exception('Formato de respuesta inválido');
        }
        return list.where((item) => item != null && item is Map).map((json) => Servicio.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar servicios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getServices: $e');
      rethrow;
    }
  }

  // Obtener empleados
  static Future<List<Map<String, dynamic>>> getEmpleados() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/empleados'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('GET Empleados - Status: ${response.statusCode}');
      print('GET Empleados - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data['success'] == true && data['data'] is List) {
          list = data['data'];
        } else {
          throw Exception('Formato de respuesta inválido');
        }
        return list.where((item) => item != null && item is Map).map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Error al cargar empleados: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getEmpleados: $e');
      rethrow;
    }
  }

  // Obtener clientes
  static Future<List<Map<String, dynamic>>> getClientes() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('GET Clientes - Status: ${response.statusCode}');
      print('GET Clientes - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data['success'] == true && data['data'] is List) {
          list = data['data'];
        } else {
          throw Exception('Formato de respuesta inválido');
        }
        return list.where((item) => item != null && item is Map).map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Error al cargar clientes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getClientes: $e');
      rethrow;
    }
  }

  // Obtener citas
  static Future<List<Cita>> getAppointments() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/citas'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('GET Citas - Status: ${response.statusCode}');
      print('GET Citas - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null && data['data']['citas'] != null) {
          final List<dynamic> citas = data['data']['citas'];
          return citas.map((item) => Cita.fromJson(item)).toList();
        } else {
          throw Exception('Formato de respuesta inválido');
        }
      } else {
        throw Exception('Error al cargar citas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getAppointments: $e');
      rethrow;
    }
  }

  // Actualizar cita
  static Future<void> updateAppointment(int id, Map<String, dynamic> appointmentData) async {
    try {
      final token = await AuthService.getToken();
      
      print('=== ACTUALIZAR CITA ===');
      print('URL: $baseUrl/citas/$id');
      print('Body: ${jsonEncode(appointmentData)}');
      print('======================');
      
      final response = await http.put(
        Uri.parse('$baseUrl/citas/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(appointmentData),
      );

      print('PUT Cita - Status: ${response.statusCode}');
      print('PUT Cita - Body: ${response.body}');

      if (response.statusCode == 200) {
        return;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Error desconocido';
        throw Exception('Error al actualizar cita: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print('Error en updateAppointment: $e');
      rethrow;
    }
  }

  // Crear cita - CORREGIDO PARA COINCIDIR CON EL BACKEND
  static Future<void> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      final token = await AuthService.getToken();
      
      // Imprimir datos antes de enviar
      print('=== DATOS A ENVIAR ===');
      print('URL: $baseUrl/citas');
      print('Body: ${jsonEncode(appointmentData)}');
      print('Token: ${token != null ? "Presente" : "No presente"}');
      print('=====================');

      final response = await http.post(
        Uri.parse('$baseUrl/citas'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(appointmentData),
      );

      print('=== RESPUESTA DEL SERVIDOR ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==============================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Cita creada exitosamente');
        return;
      } else {
        // Intentar decodificar el error del servidor
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? errorData['error'] ?? errorData.toString();
          throw Exception('Failed to create appointment: ${response.statusCode} - $errorMessage');
        } catch (e) {
          throw Exception('Failed to create appointment: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Error en createAppointment: $e');
      rethrow;
    }
  }

  // Calcular hora de salida basada en la hora de entrada y duración total
  static String calcularHoraSalida(String horaEntrada, int duracionMinutos) {
    try {
      // Parse hora_entrada (formato: "HH:mm:ss")
      final parts = horaEntrada.split(':');
      final hora = int.parse(parts[0]);
      final minuto = int.parse(parts[1]);
      
      // Crear DateTime para hacer el cálculo
      final inicio = DateTime(2024, 1, 1, hora, minuto);
      final fin = inicio.add(Duration(minutes: duracionMinutos));
      
      // Formatear como "HH:mm:ss"
      return '${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}:00';
    } catch (e) {
      print('Error calculando hora de salida: $e');
      return horaEntrada; // Retornar la misma hora si hay error
    }
  }
}