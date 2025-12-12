import 'package:flutter/material.dart';
import '../layouts/inicio_sesion.dart';

/// Versión simplificada del wrapper de autenticación.
/// Solo muestra la pantalla de inicio de sesión sin lógica adicional.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: InicioSesion(),
      ),
    );
  }
}