import 'package:flutter/material.dart';
import '../models/company.dart';
import '../models/transaction.dart';
import '../services/excel_service.dart';
import '../services/firebase_service.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Company company;
  final Transaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.company,
    required this.transaction,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  Transaction? _transaction;
  bool _loading = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    final t = await FirebaseService().getTransactionWithEntries(widget.transaction.id);
    if (mounted) {
      setState(() {
        _transaction = t;
        _loading = false;
      });
    }
  }

  Future<void> _exportExcel() async {
    if (_transaction == null || _transaction!.entries.isEmpty) return;
    setState(() => _exporting = true);
    try {
      await ExcelService().exportTransactionToExcel(widget.company, _transaction!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_transaction?.monthYearLabel ?? widget.transaction.monthYearLabel),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _exporting || _transaction == null || _transaction!.entries.isEmpty
                ? null
                : _exportExcel,
            icon: _exporting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download),
            tooltip: 'Export Excel',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _transaction == null || _transaction!.entries.isEmpty
              ? const Center(child: Text('No entries'))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.company.name.toUpperCase()}, ${_transaction!.monthYearLabel} - EPF, ESI',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildTable(),
                          const SizedBox(height: 16),
                          _buildSummary(),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildTable() {
    final t = _transaction!;
    return Table(
      border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(0.5),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(0.8),
        6: FlexColumnWidth(1),
        7: FlexColumnWidth(1),
        8: FlexColumnWidth(1),
        9: FlexColumnWidth(1),
        10: FlexColumnWidth(1),
        11: FlexColumnWidth(1),
        12: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: [
            _header('S NO'),
            _header('UAN'),
            _header('IP NUMBER'),
            _header('NAME'),
            _header('Salary/Day'),
            _header('DAYS'),
            _header('TOTAL SALARY'),
            _header('EPF 12%'),
            _header('ESI 0.75%'),
            _header('EPF 8.33%'),
            _header('EPF 3.67%'),
            _header('ESI 3.25%'),
            _header('Gross Salary'),
          ],
        ),
        ...t.entries.asMap().entries.map((e) {
          final i = e.key;
          final entry = e.value;
          return TableRow(
            children: [
              _cell('${i + 1}'),
              _cell(entry.uan),
              _cell(entry.ipNumber),
              _cell(entry.employeeName),
              _cell(entry.salaryPerDay.toStringAsFixed(2)),
              _cell('${entry.noOfDays}'),
              _cell(entry.totalSalary.toStringAsFixed(2)),
              _cell(entry.employeeEpf.toStringAsFixed(2)),
              _cell(entry.employeeEsi.toStringAsFixed(2)),
              _cell(entry.employerEpf8_33.toStringAsFixed(2)),
              _cell(entry.employerEpf3_67.toStringAsFixed(2)),
              _cell(entry.employerEsi.toStringAsFixed(2)),
              _cell(entry.grossSalary.toStringAsFixed(2)),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSummary() {
    final t = _transaction!;
    final totalSalaryPerDay = t.entries.fold<double>(0, (s, e) => s + e.salaryPerDay);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _summaryRow('Salary Per Day Total', totalSalaryPerDay.toStringAsFixed(2)),
            _summaryRow('Total Salary', t.totalSalary.toStringAsFixed(2)),
            _summaryRow('Employee EPF (12%)', t.totalEmployeeEpf.toStringAsFixed(2)),
            _summaryRow('Employee ESI (0.75%)', t.totalEmployeeEsi.toStringAsFixed(2)),
            _summaryRow('Employer EPF (8.33%)', t.totalEmployerEpf8_33.toStringAsFixed(2)),
            _summaryRow('Employer EPF (3.67%)', t.totalEmployerEpf3_67.toStringAsFixed(2)),
            _summaryRow('Employer ESI (3.25%)', t.totalEmployerEsi.toStringAsFixed(2)),
            _summaryRow('Gross Salary', t.totalGrossSalary.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _cell(String text) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text),
      );

  Widget _summaryRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text('₹$value')],
        ),
      );
}
