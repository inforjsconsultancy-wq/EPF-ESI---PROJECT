import 'package:flutter/material.dart';
import '../models/company.dart';
import '../models/transaction.dart';
import '../services/firebase_service.dart';
import 'transaction_detail_screen.dart';

class TransactionTab extends StatelessWidget {
  final Company company;

  const TransactionTab({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: FirebaseService().getTransactionsByCompany(company.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final transactions = snapshot.data!;
        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add entries from the Entry tab',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final t = transactions[index];
            return _TransactionCard(
              company: company,
              transaction: t,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionDetailScreen(company: company, transaction: t),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Company company;
  final Transaction transaction;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.company,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.monthYearLabel,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _InfoChip(label: 'Total Salary', value: '₹${transaction.totalSalary.toStringAsFixed(2)}'),
                  _InfoChip(label: 'ESI', value: '₹${(transaction.totalEmployeeEsi + transaction.totalEmployerEsi).toStringAsFixed(2)}'),
                  _InfoChip(label: 'PF', value: '₹${(transaction.totalEmployeeEpf + transaction.totalEmployerEpf8_33 + transaction.totalEmployerEpf3_67).toStringAsFixed(2)}'),
                  _InfoChip(label: 'Entries', value: '${transaction.entries.length}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
