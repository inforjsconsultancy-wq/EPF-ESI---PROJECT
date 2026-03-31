import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/company.dart';
import '../models/transaction.dart';

extension _Round on double {
  /// Rounds to nearest whole number: 38.45 → 38.00, 38.65 → 39.00
  double get rounded => roundToDouble();
}

class ExcelService {
  Future<String> exportTransactionToExcel(
    Company company,
    Transaction transaction,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['EPF ESI'];

    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final monthYear = '${months[transaction.month - 1]} ${transaction.year}';

    // Header: "MRP ENTERPRISES, January 2026 - EPF, ESI"
    excel.merge(
      'EPF ESI',
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('L1'),
    );
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
      '${company.name.toUpperCase()}, $monthYear - EPF, ESI',
    );

    // Column headers
    final headers = [
      'S NO',
      'UAN',
      'IP NUMBER',
      'NAME',
      'Salary Per Day',
      'NO. OF DAYS',
      'TOTAL SALARY',
      'EPF - 12%',
      'ESI - 0.75%',
      'EPF - 8.33%',
      'EPF - 3.67%',
      'ESI - 3.25%',
      'Gross Salary',
    ];

    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2)).value =
          TextCellValue(headers[i]);
    }

    // Data rows - round all numeric values
    for (var i = 0; i < transaction.entries.length; i++) {
      final e = transaction.entries[i];
      final row = i + 3;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          TextCellValue(e.uan);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
          TextCellValue(e.ipNumber);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value =
          TextCellValue(e.employeeName);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value =
          DoubleCellValue(e.salaryPerDay.rounded);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value =
          IntCellValue(e.noOfDays);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value =
          DoubleCellValue(e.totalSalary.rounded);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value =
          DoubleCellValue(e.employeeEpf.rounded);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value =
          DoubleCellValue(e.employeeEsi.rounded);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row)).value =
          DoubleCellValue(e.employerEpf8_33.rounded);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row)).value =
          DoubleCellValue(e.employerEpf3_67.rounded);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: row)).value =
          DoubleCellValue(e.employerEsi.rounded);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: row)).value =
          DoubleCellValue(e.grossSalary.rounded);
    }

    // Total row at bottom - sum of ROUNDED individual values (not sum then round)
    final totalRow = transaction.entries.length + 3;
    final totalSalaryPerDay = transaction.entries.fold<double>(
        0, (sum, e) => sum + e.salaryPerDay.rounded);
    final totalSalary = transaction.entries.fold<double>(
        0, (sum, e) => sum + e.totalSalary.rounded);
    final totalEmployeeEpf = transaction.entries.fold<double>(
        0, (sum, e) => sum + e.employeeEpf.rounded);
    final totalEmployeeEsi = transaction.entries.fold<double>(
        0, (sum, e) => sum + e.employeeEsi.rounded);
    final totalEmployerEpf8_33 = transaction.entries.fold<double>(
        0, (sum, e) => sum + e.employerEpf8_33.rounded);
    final totalEmployerEpf3_67 = transaction.entries.fold<double>(
        0, (sum, e) => sum + e.employerEpf3_67.rounded);
    final totalEmployerEsi = transaction.entries.fold<double>(
        0, (sum, e) => sum + e.employerEsi.rounded);
    final totalGrossSalary = transaction.entries.fold<double>(
        0, (sum, e) => sum + e.grossSalary.rounded);

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: totalRow))
        .value = TextCellValue('TOTAL');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: totalRow))
        .value = DoubleCellValue(totalSalaryPerDay);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: totalRow))
        .value = DoubleCellValue(totalSalary);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: totalRow))
        .value = DoubleCellValue(totalEmployeeEpf);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: totalRow))
        .value = DoubleCellValue(totalEmployeeEsi);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: totalRow))
        .value = DoubleCellValue(totalEmployerEpf8_33);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: totalRow))
        .value = DoubleCellValue(totalEmployerEpf3_67);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: totalRow))
        .value = DoubleCellValue(totalEmployerEsi);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: totalRow))
        .value = DoubleCellValue(totalGrossSalary);

    // Save and share
    final dir = await getTemporaryDirectory();
    final safeName = company.name.replaceAll(RegExp(r'[^\w\-]'), '_');
    final filePath = '${dir.path}/${safeName}_$monthYear.xlsx';
    final file = File(filePath);
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(filePath)], text: 'EPF ESI Report - $monthYear');
    return filePath;
  }
}
