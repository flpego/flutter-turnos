import 'package:flutter/material.dart';
import 'package:turnos/services/appointment_service.dart';
import 'package:turnos/services/holiday_service.dart';

class AddAppointmentView extends StatefulWidget {
  const AddAppointmentView({super.key});

  @override
  _AddAppointmentViewState createState() => _AddAppointmentViewState();
}

class _AddAppointmentViewState extends State<AddAppointmentView> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _details;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  late String _assignedTo;
  bool _isHoliday = false;

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple, // Cambia este color según tu tema
              onPrimary: Colors.white, // Color del texto en la barra superior
              onSurface: Colors.black, // Color de los textos de los días
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple, // Botones de acción
              ),
            ),
            textTheme: const TextTheme(
              headlineMedium:
                  TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              titleMedium: TextStyle(fontSize: 18.0),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        _checkIfHoliday(_date);
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

  void _checkIfHoliday(DateTime date) async {
    final holidays = await HolidayService.fetchHolidays();
    setState(() {
      _isHoliday = holidays.any((holiday) =>
          holiday.date.year == date.year &&
          holiday.date.month == date.month &&
          holiday.date.day == date.day);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      AppointmentService.addAppointment(
        _title,
        _details,
        _date,
        _time,
        _assignedTo,
      );

      Navigator.pop(context); // Regresar a la pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Nuevo Turno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
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
                decoration: const InputDecoration(labelText: 'Detalles'),
                onSaved: (value) => _details = value!,
              ),
              ListTile(
                title: Text("Fecha: ${_date.day}/${_date.month}/${_date.year}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              if (_isHoliday)
                const Text(
                  'Recuerde que este día es feriado',
                  style: TextStyle(color: Colors.red),
                ),
              ListTile(
                title: Text("Hora: ${_time.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              TextFormField(
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
                child: const Text('Guardar Turno'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
