
class Holiday {
  final DateTime date;
  final String type;
  final String name;

  Holiday({
    required this.date,
    required this.type,
    required this.name,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      date: DateTime.parse(json['fecha']),
      type: json['tipo'],
      name: json['nombre'],
    );
  }
}
