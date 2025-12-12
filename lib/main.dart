import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'layouts/inicio_sesion.dart';
import 'layouts/registrarse.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppCapex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const InicioSesion(),
    );
  }
}


