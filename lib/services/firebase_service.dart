import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company.dart';
import '../models/employee.dart';
import '../models/transaction.dart' as models;
import '../models/transaction_entry.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ COMPANIES ============
  CollectionReference<Map<String, dynamic>> get _companies => _firestore.collection('companies');

  Stream<List<Company>> getCompanies(String userId) {
    return _companies
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Company.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<String> addCompany(Company company) async {
    final doc = await _companies.add(company.toMap());
    return doc.id;
  }

  Future<Company?> getCompany(String id) async {
    final doc = await _companies.doc(id).get();
    if (doc.exists) {
      return Company.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  // ============ EMPLOYEES ============
  CollectionReference<Map<String, dynamic>> get _employees => _firestore.collection('employees');

  Stream<List<Employee>> getEmployeesByCompany(String companyId) {
    return _employees
        .where('companyId', isEqualTo: companyId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Employee.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<String> addEmployee(Employee employee) async {
    final doc = await _employees.add(employee.toMap());
    return doc.id;
  }

  Future<Employee?> getEmployee(String id) async {
    final doc = await _employees.doc(id).get();
    if (doc.exists) {
      return Employee.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  // ============ TRANSACTIONS ============
  CollectionReference<Map<String, dynamic>> get _transactions => _firestore.collection('transactions');

  CollectionReference<Map<String, dynamic>> _entries(String transactionId) =>
      _transactions.doc(transactionId).collection('entries');

  Stream<List<models.Transaction>> getTransactionsByCompany(String companyId) {
    return _transactions
        .where('companyId', isEqualTo: companyId)
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .snapshots()
        .asyncMap<List<models.Transaction>>((snapshot) async {
      final transactions = <models.Transaction>[];
      for (final doc in snapshot.docs) {
        final entriesSnapshot = await _entries(doc.id).orderBy('employeeName').get();
        final entries = entriesSnapshot.docs
            .map((e) => TransactionEntry.fromMap(e.id, e.data()))
            .toList();
        transactions.add(models.Transaction.fromMap(doc.id, doc.data(), entries: entries));
      }
      return transactions;
    });
  }

  Future<models.Transaction?> getTransactionWithEntries(String transactionId) async {
    final doc = await _transactions.doc(transactionId).get();
    if (!doc.exists) return null;

    final entriesSnapshot = await _entries(transactionId).orderBy('employeeName').get();
    final entries = entriesSnapshot.docs
        .map((e) => TransactionEntry.fromMap(e.id, e.data()))
        .toList();

    return models.Transaction.fromMap(doc.id, doc.data()!, entries: entries);
  }

  Future<String> getOrCreateTransaction(String companyId, int month, int year) async {
    final existing = await _transactions
        .where('companyId', isEqualTo: companyId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final doc = await _transactions.add({
      'companyId': companyId,
      'month': month,
      'year': year,
    });
    return doc.id;
  }

  Future<void> addTransactionEntry(TransactionEntry entry) async {
    await _entries(entry.transactionId).add(entry.toMap());
  }

  // ============ USER PERCENTAGES (per-user, stored in Firebase) ============
  CollectionReference<Map<String, dynamic>> get _userPercentages =>
      _firestore.collection('user_percentages');

  Stream<List<double>> getUserPercentages(String userId) {
    return _userPercentages
        .where('userId', isEqualTo: userId)
        .orderBy('value')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => (d.data()['value'] as num).toDouble()).toList());
  }

  /// Adds a percentage for the user. Returns false if already exists.
  Future<bool> addUserPercentage(String userId, double value) async {
    final rounded = (value * 100).round() / 100;
    final docId = '${userId}_${rounded.toStringAsFixed(2)}';
    final doc = await _userPercentages.doc(docId).get();
    if (doc.exists) return false; // Already exists
    await _userPercentages.doc(docId).set({'userId': userId, 'value': rounded});
    return true;
  }
}
