import 'package:flutter/material.dart';
import 'new_appointment.dart';
import 'edit_appointment.dart';
import '../services/appointment_service.dart';
import '../models/cita.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Cita> _allAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
    _tabController.addListener(_onTabChanged);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final appointments = await AppointmentService.getAppointments();
      if (mounted) {
        setState(() {
          _allAppointments = appointments;
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

  void _onTabChanged() {
    setState(() {});
  }

  List<Cita> _getFilteredAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_tabController.index) {
      case 0: // Todas
        return _allAppointments;
      case 1: // Hoy
        return _allAppointments.where((cita) {
          if (cita.fechaServicio == null) return false;
          final citaDate = DateTime(cita.fechaServicio!.year, cita.fechaServicio!.month, cita.fechaServicio!.day);
          return citaDate.isAtSameMomentAs(today);
        }).toList();
      case 2: // Pendientes
        return _allAppointments.where((cita) => cita.estado == 'pendiente').toList();
      case 3: // Confirmadas
        return _allAppointments.where((cita) => cita.estado == 'confirmada').toList();
      default:
        return _allAppointments;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointments = _getFilteredAppointments();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gestión de Citas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NewAppointmentScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9B000),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.black87,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFFF9B000),
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.black87,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Todas'),
                Tab(text: 'Hoy'),
                Tab(text: 'Pendientes'),
                Tab(text: 'Confirmadas'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _AppointmentCard(data: appointments[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.data});

  final Cita data;

  @override
  Widget build(BuildContext context) {
    final initials = data.usuario?.nombre?.split(' ').map((e) => e[0]).take(2).join().toUpperCase() ?? 'U';
    final isPending = data.estado == 'pendiente';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF9B000),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.servicios?.isNotEmpty == true ? data.servicios!.map((d) => d.servicio?.nombre ?? 'Servicio').join(', ') : (data.servicio?.nombre ?? 'Servicio'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data.usuario?.nombre ?? 'Cliente',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.fechaServicio?.toLocal().toString().split(' ')[0] ?? 'Fecha'} ${data.horaEntrada ?? 'Hora'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFF9B000)),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditAppointmentScreen(cita: data),
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPending
                          ? const Color(0xFFFFF1D1)
                          : const Color(0xFFF9B000),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data.estado ?? 'Estado',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '\$${data.valorTotal?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

