import 'package:flutter/material.dart';

import 'package:so_thu_chi/category_catalog.dart';
import 'package:so_thu_chi/constants.dart';
import 'package:so_thu_chi/database/database_helper.dart';
import 'package:so_thu_chi/models/transaction.dart';
import 'package:so_thu_chi/utils/number_utils.dart';

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

  /// The transaction being edited (null = create mode).
  Transaction? _editingTransaction;

  TransactionType get currentType => _currentType;
  String get selectedCategory => _selectedCategory;
  DateTime get date => _date;
  bool get isEditMode => _editingTransaction != null;

  String get typeString =>
      _currentType == TransactionType.income ? 'income' : 'expense';

  Map<String, IconData> get currentCategories =>
      _currentType == TransactionType.expense
          ? expenseCategories
          : incomeCategories;

  /// Pre-populate the form with an existing [transaction] for editing.
  void loadForEdit(Transaction transaction) {
    _editingTransaction = transaction;
    titleController.text = transaction.title;
    amountController.text = formatAmount(transaction.amount.toStringAsFixed(
        transaction.amount == transaction.amount.roundToDouble() ? 0 : 2));
    _currentType = transaction.type == 'income'
        ? TransactionType.income
        : TransactionType.expense;
    _selectedCategory = transaction.category;
    _date = transaction.date;
    notifyListeners();
  }

  /// Reset to create mode.
  void resetToCreateMode() {
    _editingTransaction = null;
    titleController.clear();
    amountController.text = '0';
    _currentType = TransactionType.expense;
    _selectedCategory = expenseCategories.keys.first;
    _date = DateTime.now();
    notifyListeners();
  }

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

    if (isEditMode) {
      // UPDATE existing transaction
      final updated = _editingTransaction!.copyWith(
        title: title,
        amount: amount,
        date: _date,
        type: typeString,
        category: _selectedCategory,
      );
      await _dbHelper.updateTransaction(updated);

      resetToCreateMode();

      if (!context.mounted) return;
      _showSuccessToast(context, label: 'Giao dịch đã được cập nhật');
    } else {
      // INSERT new transaction
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

      if (!context.mounted) return;
      _showSuccessToast(context);
    }
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

  void _showSuccessToast(BuildContext context,
      {String label = 'Giao dịch đã được lưu'}) {
    final overlay = Overlay.of(context);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _SuccessToast(
        label: label,
        onDismissed: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Custom success toast widget
// ---------------------------------------------------------------------------

class _SuccessToast extends StatefulWidget {
  const _SuccessToast({required this.onDismissed, this.label = 'Giao dịch đã được lưu'});

  final VoidCallback onDismissed;
  final String label;

  @override
  State<_SuccessToast> createState() => _SuccessToastState();
}

class _SuccessToastState extends State<_SuccessToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();

    // Auto dismiss after 2.2 s
    Future.delayed(const Duration(milliseconds: 2200), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: bottomPadding + 90,
        ),
        child: FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _slide,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFF34C759).withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon badge
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF34C759),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Thành công',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.label,
                            style: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
