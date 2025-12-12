class Servicio {
  int? idServicio;
  String? nombre;
  String? descripcion;
  String? precio;
  int? duracion;

  Servicio({
    this.idServicio,
    this.nombre,
    this.descripcion,
    this.precio,
    this.duracion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_servicio': idServicio,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'duracion': duracion,
    };
  }

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      idServicio: json['id_servicio'] ?? json['id'],
      nombre: json['nombre'] ?? json['name'],
      descripcion: json['descripcion'] ?? json['description'],
      precio: json['precio']?.toString(),
      duracion: json['duracion'] is int ? json['duracion'] : int.tryParse(json['duracion']?.toString() ?? '0'),
    );
  }
}