import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:turnos/models/holiday_model.dart';


class HolidayService {
  static const String _apiUrl = 'https://api.argentinadatos.com/v1/feriados/2024';

  static Future<List<Holiday>> fetchHolidays() async {
    final response = await http.get(Uri.parse(_apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Holiday.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load holidays');
    }
  }
}
