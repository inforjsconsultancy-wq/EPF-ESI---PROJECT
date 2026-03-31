import 'dart:async';
import 'package:flutter/material.dart';
import '../models/company.dart';
import '../models/employee.dart';
import '../models/transaction_entry.dart';
import '../services/firebase_service.dart';

class EntryTab extends StatefulWidget {
  final Company company;

  const EntryTab({super.key, required this.company});

  @override
  State<EntryTab> createState() => _EntryTabState();
}

class _EntryTabState extends State<EntryTab> {
  final _formKey = GlobalKey<FormState>();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _saving = false;
  List<Employee> _employees = [];
  final Map<String, TextEditingController> _daysControllers = {};
  StreamSubscription<List<Employee>>? _empSubscription;

  @override
  void initState() {
    super.initState();
    _empSubscription = FirebaseService().getEmployeesByCompany(widget.company.id).listen((employees) {
      if (mounted) {
        final prevControllers = Map<String, TextEditingController>.from(_daysControllers);
        _daysControllers.clear();
        for (final emp in employees) {
          _daysControllers[emp.id] = prevControllers[emp.id] ?? TextEditingController();
        }
        for (final empId in prevControllers.keys) {
          if (!_daysControllers.containsKey(empId)) {
            prevControllers[empId]?.dispose();
          }
        }
        setState(() => _employees = employees);
      }
    });
  }

  @override
  void dispose() {
    _empSubscription?.cancel();
    for (final c in _daysControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add employees in the Data tab first')),
      );
      return;
    }

    // Validate all employees have days
    final missing = <String>[];
    final entries = <({Employee emp, int days})>[];
    for (final emp in _employees) {
      final text = (_daysControllers[emp.id]?.text ?? '').trim();
      final days = int.tryParse(text);
      if (days == null || days < 0 || days > 31) {
        missing.add(emp.name);
      } else if (days > 0) {
        entries.add((emp: emp, days: days));
      }
    }

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter valid days (0-31) for: ${missing.join(", ")}')),
      );
      return;
    }

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter working days for at least one employee')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final transactionId = await FirebaseService().getOrCreateTransaction(
        widget.company.id,
        _selectedMonth,
        _selectedYear,
      );

      for (final e in entries) {
        final totalSalary = e.emp.salaryPerDay * e.days;
        final employeeEpf = totalSalary * (widget.company.epfEmployeePercent / 100);
        final employeeEsi = totalSalary * (widget.company.esiEmployeePercent / 100);
        final employerEpf8_33 = totalSalary * (widget.company.epfEmployer8_33Percent / 100);
        final employerEpf3_67 = totalSalary * (widget.company.epfEmployer3_67Percent / 100);
        final employerEsi = totalSalary * (widget.company.esiEmployerPercent / 100);
        final grossSalary = totalSalary - employeeEpf - employeeEsi;

        final entry = TransactionEntry(
          id: '',
          transactionId: transactionId,
          employeeId: e.emp.id,
          employeeName: e.emp.name,
          uan: e.emp.uan,
          ipNumber: e.emp.ipNumber,
          salaryPerDay: e.emp.salaryPerDay,
          noOfDays: e.days,
          totalSalary: totalSalary,
          employeeEpf: employeeEpf,
          employeeEsi: employeeEsi,
          employerEpf8_33: employerEpf8_33,
          employerEpf3_67: employerEpf3_67,
          employerEsi: employerEsi,
          grossSalary: grossSalary,
        );

        await FirebaseService().addTransactionEntry(entry);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${entries.length} entries added successfully')),
        );
        for (final c in _daysControllers.values) {
          c.clear();
        }
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Month', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth, // ignore: deprecated_member_use
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: List.generate(12, (i) => i + 1).map((m) {
                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                      return DropdownMenuItem(value: m, child: Text(months[m - 1]));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedMonth = v ?? _selectedMonth),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear, // ignore: deprecated_member_use
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: List.generate(5, (i) => DateTime.now().year - 2 + i).map((y) {
                      return DropdownMenuItem(value: y, child: Text('$y'));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedYear = v ?? _selectedYear),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Employees - Working Days', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Enter days worked for each employee (0 if not worked). All employees must have a value.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            if (_employees.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Add employees in the Data tab first', style: TextStyle(color: Colors.orange[700])),
              )
            else
              ..._employees.map((emp) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(emp.name, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: _daysControllers[emp.id],
                        decoration: const InputDecoration(
                          labelText: 'Days',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final text = v?.trim() ?? '';
                          if (text.isEmpty) return 'Required';
                          final d = int.tryParse(text);
                          if (d == null || d < 0 || d > 31) return '0-31';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              )),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving || _employees.isEmpty ? null : _submit,
              child: _saving
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Submit All'),
            ),
          ],
        ),
      ),
    );
  }
}
