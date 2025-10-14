// screens/input_screen/input_controller.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/transaction.dart';
import '../../../database/database_helper.dart';
import '../../../utils/number_utils.dart';
import '../../constants.dart';

// Danh mục TIỀN CHI
final Map<String, IconData> expenseCategories = {
  'Ăn uống': Icons.restaurant,
  'Chi tiêu': Icons.clean_hands,
  'Mua sắm': Icons.shopping_bag,
  'Trả nợ': Icons.payments,
  'Phí giao lưu': Icons.wine_bar,
  'Y tế': Icons.medical_services,
  'phát triển bản t...': Icons.lightbulb,
  'Đầu tư': Icons.monetization_on,
  'Đi lại': Icons.train,
  'Giải trí': Icons.music_note,
  'Xăng xe': Icons.local_gas_station,
  'Tiền nhà': Icons.home,
};

// Danh mục TIỀN THU
final Map<String, IconData> incomeCategories = {
  'Lương': Icons.attach_money,
  'Thưởng': Icons.star,
  'Tặng': Icons.card_giftcard,
  'Mượn': Icons.handshake,
};

class InputController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController(text: '0');

  TransactionType _currentType = TransactionType.expense;
  String _selectedCategory = 'Ăn uống';
  DateTime _date = DateTime.now();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Getter (Lấy giá trị ra)
  TransactionType get currentType => _currentType;
  String get selectedCategory => _selectedCategory;
  DateTime get date => _date;
  
  String get typeString => _currentType == TransactionType.income ? 'income' : 'expense';
  
  Map<String, IconData> get currentCategories => 
      _currentType == TransactionType.expense ? expenseCategories : incomeCategories;

  // Khởi tạo (Thay thế initState)
  InputController() {
    _loadTransactions();
  }
  
  // Setter (Thay đổi giá trị)
  void setCurrentType(TransactionType newType) {
    if (_currentType != newType) {
      _currentType = newType;
      amountController.text = '0'; // Reset số tiền
      
      // Chọn danh mục mặc định
      _selectedCategory = newType == TransactionType.expense 
          ? expenseCategories.keys.first
          : incomeCategories.keys.first;
          
      notifyListeners(); // Báo cho UI render lại
    }
  }

  void setSelectedCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }
  
  // Hàm Load Transactions (giữ nguyên logic)
  Future<void> _loadTransactions() async {
    List<Transaction> transactions = await _dbHelper.getTransactions();
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
  }

  // Hàm Thêm Giao Dịch
  Future<void> addTransaction(BuildContext context) async {
    String title = titleController.text;
    double amount = parseToDouble(amountController.text);

    if (title.isNotEmpty && amount > 0) {
      Transaction newTx = Transaction(
        title: title,
        amount: amount,
        date: _date,
        type: typeString,
        category: _selectedCategory,
      );
      await _dbHelper.insertTransaction(newTx);
      _loadTransactions();

      // Reset fields
      titleController.clear();
      amountController.text = '0';
      _currentType = TransactionType.expense;
      _selectedCategory = expenseCategories.keys.first;
      _date = DateTime.now();
      
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giao dịch đã được thêm!')),
      );
    }
  }
  
  // Hàm xử lý nhập phím
  void handleKeyPress(String value) {
    String rawText = removeFormat(amountController.text);

    if (value == '.') {
      if (rawText.contains('.')) return;
      if (rawText.isEmpty) rawText = '0';
    }

    if (rawText == '0' && value != '.') {
      rawText = value;
    } else {
      rawText += value;
    }

    amountController.text = formatAmount(rawText);
    
    // Cập nhật vị trí con trỏ (không cần notifyListeners vì controller tự handle)
    amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountController.text.length));
  }

  // Hàm xử lý xoá phím
  void handleErasePress() {
    String rawText = removeFormat(amountController.text);

    if (rawText.isNotEmpty) {
      String newRawText = rawText.substring(0, rawText.length - 1);

      if (newRawText.isEmpty) {
        amountController.text = '0';
      } else {
        amountController.text = formatAmount(newRawText);
      }
    }
    
    amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountController.text.length));
  }

  // Hàm chọn ngày tháng
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1997),
      lastDate: DateTime(2101),
      helpText: 'Chọn Ngày Giao Dịch', 
      cancelText: 'Hủy',
      confirmText: 'Xác nhận',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: _currentType == TransactionType.income ? Colors.green : Colors.red,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _date) {
      _date = picked;
      notifyListeners();
    }
  }

  // Hàm điều hướng ngày tháng
  void navigateDate(int days) {
    _date = _date.add(Duration(days: days));
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }
}