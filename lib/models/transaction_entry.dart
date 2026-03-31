class TransactionEntry {
  final String id;
  final String transactionId;
  final String employeeId;
  final String employeeName;
  final String uan;
  final String ipNumber;
  final double salaryPerDay;
  final int noOfDays;
  final double totalSalary;
  final double employeeEpf;
  final double employeeEsi;
  final double employerEpf8_33;
  final double employerEpf3_67;
  final double employerEsi;
  final double grossSalary;

  TransactionEntry({
    required this.id,
    required this.transactionId,
    required this.employeeId,
    required this.employeeName,
    required this.uan,
    required this.ipNumber,
    required this.salaryPerDay,
    required this.noOfDays,
    required this.totalSalary,
    required this.employeeEpf,
    required this.employeeEsi,
    required this.employerEpf8_33,
    required this.employerEpf3_67,
    required this.employerEsi,
    required this.grossSalary,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'uan': uan,
      'ipNumber': ipNumber,
      'salaryPerDay': salaryPerDay,
      'noOfDays': noOfDays,
      'totalSalary': totalSalary,
      'employeeEpf': employeeEpf,
      'employeeEsi': employeeEsi,
      'employerEpf8_33': employerEpf8_33,
      'employerEpf3_67': employerEpf3_67,
      'employerEsi': employerEsi,
      'grossSalary': grossSalary,
    };
  }

  factory TransactionEntry.fromMap(String id, Map<String, dynamic> map) {
    return TransactionEntry(
      id: id,
      transactionId: map['transactionId'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      uan: map['uan'] ?? '',
      ipNumber: map['ipNumber'] ?? '',
      salaryPerDay: (map['salaryPerDay'] ?? 0).toDouble(),
      noOfDays: map['noOfDays'] ?? 0,
      totalSalary: (map['totalSalary'] ?? 0).toDouble(),
      employeeEpf: (map['employeeEpf'] ?? 0).toDouble(),
      employeeEsi: (map['employeeEsi'] ?? 0).toDouble(),
      employerEpf8_33: (map['employerEpf8_33'] ?? 0).toDouble(),
      employerEpf3_67: (map['employerEpf3_67'] ?? 0).toDouble(),
      employerEsi: (map['employerEsi'] ?? 0).toDouble(),
      grossSalary: (map['grossSalary'] ?? 0).toDouble(),
    );
  }
}
