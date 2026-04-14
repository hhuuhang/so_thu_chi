import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../database/database_helper.dart';
import '../../models/transaction.dart';

enum ReportRangeMode { monthly, yearly }

enum ReportCategoryType { expense, income }

class CategoryBreakdown {
  const CategoryBreakdown({
    required this.name,
    required this.type,
    required this.amount,
    required this.percentage,
    required this.transactions,
  });

  final String name;
  final String type;
  final double amount;
  final double percentage;
  final List<Transaction> transactions;
}

class ReportController extends ChangeNotifier {
  ReportController({
    Future<List<Transaction>> Function()? transactionLoader,
    Future<int> Function(int id)? deleteTransactionHandler,
    DateTime? initialDate,
  })  : _transactionLoader = transactionLoader,
        _deleteTransactionHandler = deleteTransactionHandler,
        _focusedDate = initialDate ?? DateTime.now();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Future<List<Transaction>> Function()? _transactionLoader;
  final Future<int> Function(int id)? _deleteTransactionHandler;

  bool _isLoading = true;
  DateTime _focusedDate;
  ReportRangeMode _rangeMode = ReportRangeMode.monthly;
  ReportCategoryType _activeType = ReportCategoryType.expense;
  String _searchQuery = '';

  List<Transaction> _transactions = <Transaction>[];
  List<CategoryBreakdown> _expenseBreakdown = <CategoryBreakdown>[];
  List<CategoryBreakdown> _incomeBreakdown = <CategoryBreakdown>[];
  double _balance = 0;
  double _income = 0;
  double _expense = 0;

  bool get isLoading => _isLoading;
  DateTime get focusedDate => _focusedDate;
  ReportRangeMode get rangeMode => _rangeMode;
  ReportCategoryType get activeType => _activeType;
  String get searchQuery => _searchQuery;
  List<Transaction> get transactions => _transactions;
  double get balance => _balance;
  double get income => _income;
  double get expense => _expense;

  DateTime get periodStart {
    if (_rangeMode == ReportRangeMode.monthly) {
      return DateTime(_focusedDate.year, _focusedDate.month, 1);
    }

    return DateTime(_focusedDate.year, 1, 1);
  }

  DateTime get periodEndExclusive {
    if (_rangeMode == ReportRangeMode.monthly) {
      return DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
    }

    return DateTime(_focusedDate.year + 1, 1, 1);
  }

  DateTime get periodEndDisplay => periodEndExclusive.subtract(
        const Duration(days: 1),
      );

  String get periodTitle {
    if (_rangeMode == ReportRangeMode.monthly) {
      return DateFormat('MM/yyyy').format(periodStart);
    }

    return DateFormat('yyyy').format(periodStart);
  }

  String get periodRangeLabel {
    return '${DateFormat('dd/MM').format(periodStart)}-${DateFormat('dd/MM').format(periodEndDisplay)}';
  }

  bool get hasActiveSearch => _searchQuery.trim().isNotEmpty;

  List<CategoryBreakdown> get activeBreakdown {
    final baseList = _activeType == ReportCategoryType.expense
        ? _expenseBreakdown
        : _incomeBreakdown;

    if (!hasActiveSearch) {
      return baseList;
    }

    final normalizedQuery = _normalize(_searchQuery);
    return baseList.where((item) {
      if (_normalize(item.name).contains(normalizedQuery)) {
        return true;
      }

      return item.transactions.any(
        (transaction) =>
            _normalize(transaction.title).contains(normalizedQuery) ||
            _normalize(transaction.category).contains(normalizedQuery),
      );
    }).toList();
  }

  List<CategoryBreakdown> get searchableBreakdown {
    return _activeType == ReportCategoryType.expense
        ? _expenseBreakdown
        : _incomeBreakdown;
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final allTransactions =
          await (_transactionLoader?.call() ?? _dbHelper.getTransactions());
      final filteredTransactions = allTransactions.where((transaction) {
        return !transaction.date.isBefore(periodStart) &&
            transaction.date.isBefore(periodEndExclusive);
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      _transactions = filteredTransactions;
      _income = _sumTransactions(filteredTransactions, 'income');
      _expense = _sumTransactions(filteredTransactions, 'expense');
      _balance = _income - _expense;
      _expenseBreakdown = _buildCategoryBreakdown(filteredTransactions, 'expense');
      _incomeBreakdown = _buildCategoryBreakdown(filteredTransactions, 'income');
    } catch (error, stackTrace) {
      debugPrint('ReportController.loadTransactions failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setRangeMode(ReportRangeMode newMode) async {
    if (_rangeMode == newMode) {
      return;
    }

    _rangeMode = newMode;
    await loadTransactions();
  }

  Future<void> shiftPeriod(int offset) async {
    _focusedDate = _rangeMode == ReportRangeMode.monthly
        ? DateTime(_focusedDate.year, _focusedDate.month + offset, 1)
        : DateTime(_focusedDate.year + offset, _focusedDate.month, 1);
    await loadTransactions();
  }

  void setActiveType(ReportCategoryType newType) {
    if (_activeType == newType) {
      return;
    }

    _activeType = newType;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    final trimmedQuery = query.trim();
    if (_searchQuery == trimmedQuery) {
      return;
    }

    _searchQuery = trimmedQuery;
    notifyListeners();
  }

  void clearSearchQuery() {
    if (_searchQuery.isEmpty) {
      return;
    }

    _searchQuery = '';
    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    await (_deleteTransactionHandler?.call(id) ?? _dbHelper.deleteTransaction(id));
    await loadTransactions();
  }

  double _sumTransactions(List<Transaction> items, String type) {
    return items
        .where((transaction) => transaction.type == type)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  List<CategoryBreakdown> _buildCategoryBreakdown(
    List<Transaction> items,
    String type,
  ) {
    final groupedTransactions = <String, List<Transaction>>{};

    for (final transaction in items.where((item) => item.type == type)) {
      groupedTransactions
          .putIfAbsent(transaction.category, () => <Transaction>[])
          .add(transaction);
    }

    final totalAmount = groupedTransactions.values.fold<double>(
      0,
      (sum, transactions) => sum + _sumAmount(transactions),
    );

    final breakdown = groupedTransactions.entries.map((entry) {
      final amount = _sumAmount(entry.value);
      final sortedTransactions = List<Transaction>.from(entry.value)
        ..sort((a, b) => b.date.compareTo(a.date));

      return CategoryBreakdown(
        name: entry.key,
        type: type,
        amount: amount,
        percentage: totalAmount == 0 ? 0 : amount / totalAmount,
        transactions: sortedTransactions,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return breakdown;
  }

  double _sumAmount(List<Transaction> items) {
    return items.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  String _normalize(String input) {
    return input.toLowerCase().trim();
  }
}
