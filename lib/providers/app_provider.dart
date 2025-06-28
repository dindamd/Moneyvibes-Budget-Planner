import 'package:flutter/material.dart';
import 'package:moneyvibes/core/services/database_helper.dart';
import 'package:moneyvibes/models/transaction.dart';
import 'package:moneyvibes/models/budget.dart';

class AppProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  Budget? _currentBudget;

  List<Transaction> get transactions => _transactions;
  Budget? get currentBudget => _currentBudget;

  Future<void> loadData() async {
    _transactions = await DatabaseHelper.instance.getTransactions();
    _currentBudget = await DatabaseHelper.instance.getBudget();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    await loadData();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await DatabaseHelper.instance.updateTransaction(transaction);
    await loadData();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await loadData();
  }

  Future<void> addBudget(Budget budget) async {
    await DatabaseHelper.instance.insertBudget(budget);
    await loadData();
  }

  Future<void> updateBudget(Budget budget) async {
    await DatabaseHelper.instance.updateBudget(budget);
    await loadData();
  }

  Future<void> deleteBudget(int id) async {
    await DatabaseHelper.instance.deleteBudget(id);
    await loadData();
  }

  Future<void> resetAllData() async {
    await DatabaseHelper.instance.resetAllData();
    await loadData();
  }
}