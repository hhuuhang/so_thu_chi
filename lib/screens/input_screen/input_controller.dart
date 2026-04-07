import 'package:flutter/material.dart';

import 'package:so_thu_chi/constants.dart';
import 'package:so_thu_chi/database/database_helper.dart';
import 'package:so_thu_chi/models/transaction.dart';
import 'package:so_thu_chi/utils/number_utils.dart';

final Map<String, IconData> expenseCategories = {
  'Ăn uống': Icons.restaurant,
  'Chi tiêu': Icons.clean_hands,
  'Mua sắm': Icons.shopping_bag,
  'Trả nợ': Icons.payments,
  'Phí giao lưu': Icons.wine_bar,
  'Y tế': Icons.medical_services,
  'Phát triển bản thân': Icons.lightbulb,
  'Đầu tư': Icons.monetization_on,
  'Đi lại': Icons.train,
  'Giải trí': Icons.music_note,
  'Xăng xe': Icons.local_gas_station,
  'Tiền nhà': Icons.home,
};

final Map<String, IconData> incomeCategories = {
  'Lương': Icons.attach_money,
  'Thưởng': Icons.star,
  'Tặng': Icons.card_giftcard,
  'Mượn': Icons.handshake,
};

class InputController extends ChangeNotifier {
  InputController(
      {Future<int> Function(Transaction transaction)? insertTransaction})
      : _insertTransaction = insertTransaction;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController =
      TextEditingController(text: '0');
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Future<int> Function(Transaction transaction)? _insertTransaction;

  TransactionType _currentType = TransactionType.expense;
  String _selectedCategory = expenseCategories.keys.first;
  DateTime _date = DateTime.now();

  TransactionType get currentType => _currentType;
  String get selectedCategory => _selectedCategory;
  DateTime get date => _date;

  String get typeString =>
      _currentType == TransactionType.income ? 'income' : 'expense';

  Map<String, IconData> get currentCategories =>
      _currentType == TransactionType.expense
          ? expenseCategories
          : incomeCategories;

  void setCurrentType(TransactionType newType) {
    if (_currentType == newType) {
      return;
    }

    _currentType = newType;
    amountController.text = '0';
    _selectedCategory = newType == TransactionType.expense
        ? expenseCategories.keys.first
        : incomeCategories.keys.first;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    if (_selectedCategory == category) {
      return;
    }

    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addTransaction(BuildContext context) async {
    final title = titleController.text.trim();
    final amount = parseToDouble(amountController.text);

    if (amount <= 0) {
      return;
    }

    final newTx = Transaction(
      title: title,
      amount: amount,
      date: _date,
      type: typeString,
      category: _selectedCategory,
    );

    await (_insertTransaction?.call(newTx) ??
        _dbHelper.insertTransaction(newTx));

    titleController.clear();
    amountController.text = '0';
    _currentType = TransactionType.expense;
    _selectedCategory = expenseCategories.keys.first;
    _date = DateTime.now();
    notifyListeners();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Giao dịch đã được thêm!')),
    );
  }

  void handleKeyPress(String value) {
    var rawText = removeFormat(amountController.text);

    if (value == '.') {
      if (rawText.contains('.')) {
        return;
      }
      if (rawText.isEmpty) {
        rawText = '0';
      }
    }

    if (rawText == '0' && value != '.') {
      rawText = value;
    } else {
      rawText += value;
    }

    amountController.text = formatAmount(rawText);
    amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: amountController.text.length),
    );
  }

  void handleErasePress() {
    final rawText = removeFormat(amountController.text);

    if (rawText.isNotEmpty) {
      final newRawText = rawText.substring(0, rawText.length - 1);
      amountController.text =
          newRawText.isEmpty ? '0' : formatAmount(newRawText);
    }

    amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: amountController.text.length),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
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
              primary: _currentType == TransactionType.income
                  ? Colors.green
                  : Colors.red,
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
