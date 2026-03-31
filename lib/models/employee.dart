class Employee {
  final String id;
  final String companyId;
  final String name;
  final String uan;
  final String ipNumber;
  final double salaryPerDay;

  Employee({
    required this.id,
    required this.companyId,
    required this.name,
    required this.uan,
    required this.ipNumber,
    required this.salaryPerDay,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'name': name,
      'uan': uan,
      'ipNumber': ipNumber,
      'salaryPerDay': salaryPerDay,
    };
  }

  factory Employee.fromMap(String id, Map<String, dynamic> map) {
    return Employee(
      id: id,
      companyId: map['companyId'] ?? '',
      name: map['name'] ?? '',
      uan: map['uan'] ?? '',
      ipNumber: map['ipNumber'] ?? '',
      salaryPerDay: (map['salaryPerDay'] ?? 0).toDouble(),
    );
  }
}
