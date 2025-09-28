import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../database/database_helper.dart';
import 'package:intl/intl.dart';

// Kế thừa từ ChangeNotifier để thông báo thay đổi cho UI
class ReportController extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;

  // # BIẾN TRẠNG THÁI (STATE)
  List<Transaction> _transactions = [];
  double _balance = 0.0;
  double _income = 0.0;
  double _expense = 0.0;
  Map<String, Map<String, double>> _chartData = {};

  // # GETTERS: Cung cấp quyền truy cập chỉ đọc (read-only) từ bên ngoài
  List<Transaction> get transactions => _transactions;
  double get balance => _balance;
  double get income => _income;
  double get expense => _expense;
  Map<String, Map<String, double>> get chartData => _chartData;
  bool get isLoading => _isLoading;

  // # HÀM XỬ LÝ LOGIC

  // Hàm tải giao dịch và cập nhật trạng thái
  Future<void> loadTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // 1. Đặt trạng thái đang tải
    _isLoading = true;
    notifyListeners(); // Báo cho UI biết đang tải để hiển thị loading

    // 2. Thực hiện tải dữ liệu và tính toán
    List<Transaction> transactions = await _getTransactions(
      startDate: startDate,
      endDate: endDate,
    );
    double newIncome = _getIncome(transactions);
    double newExpense = _getExpense(transactions);
    Map<String, Map<String, double>> newChartData =
        _buildChartData(transactions);

    // 3. Cập nhật trạng thái
    _transactions = transactions;
    _income = newIncome;
    _expense = newExpense;
    _balance = newIncome - newExpense;
    _chartData = newChartData;

    // 4. Đặt trạng thái tải xong
    _isLoading = false;
    notifyListeners(); // Báo cho UI biết đã tải xong, hiển thị dữ liệu
  }

  // Hàm xóa giao dịch và tải lại dữ liệu
  Future<void> deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    // Tải lại dữ liệu sau khi xóa
    await loadTransactions();
  }

  // # HÀM HỖ TRỢ (PRIVATE METHODS)

  Future<List<Transaction>> _getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Logic lọc theo ngày (giống như đề xuất trước)
    List<Transaction> allTransactions = await _dbHelper.getTransactions();

    return allTransactions.where((tx) {
      bool isAfterStart = startDate == null ||
          tx.date.isAfter(startDate.subtract(const Duration(days: 1)));

      bool isBeforeEnd = endDate == null ||
          tx.date.isBefore(endDate.add(const Duration(days: 1)));

      return isAfterStart && isBeforeEnd;
    }).toList();
  }

  double _getIncome(List<Transaction> transactions) => transactions
      .where((tx) => tx.type == 'income')
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double _getExpense(List<Transaction> transactions) => transactions
      .where((tx) => tx.type == 'expense')
      .fold(0.0, (sum, tx) => sum + tx.amount);

  Map<String, Map<String, double>> _buildChartData(
      List<Transaction> transactions) {
    Map<String, Map<String, double>> chartData = {};
    for (var tx in transactions) {
      String dateKey = DateFormat('dd/MM/yyyy').format(tx.date);
      if (!chartData.containsKey(dateKey)) {
        chartData[dateKey] = {'income': 0.0, 'expense': 0.0};
      }
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
}
