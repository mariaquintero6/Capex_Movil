class Usuario {
  int? idUsuario;
  String? nombre;
  String? tipoDocumento;
  String? documento;
  String? telefono;
  String? correo;
  String? contrasena;
  int? roleId;
  String? foto;
  String? estado;
  bool? mustChangePassword;
  String? passwordChangedAt;
  String? createdAt;
  String? updatedAt;
  Map<String, dynamic>? rol;
  Map<String, dynamic>? privileges;

  Usuario({
    this.idUsuario,
    this.nombre,
    this.tipoDocumento,
    this.documento,
    this.telefono,
    this.correo,
    this.contrasena,
    this.roleId,
    this.foto,
    this.estado,
    this.mustChangePassword,
    this.passwordChangedAt,
    this.createdAt,
    this.updatedAt,
    this.rol,
    this.privileges,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nombre': nombre,
      'tipo_documento': tipoDocumento,
      'documento': documento,
      'telefono': telefono,
      'correo': correo,
      'contrasena': contrasena,
      'roleId': roleId,
      'foto': foto,
      'estado': estado,
      'must_change_password': mustChangePassword,
      'password_changed_at': passwordChangedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'rol': rol,
      'privileges': privileges,
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['id_usuario'],
      nombre: json['nombre'],
      tipoDocumento: json['tipo_documento'],
      documento: json['documento'],
      telefono: json['telefono'],
      correo: json['correo'],
      contrasena: json['contrasena'],
      roleId: json['roleId'],
      foto: json['foto'],
      estado: json['estado'],
      mustChangePassword: json['must_change_password'],
      passwordChangedAt: json['password_changed_at'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      rol: json['rol'],
      privileges: json['privileges'],
    );
  }
}