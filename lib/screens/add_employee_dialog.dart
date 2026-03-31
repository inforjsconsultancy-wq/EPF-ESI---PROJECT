import 'package:flutter/material.dart';
import '../models/company.dart';
import '../models/employee.dart';
import '../services/firebase_service.dart';

class AddEmployeeDialog extends StatefulWidget {
  final Company company;

  const AddEmployeeDialog({super.key, required this.company});

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _uanController = TextEditingController();
  final _ipController = TextEditingController();
  final _salaryController = TextEditingController(text: '0');
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _uanController.dispose();
    _ipController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final salary = double.tryParse(_salaryController.text) ?? 0;
      final employee = Employee(
        id: '',
        companyId: widget.company.id,
        name: _nameController.text.trim(),
        uan: _uanController.text.trim(),
        ipNumber: _ipController.text.trim(),
        salaryPerDay: salary,
      );
      await FirebaseService().addEmployee(employee);
      if (mounted) Navigator.pop(context);
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
    return AlertDialog(
      title: const Text('Add Employee'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _uanController,
                decoration: const InputDecoration(labelText: 'UAN', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(labelText: 'IP Number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: 'Salary Per Day (₹)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Invalid';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add'),
        ),
      ],
    );
  }
}
