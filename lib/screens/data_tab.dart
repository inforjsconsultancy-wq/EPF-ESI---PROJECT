import 'package:flutter/material.dart';
import '../models/company.dart';
import '../models/employee.dart';
import '../services/firebase_service.dart';
import 'add_employee_dialog.dart';

class DataTab extends StatelessWidget {
  final Company company;

  const DataTab({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Employees & Salary',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              FilledButton.icon(
                onPressed: () => _showAddEmployee(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Employee'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Employee>>(
            stream: FirebaseService().getEmployeesByCompany(company.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final employees = snapshot.data!;
              if (employees.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No employees yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => _showAddEmployee(context),
                        child: const Text('Add your first employee'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final emp = employees[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(emp.name),
                      subtitle: Text('UAN: ${emp.uan} | IP: ${emp.ipNumber}'),
                      trailing: Text(
                        '₹${emp.salaryPerDay.toStringAsFixed(2)}/day',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddEmployee(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddEmployeeDialog(company: company),
    );
  }
}
