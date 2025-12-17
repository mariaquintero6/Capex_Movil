import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../models/cita.dart';
import '../models/servicio.dart';
import '../models/detalle_cita.dart';
import '../models/usuario.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  List<Map<String, dynamic>> _selectedServices = [];
  String? _selectedProfessional;
  String? _selectedDocType;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<Servicio> _servicios = [];
  List<Map<String, dynamic>> _empleados = [];
  List<Map<String, dynamic>> _clientes = [];
  bool _isLoading = false;
  int? _selectedClientId;
  int? _selectedEmployeeId;
  TimeOfDay? _selectedTime;
  Usuario? _currentUser;

  double get _total => _selectedServices.fold(0.0, (sum, item) {
    final servicio = item['servicio'] as Servicio;
    final cantidad = item['cantidad'] as int;
    final precio = double.tryParse(servicio.precio ?? '0') ?? 0.0;
    return sum + (precio * cantidad);
  });

  int get _totalDuration => _selectedServices.fold(0, (sum, item) {
    final servicio = item['servicio'] as Servicio;
    final cantidad = item['cantidad'] as int;
    final duracion = servicio.duracion ?? 0;
    return sum + (duracion * cantidad);
  });

  @override
  void initState() {
    super.initState();
    _loadUser().then((_) => _loadData());
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
      // Pre-fill client data if user is a client
      if (_currentUser?.roleId == 3) {
        _selectedClientId = _currentUser!.idUsuario;
        _nameController.text = _currentUser!.nombre ?? '';
        _documentController.text = _currentUser!.documento ?? '';
        _phoneController.text = _currentUser!.telefono ?? '';
        _emailController.text = _currentUser!.correo ?? '';
        _selectedDocType = _currentUser!.tipoDocumento;
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final servicios = await AppointmentService.getServices();
      final empleados = await AppointmentService.getEmpleados();
      List<Map<String, dynamic>> clientes = [];
      if (_currentUser?.roleId != 3) {
        clientes = await AppointmentService.getClientes();
      }

      print('📊 === DATOS CARGADOS ===');
      print('Servicios: ${servicios.length}');
      print('Empleados: ${empleados.length}');
      if (empleados.isNotEmpty) {
        print('Primer empleado: ${empleados.first}');
      }
      print('Clientes: ${clientes.length}');
      print('========================');

      setState(() {
        _servicios = servicios;
        _empleados = empleados;
        _clientes = clientes;
      });
    } catch (e) {
      print('❌ Error cargando datos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _documentController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF9B000)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Nueva Cita',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Servicio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _SearchField(
              hintText: 'Buscar Servicio',
              icon: Icons.search,
              onTap: () async {
                if (_isLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cargando servicios...')),
                  );
                  return;
                }
                if (_servicios.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No hay servicios disponibles')),
                  );
                  return;
                }
                final selected = await showDialog<Servicio>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Seleccionar Servicio'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _servicios.length,
                        itemBuilder: (context, index) {
                          final servicio = _servicios[index];
                          return ListTile(
                            title: Text(servicio.nombre ?? 'Servicio'),
                            subtitle: Text('Precio: ${servicio.precio ?? 'N/A'}'),
                            onTap: () => Navigator.of(context).pop(servicio),
                          );
                        },
                      ),
                    ),
                  ),
                );
                if (selected != null) {
                  final cantidad = await showDialog<int>(
                    context: context,
                    builder: (context) => _CantidadDialog(),
                  ) ?? 1;
                  setState(() {
                    _selectedServices.add({'servicio': selected, 'cantidad': cantidad});
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            ..._selectedServices.map((item) {
              final servicio = item['servicio'] as Servicio;
              final cantidad = item['cantidad'] as int;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SelectedServiceCard(
                  service: servicio.nombre ?? 'Servicio',
                  duration: servicio.duracion?.toString() ?? 'N/A',
                  price: '\$${(double.tryParse(servicio.precio ?? '0') ?? 0.0) * cantidad}',
                  cantidad: cantidad,
                  onRemove: () {
                    setState(() {
                      _selectedServices.remove(item);
                    });
                  },
                  onCantidadChanged: (newCantidad) {
                    setState(() {
                      item['cantidad'] = newCantidad;
                    });
                  },
                ),
              );
            }),
            const SizedBox(height: 24),
            const Text(
              'Valor Total:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${_total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF9B000),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Fecha y Hora',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Fecha',
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _dateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                    });
                  }
                },
                child: AbsorbPointer(
                  child: _InputField(
                    controller: _dateController,
                    hintText: 'dd/mm/aaaa',
                    suffixIcon: Icons.calendar_today,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Hora',
              child: GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedTime = picked;
                      _timeController.text = picked.format(context);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: _InputField(
                    controller: _timeController,
                    hintText: '9:00 AM',
                    suffixIcon: Icons.keyboard_arrow_down,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Profesional y Duración',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // DROPDOWN CORREGIDO
            _LabeledField(
              label: 'Profesional',
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<int>(
                        value: _selectedEmployeeId,
                        hint: const Text('Seleccionar Profesional', style: TextStyle(color: Colors.grey)),
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: _empleados.map((e) {
                          print('📋 Empleado: ${e['nombre']} - ID: ${e['id']}');
                          final empleadoId = e['id'] as int?;
                          return DropdownMenuItem<int>(
                            value: empleadoId,
                            child: Text(e['nombre']?.toString() ?? 'Sin nombre'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          print('🔍 ====================================');
                          print('🔍 DROPDOWN onChanged EJECUTADO');
                          print('🔍 Valor seleccionado: $value');
                          print('🔍 ====================================');
                          setState(() {
                            _selectedEmployeeId = value;
                            if (value != null) {
                              final emp = _empleados.firstWhere(
                                (e) => e['id'] == value,
                                orElse: () => {},
                              );
                              _selectedProfessional = emp['nombre']?.toString();
                              print('✅ _selectedEmployeeId: $_selectedEmployeeId');
                              print('✅ _selectedProfessional: $_selectedProfessional');
                            } else {
                              _selectedProfessional = null;
                            }
                          });
                        },
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Duración total (min)',
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  _totalDuration.toString(),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Información del Cliente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Tipo de Doc.',
              child: _DropdownField(
                value: _selectedDocType,
                hintText: 'CC',
                onChanged: (value) {
                  setState(() {
                    _selectedDocType = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: '# Documento',
              child: Row(
                children: [
                  Expanded(
                    child: _InputField(
                      controller: _documentController,
                      hintText: 'Número',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final doc = _documentController.text.trim();
                      if (doc.isNotEmpty) {
                        final cliente = _clientes.firstWhere(
                          (c) => c['documento']?.toString() == doc || c['numero_documento']?.toString() == doc,
                          orElse: () => {},
                        );
                        if (cliente.isNotEmpty) {
                          setState(() {
                            _selectedClientId = cliente['id'] ?? cliente['id_usuario'];
                            _nameController.text = cliente['nombre'] ?? '';
                            _phoneController.text = cliente['telefono'] ?? '';
                            _emailController.text = cliente['correo'] ?? '';
                          });
                          print('✅ Cliente encontrado: ${cliente['nombre']} (ID: $_selectedClientId)');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cliente no encontrado')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9B000),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Buscar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Nombre del cliente',
              child: _InputField(
                controller: _nameController,
                hintText: 'Nombre completo',
              ),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Teléfono',
              child: _InputField(
                controller: _phoneController,
                hintText: 'Número de teléfono',
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Correo Electrónico',
              child: _InputField(
                controller: _emailController,
                hintText: 'correo@ejemplo.com',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  print('🔍 === VALIDANDO DATOS ===');
                  print('Servicios: ${_selectedServices.length}');
                  print('Fecha: ${_dateController.text}');
                  print('Hora: ${_timeController.text}');
                  print('TimeOfDay: $_selectedTime');
                  print('Empleado ID: $_selectedEmployeeId');
                  print('Empleado Nombre: $_selectedProfessional');
                  print('Cliente ID: $_selectedClientId');
                  print('========================');
                  
                  if (_selectedServices.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debe seleccionar al menos un servicio')),
                    );
                    return;
                  }

                  if (_dateController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debe seleccionar una fecha')),
                    );
                    return;
                  }

                  if (_timeController.text.isEmpty || _selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debe seleccionar una hora')),
                    );
                    return;
                  }

                  if (_selectedEmployeeId == null) {
                    print('❌ ERROR: _selectedEmployeeId es null');
                    print('Empleados disponibles: $_empleados');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Debe seleccionar un profesional. Empleados cargados: ${_empleados.length}'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  if (_selectedClientId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debe buscar o ingresar un cliente')),
                    );
                    return;
                  }

                  try {
                    final dateParts = _dateController.text.split('/');
                    final fechaFormateada = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';

                    final horaEntrada = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00';

                    final horaSalida = AppointmentService.calcularHoraSalida(horaEntrada, _totalDuration);

                    final citaData = {
                      'id_cliente': _selectedClientId,
                      'fecha_servicio': fechaFormateada,
                      'hora_entrada': horaEntrada,
                      'hora_salida': horaSalida,
                      'estado': 'Agendada',
                      'valor_total': _total,
                      'motivo': 'Cita creada desde app móvil',
                    };

                    final serviciosData = _selectedServices.map((item) {
                      final servicio = item['servicio'] as Servicio;
                      final cantidad = item['cantidad'] as int;
                      
                      return {
                        'id_empleado': _selectedEmployeeId,
                        'id_servicio': servicio.idServicio,
                        'cantidad': cantidad,
                        'precio_unitario': double.tryParse(servicio.precio ?? '0') ?? 0.0,
                        'hora_inicio': horaEntrada,
                        'hora_finalizacion': horaSalida,
                        'duracion': servicio.duracion ?? 60,
                        'estado': 'pendiente',
                      };
                    }).toList();

                    final appointmentData = {
                      'cita': citaData,
                      'servicios': serviciosData,
                    };

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF9B000),
                        ),
                      ),
                    );

                    await AppointmentService.createAppointment(appointmentData);

                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Cita creada exitosamente!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.of(context).pop(true);
                    
                  } catch (e) {
                    Navigator.of(context).pop();
                    
                    print('Error completo: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al crear cita: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9B000),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.hintText,
    required this.icon,
    this.onTap,
  });

  final String hintText;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hintText,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedServiceCard extends StatelessWidget {
  const _SelectedServiceCard({
    required this.service,
    required this.duration,
    required this.price,
    required this.cantidad,
    required this.onRemove,
    required this.onCantidadChanged,
  });

  final String service;
  final String duration;
  final String price;
  final int cantidad;
  final VoidCallback onRemove;
  final ValueChanged<int> onCantidadChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('Cantidad: ', style: TextStyle(fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        if (cantidad > 1) onCantidadChanged(cantidad - 1);
                      },
                      child: const Icon(Icons.remove, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text('$cantidad', style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onCantidadChanged(cantidad + 1),
                      child: const Icon(Icons.add, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close,
                color: Color(0xFFF9B000),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hintText,
    this.suffixIcon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (suffixIcon != null)
            Icon(
              suffixIcon,
              color: Colors.grey[600],
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.hintText,
    required this.onChanged,
    this.items,
  });

  final String? value;
  final String hintText;
  final ValueChanged<String?> onChanged;
  final List<String>? items;

  @override
  Widget build(BuildContext context) {
    final defaultItems = ['CC', 'CE', 'TI', 'PAS'];
    final dropdownItems = items ?? defaultItems;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hintText,
                style: TextStyle(color: Colors.grey[600]),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              items: dropdownItems.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _CantidadDialog extends StatefulWidget {
  @override
  _CantidadDialogState createState() => _CantidadDialogState();
}

class _CantidadDialogState extends State<_CantidadDialog> {
  int _cantidad = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Cantidad'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              if (_cantidad > 1) setState(() => _cantidad--);
            },
            icon: const Icon(Icons.remove),
          ),
          Text('$_cantidad', style: const TextStyle(fontSize: 20)),
          IconButton(
            onPressed: () => setState(() => _cantidad++),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_cantidad),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}