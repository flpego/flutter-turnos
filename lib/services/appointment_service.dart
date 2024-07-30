import 'package:turnos/models/appointment.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AppointmentService {
  static final Map<DateTime, List<Appointment>> _appointments = {};
  static const Uuid _uuid = Uuid();

  static Map<DateTime, List<Appointment>> getAppointments() {
    return _appointments;
  }

  static List<Appointment> getAppointmentsForDay(DateTime date) {
    return _appointments[date] ?? [];
  }

  static void addAppointment(String title, String details, DateTime date, TimeOfDay time, String assignedTo) {
    final newAppointment = Appointment(
      id: _uuid.v4(),
      title: title,
      details: details,
      date: date,
      time: time,
      assignedTo: assignedTo,
    );

    if (_appointments[date] == null) {
      _appointments[date] = [];
    }

    _appointments[date]!.add(newAppointment);
  }

  static void updateAppointment(String id, String title, String details, DateTime date, TimeOfDay time, String assignedTo) {
    for (var appointmentList in _appointments.values) {
      final index = appointmentList.indexWhere((appointment) => appointment.id == id);
      if (index != -1) {
        appointmentList[index] = Appointment(
          id: id,
          title: title,
          details: details,
          date: date,
          time: time,
          assignedTo: assignedTo,
        );
        break;
      }
    }
  }

  static void deleteAppointment(String id) {
    _appointments.removeWhere((date, appointments) {
      appointments.removeWhere((appointment) => appointment.id == id);
      return appointments.isEmpty;
    });
  }
}
