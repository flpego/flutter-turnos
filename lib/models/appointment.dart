import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final String title;
  final String details;
  final DateTime date;
  final TimeOfDay time;
  final String assignedTo;

  Appointment({
    required this.id,
    required this.title,
    required this.details,
    required this.date,
    required this.time,
    required this.assignedTo,
  });

  DateTime get normalizedDate => DateTime(date.year, date.month, date.day);
}