import 'package:flutter/material.dart';
import 'new_appointment.dart';
import 'edit_appointment.dart';
import 'appointment_details.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../models/cita.dart';
import '../models/usuario.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Cita> _appointments = [];
  bool _isLoading = true;
  Usuario? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser().then((_) => _loadAppointments());
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _loadAppointments() async {
    try {
      final appointments = await AppointmentService.getAppointments();
      List<Cita> filteredAppointments = appointments;
      if (_currentUser?.roleId == 3) { // Client role
        filteredAppointments = appointments.where((cita) => cita.idCliente == _currentUser!.idUsuario).toList();
      }
      // Filter out finalized appointments
      filteredAppointments = filteredAppointments.where((cita) => cita.estado?.toLowerCase() != 'finalizada').toList();
      // Sort by date ascending (next ones first)
      filteredAppointments.sort((a, b) => (a.fechaServicio ?? DateTime.now()).compareTo(b.fechaServicio ?? DateTime.now()));
      // Take only first 3
      filteredAppointments = filteredAppointments.take(3).toList();
      if (mounted) {
        setState(() {
          _appointments = filteredAppointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar citas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatCardData(value: _appointments.length.toString(), label: 'Total'),
      _StatCardData(value: _appointments.where((a) => a.estado == 'confirmada').length.toString(), label: 'Confirmadas'),
      _StatCardData(value: _appointments.where((a) => a.estado == 'pendiente').length.toString(), label: 'Pendientes'),
    ];

    final appointmentWidgets = _isLoading
        ? [const Center(child: CircularProgressIndicator())]
        : _appointments.map((appointment) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _AppointmentCard(data: appointment),
            )).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _SearchBar(),
              const SizedBox(height: 20),
              Row(
                children: stats
                    .map(
                      (stat) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _StatCard(data: stat),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Próximas Citas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFF7B500),
                    ),
                    child: const Text(
                      'Ver todas',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...appointmentWidgets,
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[500]),
                const SizedBox(width: 12),
                Text(
                  'Buscar citas...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NewAppointmentScreen(),
              ),
            );
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFF7B500),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 28, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class _StatCardData {
  _StatCardData({required this.value, required this.label});
  final String value;
  final String label;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08888888),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            style: const TextStyle(
              color: Color(0xFF7D7D7D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _Appointment {
  _Appointment({
    required this.title,
    required this.time,
    required this.client,
    required this.status,
    required this.statusColor,
  });

  final String title;
  final String time;
  final String client;
  final String status;
  final Color statusColor;
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.data});

  final Cita data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AppointmentDetailsScreen(cita: data),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEFEFEF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4D9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: Color(0xFFF7B500),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.servicios?.isNotEmpty == true ? data.servicios!.map((d) => d.servicio?.nombre ?? 'Servicio').join(', ') : (data.servicio?.nombre ?? 'Servicio'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 18, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${data.fechaServicio?.toLocal().toString().split(' ')[0] ?? 'Fecha'} ${data.horaEntrada ?? 'Hora'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.usuario?.nombre ?? 'Cliente',
                    style: const TextStyle(
                      color: Color(0xFF8C8C8C),
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFFF7B500)),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditAppointmentScreen(cita: data),
                      ),
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: data.estado == 'confirmada' ? const Color(0xFFFFE7AF) : const Color(0xFFFFF1D1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data.estado ?? 'pendiente',
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}