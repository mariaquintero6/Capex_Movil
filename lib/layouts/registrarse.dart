import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'inicio_sesion.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';

class Registrarse extends StatefulWidget {
  const Registrarse({super.key});

  @override
  _RegistrarseState createState() => _RegistrarseState();
}

class _RegistrarseState extends State<Registrarse> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _selectedDocumentType;
  final List<String> _documentTypes = ['Cédula', 'Pasaporte', 'Tarjeta de Identidad'];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _documentNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        child: Image.asset(
                          "assets/images/logo3.png",
                          width: 160,
                          height: 160,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Title
                      const Text(
                        "Regístrate",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Step indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(2, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentStep == index ? const Color(0xFFFDCB2F) : Colors.grey[300],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      // Form fields
                      SizedBox(
                        height: 400, // Adjust height as needed
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // Step 1
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nombre completo
                                const Text("Nombre completo", style: TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: "Tu nombre completo",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Correo electrónico
                                const Text("Correo electrónico", style: TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    hintText: "tuemail@ejemplo.com",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Teléfono
                                const Text("Teléfono", style: TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    hintText: "Número de teléfono",
                                    prefix: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text('🇨🇴'),
                                        SizedBox(width: 4),
                                        Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Step 2
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tipo de documento
                                const Text("Tipo de documento", style: TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedDocumentType,
                                  hint: const Text("Selecciona tipo"),
                                  items: _documentTypes.map((type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDocumentType = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Número de documento
                                const Text("Número de documento", style: TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _documentNumberController,
                                  decoration: InputDecoration(
                                    hintText: "Número de documento",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Contraseña
                                const Text("Contraseña", style: TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: "Contraseña",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Confirmar contraseña
                                const Text("Confirmar contraseña", style: TextStyle(fontSize: 16)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    hintText: "Confirmar contraseña",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword = !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFDCB2F)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        "Atrás",
                        style: TextStyle(
                          color: Color(0xFFFDCB2F),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == 0
                        ? _nextStep
                        : () async {
                            if (_isLoading) return; // Prevent multiple taps

                            // Log field values for debugging
                            print('Registration attempt:');
                            print('Nombre: ${_nameController.text}');
                            print('Email: ${_emailController.text}');
                            print('Telefono: ${_phoneController.text}');
                            print('Tipo Documento: $_selectedDocumentType');
                            print('Documento: ${_documentNumberController.text}');
                            print('Password: ${_passwordController.text}');
                            print('Confirm Password: ${_confirmPasswordController.text}');

                            // Basic validation
                            if (_nameController.text.isEmpty ||
                                _emailController.text.isEmpty ||
                                _phoneController.text.isEmpty ||
                                _selectedDocumentType == null ||
                                _documentNumberController.text.isEmpty ||
                                _passwordController.text.isEmpty ||
                                _confirmPasswordController.text.isEmpty) {
                              print('Validation failed: Some fields are empty');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Por favor, completa todos los campos.')),
                              );
                              return;
                            }

                            if (_passwordController.text != _confirmPasswordController.text) {
                              print('Validation failed: Passwords do not match');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Las contraseñas no coinciden.')),
                              );
                              return;
                            }

                            // Email validation (basic)
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                            if (!emailRegex.hasMatch(_emailController.text)) {
                              print('Validation failed: Invalid email format');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Correo electrónico inválido.')),
                              );
                              return;
                            }

                            print('Validation passed, proceeding to register');

                            setState(() => _isLoading = true);

                            // Handle registration
                            final documentTypeMap = {
                              'Cédula': 'CC',
                              'Pasaporte': 'PP',
                              'Tarjeta de Identidad': 'TI',
                            };
                            final usuario = Usuario(
                              nombre: _nameController.text,
                              tipoDocumento: documentTypeMap[_selectedDocumentType] ?? _selectedDocumentType,
                              documento: _documentNumberController.text,
                              telefono: _phoneController.text,
                              correo: _emailController.text,
                              contrasena: _passwordController.text,
                              estado: 'Activo',
                            );
                            print('Calling AuthService.register');
                            AuthService.register(usuario); // Don't await, assume success
                            print('Registration initiated, navigating to login');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Registro exitoso. Inicia sesión.')),
                            );
                            print('About to navigate to InicioSesion');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const InicioSesion()),
                            );
                            print('Navigation done');
                            setState(() => _isLoading = false);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDCB2F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            _currentStep == 0 ? "Siguiente" : "Registrarme",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Link
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: RichText(
              text: TextSpan(
                text: "¿Ya tienes cuenta? ",
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: "Inicia sesión aquí",
                    style: const TextStyle(
                      color: Color(0xFFFF7A00),
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const InicioSesion()),
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
