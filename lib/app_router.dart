import 'package:flutter/material.dart';
import 'package:turnos/models/appointment.dart';
import 'package:turnos/views/calendar_view.dart';
import 'package:turnos/views/appointment_table.dart';
import 'package:turnos/views/edit_appointment_view.dart';
import 'package:turnos/views/add_appointment_view.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const CalendarView());
      case '/table':
        return MaterialPageRoute(builder: (_) => const AppointmentTable());
      case '/editAppointment':
        final args = settings.arguments as Appointment;
        return MaterialPageRoute(
          builder: (_) => EditAppointmentView(appointment: args),
        );
      case '/addAppointment':
        return MaterialPageRoute(builder: (_) => const AddAppointmentView());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
