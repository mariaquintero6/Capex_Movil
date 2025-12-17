import 'package:flutter/material.dart';
import '../models/cita.dart';
import '../services/appointment_service.dart';

class EditAppointmentScreen extends StatefulWidget {
  const EditAppointmentScreen({
    super.key,
    required this.cita,
  });

  final Cita cita;

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  String? _selectedService;
  String? _selectedProfessional;
  String? _selectedDocType;
  String? _selectedStatus;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<Map<String, dynamic>> _empleados = [];
  bool _isLoadingEmpleados = false;
  int? _selectedEmployeeId;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadEmpleados();
  }

  Future<void> _loadEmpleados() async {
    setState(() => _isLoadingEmpleados = true);
    try {
      final empleados = await AppointmentService.getEmpleados();
      final uniqueEmpleados = <int?, Map<String, dynamic>>{};
      for (var e in empleados) {
        uniqueEmpleados[e['id']] = e;
      }
      setState(() {
        _empleados = uniqueEmpleados.values.toList();
        _isLoadingEmpleados = false;
      });
      print('✅ Empleados IDs: ${_empleados.map((e) => e['id'])}');
      if (_selectedEmployeeId != null && !_empleados.any((e) => e['id'] == _selectedEmployeeId)) {
        print('⚠️ Empleado inicial $_selectedEmployeeId no encontrado en lista, seteando a null');
        _selectedEmployeeId = null;
      } else {
        print('✅ Empleado inicial $_selectedEmployeeId encontrado o null');
      }
      print('📋 _selectedEmployeeId final: $_selectedEmployeeId');
      if (_empleados.isNotEmpty) {
        print('Primer empleado: ${_empleados.first}');
      }
    } catch (e) {
      print('❌ Error cargando empleados: $e');
      setState(() => _isLoadingEmpleados = false);
    }
  }

  void _loadInitialData() {
    print('🔍 idServicioCliente: ${widget.cita.idServicioCliente}');
    _selectedService = widget.cita.servicios?.isNotEmpty == true
        ? widget.cita.servicios!.first.servicio?.nombre
        : null;

    if (widget.cita.fechaServicio != null) {
      final fecha = widget.cita.fechaServicio!;
      _dateController.text = '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    }

    _timeController.text = widget.cita.horaEntrada ?? '';

    if (widget.cita.horaEntrada != null) {
      try {
        final parts = widget.cita.horaEntrada!.split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        print('Error parseando hora: $e');
      }
    }

    _durationController.text = widget.cita.servicios?.isNotEmpty == true
        ? (widget.cita.servicios!.first.duracion?.toString() ?? '60')
        : '60';

    _selectedDocType = widget.cita.usuario?.tipoDocumento ?? 'CC';
    _documentController.text = widget.cita.usuario?.documento ?? '';
    _nameController.text = widget.cita.usuario?.nombre ?? '';
    _phoneController.text = widget.cita.usuario?.telefono ?? '';
    _emailController.text = widget.cita.usuario?.correo ?? '';
    _selectedStatus = widget.cita.estado;

    if (widget.cita.servicios?.isNotEmpty == true) {
      _selectedEmployeeId = widget.cita.servicios!.first.idEmpleado;
      print('📋 ID de empleado inicial: $_selectedEmployeeId');
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
          'Editar Cita',
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
              'Servicio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedService != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedService!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
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
              '\$${widget.cita.valorTotal?.toStringAsFixed(0) ?? '0'}',
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
                    initialDate: widget.cita.fechaServicio ?? DateTime.now(),
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
                    initialTime: _selectedTime ?? TimeOfDay.now(),
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
            // DROPDOWN CORREGIDO CON 'id'
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
                      child: _isLoadingEmpleados
                          ? const Text('Cargando...', style: TextStyle(color: Colors.grey))
                          : DropdownButton<int>(
                              value: _selectedEmployeeId,
                              hint: const Text('Seleccionar Profesional', style: TextStyle(color: Colors.grey)),
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: _empleados.map((e) {
                                final empleadoId = e['id'] as int?;
                                return DropdownMenuItem<int>(
                                  value: empleadoId,
                                  child: Text(e['nombre']?.toString() ?? 'Sin nombre'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                print('🔍 Profesional cambiado a ID: $value');
                                setState(() {
                                  _selectedEmployeeId = value;
                                  if (value != null) {
                                    final emp = _empleados.firstWhere(
                                      (e) => e['id'] == value,
                                      orElse: () => {},
                                    );
                                    _selectedProfessional = emp['nombre']?.toString();
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
              child: _InputField(
                controller: _durationController,
                hintText: 'ej. 120',
                keyboardType: TextInputType.number,
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
              child: _InputField(
                controller: _documentController,
                hintText: 'Número',
                keyboardType: TextInputType.number,
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
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Estado',
              child: _StatusDropdown(
                value: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  print('🔄 Intentando actualizar cita');
                  print('📅 Fecha: ${_dateController.text}');
                  print('⏰ Hora: ${_timeController.text}');
                  print('👤 Empleado seleccionado: $_selectedEmployeeId');
                  print('🆔 ID Cita: ${widget.cita.idServicioCliente}');
                  print('📄 Documento: ${_documentController.text}');

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

                  if (widget.cita.idServicioCliente == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error: ID de cita no encontrado')),
                    );
                    return;
                  }

                  try {
                    final dateParts = _dateController.text.split('/');
                    final fechaFormateada = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';

                    final horaEntrada = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00';

                    final duracion = int.tryParse(_durationController.text) ?? 60;
                    final horaSalida = AppointmentService.calcularHoraSalida(horaEntrada, duracion);

                    final citaData = {
                      'id_cliente': widget.cita.idCliente,
                      'fecha_servicio': fechaFormateada,
                      'hora_inicio': horaEntrada,
                      'hora_finalizacion': horaSalida,
                      'estado': _selectedStatus ?? 'Agendada',
                      'valor_total': widget.cita.valorTotal ?? 0.0,
                      'motivo': 'Cita actualizada desde app móvil',
                    };

                    final serviciosData = widget.cita.servicios?.map((d) => {
                      'id_empleado': _selectedEmployeeId ?? d.idEmpleado,
                      'id_servicio': d.idServicio,
                      'cantidad': d.cantidad,
                      'precio_unitario': d.precioUnitario,
                      'hora_inicio': horaEntrada,
                      'hora_finalizacion': horaSalida,
                      'duracion': d.duracion,
                      'estado': d.estado,
                    }).toList() ?? [];

                    final usuarioData = {
                      'tipoDocumento': _selectedDocType,
                      'documento': _documentController.text,
                      'nombre': _nameController.text,
                      'telefono': _phoneController.text,
                      'correo': _emailController.text,
                    };

                    final appointmentData = {
                      'cita': citaData,
                      'servicios': serviciosData,
                      'usuario': usuarioData,
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

                    await AppointmentService.updateAppointment(
                      widget.cita.idServicioCliente!,
                      appointmentData,
                    );

                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Cita actualizada exitosamente!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.of(context).pop(true);
                    
                  } catch (e) {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    
                    print('Error completo: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al actualizar cita: $e'),
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
                  'Actualizar',
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
  });

  final String? value;
  final String hintText;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = ['CC', 'CE', 'TI', 'PAS'];

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
              items: items.map((String item) {
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

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = ['Agendada', 'Confirmada', 'Reprogramada', 'En proceso', 'Finalizada', 'Pagada', 'Cancelada por el usuario', 'No asistio'];

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
              hint: const Text(
                'Seleccionar Estado',
                style: TextStyle(color: Colors.grey),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              items: items.map((String item) {
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