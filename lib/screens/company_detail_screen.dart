import 'package:flutter/material.dart';
import '../models/company.dart';
import 'data_tab.dart';
import 'entry_tab.dart';
import 'transaction_tab.dart';

class CompanyDetailScreen extends StatefulWidget {
  final Company company;

  const CompanyDetailScreen({super.key, required this.company});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.company.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Data', icon: Icon(Icons.people)),
            Tab(text: 'Transaction', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Entry', icon: Icon(Icons.edit_note)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DataTab(company: widget.company),
          TransactionTab(company: widget.company),
          EntryTab(company: widget.company),
        ],
      ),
    );
  }
}
