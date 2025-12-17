import 'servicio.dart';
import 'usuario.dart';
import 'detalle_cita.dart';

class Cita {
  int? idServicioCliente;
  int? idCliente;
  DateTime? fechaServicio;
  String? horaEntrada;
  String? horaSalida;
  String? estado;
  double? valorTotal;
  String? motivo;
  Servicio? servicio;
  Usuario? usuario;
  List<DetalleCita>? servicios;

  Cita({
    this.idServicioCliente,
    this.idCliente,
    this.fechaServicio,
    this.horaEntrada,
    this.horaSalida,
    this.estado,
    this.valorTotal,
    this.motivo,
    this.servicio,
    this.usuario,
    this.servicios,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_servicio_cliente': idServicioCliente,
      'id_cliente': idCliente,
      'fecha_servicio': fechaServicio != null ? '${fechaServicio!.year}-${fechaServicio!.month.toString().padLeft(2, '0')}-${fechaServicio!.day.toString().padLeft(2, '0')}' : null,
      'hora_inicio': horaEntrada,
      'hora_finalizacion': horaSalida,
      'estado': estado,
      'valor_total': valorTotal,
      'motivo': motivo,
      'servicios': servicios?.map((d) => {'id_servicio': d.idServicio, 'cantidad': d.cantidad}).toList(),
    };
  }

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      idServicioCliente: json['id_cita'] is int ? json['id_cita'] : int.tryParse(json['id_cita']?.toString() ?? ''),
      idCliente: json['id_cliente'] is int ? json['id_cliente'] : int.tryParse(json['id_cliente']?.toString() ?? ''),
      fechaServicio: json['fecha_servicio'] != null ? DateTime.tryParse(json['fecha_servicio'].toString()) : null,
      horaEntrada: json['hora_entrada']?.toString(),
      horaSalida: json['hora_salida']?.toString(),
      estado: json['estado']?.toString(),
      valorTotal: json['valor_total'] is num ? (json['valor_total'] as num).toDouble() : double.tryParse(json['valor_total']?.toString() ?? '0'),
      motivo: json['motivo']?.toString(),
      servicio: json['servicio'] != null ? (json['servicio'] is Map ? Servicio.fromJson(json['servicio']) : Servicio(nombre: json['servicio'].toString())) :
                json['tipo_servicio'] != null ? Servicio(nombre: json['tipo_servicio'].toString()) :
                json['nombre_servicio'] != null ? Servicio(nombre: json['nombre_servicio'].toString()) : null,
      servicios: json['servicios'] != null && json['servicios'] is List ? (json['servicios'] as List).map((d) => DetalleCita.fromJson(d)).toList() : null,
      usuario: json['usuario'] != null && json['usuario'] is Map ? Usuario.fromJson(json['usuario']) : null,
    );
  }
} 