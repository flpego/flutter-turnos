import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:turnos/models/appointment.dart';
import 'package:turnos/services/appointment_service.dart';
import 'package:turnos/services/holiday_service.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Appointment>> _appointments = {};
  Set<DateTime> _holidays = {};
  bool _loadingHolidays = false;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _loadHolidays();
  }

  void _loadAppointments() {
    setState(() {
      _appointments = AppointmentService.getAppointments().map((key, value) =>
          MapEntry(DateTime(key.year, key.month, key.day), value));
    });
  }

  Future<void> _loadHolidays() async {
    setState(() {
      _loadingHolidays = true;
    });
    try {
      final holidays = await HolidayService.fetchHolidays();
      setState(() {
        _holidays = holidays.map((holiday) => DateTime(holiday.date.year, holiday.date.month, holiday.date.day)).toSet();
        _loadingHolidays = false;
      });
    } catch (e) {
      setState(() {
        _loadingHolidays = false;
      });
    }
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    return _appointments[DateTime(day.year, day.month, day.day)] ?? [];
  }
  //mostrar turnos del dia x
  void _showAppointmentsDialog(DateTime date, List<Appointment> appointments) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Turnos del ${date.day}/${date.month}/${date.year}"),
          shadowColor: Colors.red,
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return ListTile(
                  title: Text(appointment.title),
                  subtitle: Text(
                      "${appointment.details}\nHora: ${appointment.time.format(context)}\nAsignado a: ${appointment.assignedTo}"),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showHolidaysDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Feriados de 2024'),
          content: _loadingHolidays
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: _holidays.map((holiday) {
                      return ListTile(
                        title: Text('Feriado: ${holiday.day}/${holiday.month}/${holiday.year}'),
                      );
                    }).toList(),
                  ),
                ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Turnos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/addAppointment').then((_) {
                _loadAppointments(); // Actualiza los eventos después de añadir una cita
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/table');
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              _showHolidaysDialog();
            },
          ),
        ],
      ),
      body: TableCalendar<Appointment>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          final appointments = _getEventsForDay(selectedDay);
          if (appointments.isNotEmpty) {
            _showAppointmentsDialog(selectedDay, appointments);
          }
        },
        //funcio para cmbiar el formato
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 1.5,
                bottom: 1.5,
                child: _buildEventsMarker(events.length),
              );
            }
            if (_holidays.contains(DateTime(date.year, date.month, date.day))) {
              return Positioned(
                right: 1,
                bottom: 1,
                child: _buildHolidayMarker(),
              );
            }
            return const SizedBox();
          },
        ),
        calendarStyle: CalendarStyle(
          weekendDecoration: BoxDecoration(
              color: const Color.fromARGB(255, 238, 131, 130),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10)),
          todayDecoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5.0)),
          selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5.0)),
        ),
        eventLoader: _getEventsForDay,
      ),
    );
  }

  Widget _buildEventsMarker(int count) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 58, 243, 33),
      ),
      width: 20.0,
      height: 20.0,
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidayMarker() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 255, 144, 136),
      ),
      width: 16.0,
      height: 16.0,
      child: const Center(
        child: Icon(
          Icons.home_filled,
          color: Colors.white,
          size: 12.0,
        ),
      ),
    );
  }
}
