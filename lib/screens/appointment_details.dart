import 'package:flutter/material.dart';
import 'edit_appointment.dart';
import '../models/cita.dart';
import '../models/detalle_cita.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  const AppointmentDetailsScreen({
    super.key,
    required this.cita,
  });

  final Cita cita;

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
          'Detalles de Cita',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFF9B000)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditAppointmentScreen(cita: cita),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Cliente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _DetailField(
              label: 'Tipo de Doc.',
              value: cita.usuario?.tipoDocumento ?? 'N/A',
            ),
            const SizedBox(height: 16),
            _DetailField(
              label: '# Documento',
              value: cita.usuario?.documento ?? 'N/A',
            ),
            const SizedBox(height: 16),
            _DetailField(
              label: 'Nombre del cliente',
              value: cita.usuario?.nombre ?? 'N/A',
            ),
            const SizedBox(height: 16),
            _DetailField(
              label: 'Teléfono',
              value: cita.usuario?.telefono ?? 'N/A',
            ),
            const SizedBox(height: 16),
            _DetailField(
              label: 'Correo Electrónico',
              value: cita.usuario?.correo ?? 'N/A',
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
            _DetailField(
              label: 'Fecha',
              value: cita.fechaServicio != null
                  ? '${cita.fechaServicio!.day.toString().padLeft(2, '0')}/${cita.fechaServicio!.month.toString().padLeft(2, '0')}/${cita.fechaServicio!.year}'
                  : 'N/A',
            ),
            const SizedBox(height: 16),
            _DetailField(
              label: 'Hora',
              value: cita.horaEntrada ?? 'N/A',
            ),
            const SizedBox(height: 24),
            const Text(
              'Servicios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (cita.servicios != null && cita.servicios!.isNotEmpty)
              ...cita.servicios!.map((detalle) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ServiceDetailCard(detalle: detalle),
                  ))
            else
              const Text('No hay servicios asociados'),
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
              '\$${cita.valorTotal?.toStringAsFixed(0) ?? '0'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF9B000),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Estado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cita.estado == 'pendiente'
                    ? const Color(0xFFFFF1D1)
                    : const Color(0xFFF9B000),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cita.estado ?? 'N/A',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceDetailCard extends StatelessWidget {
  const _ServiceDetailCard({required this.detalle});

  final DetalleCita detalle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detalle.servicio?.nombre ?? 'Servicio',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Cantidad: ', style: TextStyle(fontSize: 14)),
              Text('${detalle.cantidad}', style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Duración: ', style: TextStyle(fontSize: 14)),
              Text('${detalle.duracion} min', style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Precio unitario: ', style: TextStyle(fontSize: 14)),
              Text('\$${detalle.precioUnitario.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Hora inicio: ', style: TextStyle(fontSize: 14)),
              Text(detalle.horaInicio, style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Hora finalización: ', style: TextStyle(fontSize: 14)),
              Text(detalle.horaFinalizacion, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}