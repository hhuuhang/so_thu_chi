import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../database/database_helper.dart';
import '../../models/transaction.dart';

class ReportController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoading = true;
  List<Transaction> _transactions = [];
  double _balance = 0;
  double _income = 0;
  double _expense = 0;
  Map<String, Map<String, double>> _chartData = {};
  Map<String, double> _expenseByCategory = {};
  Map<String, double> _incomeByCategory = {};

  List<Transaction> get transactions => _transactions;
  double get balance => _balance;
  double get income => _income;
  double get expense => _expense;
  Map<String, Map<String, double>> get chartData => _chartData;
  bool get isLoading => _isLoading;
  Map<String, double> get expenseByCategory => _expenseByCategory;
  Map<String, double> get incomeByCategory => _incomeByCategory;

  Future<void> loadTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final transactions = await _getTransactions(
        startDate: startDate,
        endDate: endDate,
      );
      final newIncome = _getIncome(transactions);
      final newExpense = _getExpense(transactions);

      _transactions = transactions;
      _income = newIncome;
      _expense = newExpense;
      _balance = newIncome - newExpense;
      _chartData = _buildChartData(transactions);
      _expenseByCategory = _buildCategoryReport(transactions, 'expense');
      _incomeByCategory = _buildCategoryReport(transactions, 'income');
    } catch (error, stackTrace) {
      debugPrint('ReportController.loadTransactions failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    await loadTransactions();
  }

  Future<List<Transaction>> _getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final allTransactions = await _dbHelper.getTransactions();

    return allTransactions.where((tx) {
      final isAfterStart = startDate == null ||
          tx.date.isAfter(startDate.subtract(const Duration(days: 1)));
      final isBeforeEnd = endDate == null ||
          tx.date.isBefore(endDate.add(const Duration(days: 1)));

      return isAfterStart && isBeforeEnd;
    }).toList();
  }

  double _getIncome(List<Transaction> transactions) => transactions
      .where((tx) => tx.type == 'income')
      .fold(0, (sum, tx) => sum + tx.amount);

  double _getExpense(List<Transaction> transactions) => transactions
      .where((tx) => tx.type == 'expense')
      .fold(0, (sum, tx) => sum + tx.amount);

  Map<String, Map<String, double>> _buildChartData(
    List<Transaction> transactions,
  ) {
    final chartData = <String, Map<String, double>>{};

    for (final tx in transactions) {
      final dateKey = DateFormat('dd/MM/yyyy').format(tx.date);
      chartData.putIfAbsent(
        dateKey,
        () => {'income': 0, 'expense': 0},
      );

      if (tx.type == 'income') {
        chartData[dateKey]!['income'] =
            chartData[dateKey]!['income']! + tx.amount;
      } else {
        chartData[dateKey]!['expense'] =
            chartData[dateKey]!['expense']! + tx.amount;
      }
    }

    return chartData;
  }

  Map<String, double> _buildCategoryReport(
    List<Transaction> transactions,
    String type,
  ) {
    final filteredTransactions = transactions.where((tx) => tx.type == type);
    final categoryTotals = <String, double>{};

    for (final tx in filteredTransactions) {
      categoryTotals.update(
        tx.category,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    return categoryTotals;
  }
}
