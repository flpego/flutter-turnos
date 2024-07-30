import 'package:flutter/material.dart';
import 'package:turnos/models/appointment.dart';
import 'package:turnos/services/appointment_service.dart';

class EditAppointmentView extends StatefulWidget {
  final Appointment appointment;

  const EditAppointmentView({super.key, required this.appointment});

  @override
  // ignore: library_private_types_in_public_api
  _EditAppointmentViewState createState() => _EditAppointmentViewState();
}

class _EditAppointmentViewState extends State<EditAppointmentView> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _details;
  late DateTime _date;
  late TimeOfDay _time;
  late String _assignedTo;

  @override
  void initState() {
    super.initState();
    _title = widget.appointment.title;
    _details = widget.appointment.details;
    _date = widget.appointment.date;
    _time = widget.appointment.time;
    _assignedTo = widget.appointment.assignedTo;
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Actualizar el turno con los nuevos datos
      AppointmentService.updateAppointment(
        widget.appointment.id,
        _title,
        _details,
        _date,
        _time,
        _assignedTo,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Turno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un título';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _details,
                decoration: const InputDecoration(labelText: 'Detalles'),
                onSaved: (value) => _details = value!,
              ),
              ListTile(
                title: Text("Fecha: ${_date.day}/${_date.month}/${_date.year}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text("Hora: ${_time.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              TextFormField(
                initialValue: _assignedTo,
                decoration: const InputDecoration(labelText: 'Asignado a'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
                onSaved: (value) => _assignedTo = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
