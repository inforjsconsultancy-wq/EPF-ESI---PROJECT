class Company {
  final String id;
  final String userId;
  final String name;
  final double epfEmployeePercent;
  final double esiEmployeePercent;
  final double epfEmployer8_33Percent;
  final double epfEmployer3_67Percent;
  final double esiEmployerPercent;

  Company({
    required this.id,
    required this.userId,
    required this.name,
    required this.epfEmployeePercent,
    required this.esiEmployeePercent,
    required this.epfEmployer8_33Percent,
    required this.epfEmployer3_67Percent,
    required this.esiEmployerPercent,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'epfEmployeePercent': epfEmployeePercent,
      'esiEmployeePercent': esiEmployeePercent,
      'epfEmployer8_33Percent': epfEmployer8_33Percent,
      'epfEmployer3_67Percent': epfEmployer3_67Percent,
      'esiEmployerPercent': esiEmployerPercent,
    };
  }

  factory Company.fromMap(String id, Map<String, dynamic> map) {
    return Company(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      epfEmployeePercent: (map['epfEmployeePercent'] ?? 12).toDouble(),
      esiEmployeePercent: (map['esiEmployeePercent'] ?? 0.75).toDouble(),
      epfEmployer8_33Percent: (map['epfEmployer8_33Percent'] ?? 8.33).toDouble(),
      epfEmployer3_67Percent: (map['epfEmployer3_67Percent'] ?? 3.67).toDouble(),
      esiEmployerPercent: (map['esiEmployerPercent'] ?? 3.25).toDouble(),
    );
  }
}
