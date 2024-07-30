import 'package:flutter/material.dart';
import 'package:turnos/models/appointment.dart';
import 'package:turnos/services/appointment_service.dart';

class AppointmentTable extends StatefulWidget {
  const AppointmentTable({super.key});

  @override
  _AppointmentTableState createState() => _AppointmentTableState();
}

class _AppointmentTableState extends State<AppointmentTable> {
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    setState(() {
      // Asumiendo que obtienes todos los turnos como una lista
      _appointments = AppointmentService.getAppointments().values.expand((e) => e).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabla de Turnos'),
      ),
      body: DataTable(
        columns: _buildColumns(),
        rows: _buildRows(),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      const DataColumn(label: Text('Fecha')),
      const DataColumn(label: Text('Hora')),
      const DataColumn(label: Text('Título')),
      const DataColumn(label: Text('Asignado a')),
      const DataColumn(label: Text('Acciones')),
    ];
  }

  List<DataRow> _buildRows() {
    return _appointments.map((appointment) {
      return DataRow(
        cells: [
          DataCell(Text(_formatDate(appointment.date))),
          DataCell(Text(_formatTime(appointment.time))),
          DataCell(Text(appointment.title)),
          DataCell(Text(appointment.assignedTo)),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navega a la vista de edición de turno con el ID del turno
                    Navigator.pushNamed(context, '/editAppointment', arguments: appointment);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _confirmDelete(appointment);
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  void _confirmDelete(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Turno'),
          content: const Text('¿Estás seguro de que deseas eliminar este turno?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  AppointmentService.deleteAppointment(appointment.id);
                  _loadAppointments();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    // Formato de fecha
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    // Formato de tiempo
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
