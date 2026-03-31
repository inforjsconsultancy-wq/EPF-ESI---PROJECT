import 'transaction_entry.dart';

class Transaction {
  final String id;
  final String companyId;
  final int month;
  final int year;
  final List<TransactionEntry> entries;

  Transaction({
    required this.id,
    required this.companyId,
    required this.month,
    required this.year,
    required this.entries,
  });

  String get monthYearLabel {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month - 1]} $year';
  }

  double get totalSalary => entries.fold(0, (sum, e) => sum + e.totalSalary);
  double get totalEmployeeEpf => entries.fold(0, (sum, e) => sum + e.employeeEpf);
  double get totalEmployeeEsi => entries.fold(0, (sum, e) => sum + e.employeeEsi);
  double get totalEmployerEpf8_33 => entries.fold(0, (sum, e) => sum + e.employerEpf8_33);
  double get totalEmployerEpf3_67 => entries.fold(0, (sum, e) => sum + e.employerEpf3_67);
  double get totalEmployerEsi => entries.fold(0, (sum, e) => sum + e.employerEsi);
  double get totalGrossSalary => entries.fold(0, (sum, e) => sum + e.grossSalary);

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'month': month,
      'year': year,
    };
  }

  factory Transaction.fromMap(String id, Map<String, dynamic> map, {List<TransactionEntry> entries = const []}) {
    return Transaction(
      id: id,
      companyId: map['companyId'] ?? '',
      month: map['month'] ?? 1,
      year: map['year'] ?? DateTime.now().year,
      entries: entries,
    );
  }
}
