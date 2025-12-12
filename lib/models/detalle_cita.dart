import 'servicio.dart';

class DetalleCita {
  int? idDetalleServicioCliente;
  int idEmpleado;
  int idServicio;
  int idServicioCliente;
  double precioUnitario;
  int cantidad;
  String horaInicio;
  String horaFinalizacion;
  int duracion;
  String estado;
  String? observaciones;
  Servicio? servicio;

  DetalleCita({
    this.idDetalleServicioCliente,
    required this.idEmpleado,
    required this.idServicio,
    required this.idServicioCliente,
    required this.precioUnitario,
    required this.cantidad,
    required this.horaInicio,
    required this.horaFinalizacion,
    required this.duracion,
    required this.estado,
    this.observaciones,
    this.servicio,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_empleado': idEmpleado,
      'id_servicio': idServicio,
      'cantidad': cantidad,
      'hora_inicio': horaInicio,
      'precio_unitario': precioUnitario,
      'observaciones': '',
    };
  }

  factory DetalleCita.fromJson(Map<String, dynamic> json) {
    return DetalleCita(
      idDetalleServicioCliente: json['id_detalle_servicio'] is int ? json['id_detalle_servicio'] : int.tryParse(json['id_detalle_servicio']?.toString() ?? ''),
      idEmpleado: json['id_empleado'] is int ? json['id_empleado'] : int.tryParse(json['id_empleado']?.toString() ?? ''),
      idServicio: json['id_servicio'] is int ? json['id_servicio'] : int.tryParse(json['id_servicio']?.toString() ?? ''),
      idServicioCliente: json['id_cita'] is int ? json['id_cita'] : int.tryParse(json['id_cita']?.toString() ?? ''),
      precioUnitario: json['precio_unitario'] is num ? (json['precio_unitario'] as num).toDouble() : (double.tryParse(json['precio_unitario']?.toString() ?? '0') ?? 0.0),
      cantidad: json['cantidad'] is int ? json['cantidad'] : int.tryParse(json['cantidad']?.toString() ?? '1'),
      horaInicio: json['hora_inicio']?.toString() ?? '',
      horaFinalizacion: json['hora_finalizacion']?.toString() ?? '',
      duracion: json['duracion'] is int ? json['duracion'] : int.tryParse(json['duracion']?.toString() ?? '0'),
      estado: json['estado']?.toString() ?? '',
      observaciones: json['observaciones']?.toString(),
      servicio: json['servicio'] != null && json['servicio'] is Map ? Servicio.fromJson(json['servicio']) : null,
    );
  }
} 