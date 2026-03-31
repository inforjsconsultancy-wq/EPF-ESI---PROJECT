import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/company.dart';
import '../services/firebase_service.dart';

// Minimal default percentages (only essential EPF/ESI values)
const _defaultPercentOptions = [0.75, 3.25, 3.67, 8.33, 12.0];

class AddCompanyScreen extends StatefulWidget {
  const AddCompanyScreen({super.key});

  @override
  State<AddCompanyScreen> createState() => _AddCompanyScreenState();
}

class _AddCompanyScreenState extends State<AddCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  double _epfEmployee = 12;
  double _esiEmployee = 0.75;
  double _epfEmployer8_33 = 8.33;
  double _epfEmployer3_67 = 3.67;
  double _esiEmployer = 3.25;
  bool _saving = false;
  List<double> _percentOptions = List.from(_defaultPercentOptions);
  StreamSubscription<List<double>>? _percentSub;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _percentSub = FirebaseService().getUserPercentages(userId).listen((firebasePercents) {
        if (mounted) {
          final merged = {..._defaultPercentOptions, ...firebasePercents}.toList()..sort();
          setState(() => _percentOptions = merged);
        }
      });
    }
  }

  @override
  void dispose() {
    _percentSub?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showAddPercentDialog(String label, ValueChanged<double> onSelected) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final controller = TextEditingController();
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $label'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Percentage',
            suffixText: '%',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final val = double.tryParse(controller.text);
              if (val == null || val < 0 || val > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter valid percentage (0-100)')),
                );
                return;
              }
              final rounded = (val * 100).round() / 100;
              final added = await FirebaseService().addUserPercentage(userId, rounded);
              if (!context.mounted) return;
              Navigator.pop(context);
              if (added) {
                onSelected(rounded);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Percentage added')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This percentage already exists')),
                );
                onSelected(rounded); // Still select it
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentDropdown(String label, double value, ValueChanged<double> onChanged) {
    final options = _percentOptions.where((o) => o >= 0 && o <= 100).toSet().toList()..sort();
    if (!options.contains(value)) {
      options.add(value);
      options.sort();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<double>(
              value: options.contains(value) ? value : null, // ignore: deprecated_member_use
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text('${o.toStringAsFixed(2)}%'))).toList(),
              onChanged: (v) => v != null ? onChanged(v) : null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddPercentDialog(label, onChanged),
            tooltip: 'Add custom percentage',
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in again')),
        );
        return;
      }
      final company = Company(
        id: '',
        userId: userId,
        name: _nameController.text.trim(),
        epfEmployeePercent: _epfEmployee,
        esiEmployeePercent: _esiEmployee,
        epfEmployer8_33Percent: _epfEmployer8_33,
        epfEmployer3_67Percent: _epfEmployer3_67,
        esiEmployerPercent: _esiEmployer,
      );
      await FirebaseService().addCompany(company);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Company'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              const Text('Employee Contributions', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildPercentDropdown('EPF %', _epfEmployee, (v) => setState(() => _epfEmployee = v)),
              _buildPercentDropdown('ESI %', _esiEmployee, (v) => setState(() => _esiEmployee = v)),
              const SizedBox(height: 24),
              const Text('Employer Contributions', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildPercentDropdown('EPF 8.33%', _epfEmployer8_33, (v) => setState(() => _epfEmployer8_33 = v)),
              _buildPercentDropdown('EPF 3.67%', _epfEmployer3_67, (v) => setState(() => _epfEmployer3_67 = v)),
              _buildPercentDropdown('ESI %', _esiEmployer, (v) => setState(() => _esiEmployer = v)),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add Company'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
