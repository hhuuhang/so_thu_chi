import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'
    show StringTranslateExtension;
import '../../models/transaction.dart';
import '../../database/database_helper.dart';
import 'package:intl/intl.dart';
import '../../modules/numpad.dart';
import '../../utils/number_utils.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputPageStateState();
}

class _InputPageStateState extends State<InputScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController =
      TextEditingController(text: '0');
  // String title = '';
  // double amount = 0.0;
  String type = 'income';
  DateTime date = DateTime.now();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 1. FocusNode cho Số tiền (Kích hoạt Bottom Sheet)
  final FocusNode _amountFocusNode = FocusNode();
  // 2. FocusNode cho Mô tả (Kích hoạt bàn phím mặc định)
  final FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    // Lắng nghe focus cho "Số tiền"
    _amountFocusNode.addListener(_handleAmountFocusChange);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _amountFocusNode.removeListener(_handleAmountFocusChange);
    _amountFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

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

  void _handleAmountFocusChange() {
    // Chỉ xử lý khi Số tiền nhận focus
    if (_amountFocusNode.hasFocus) {
      // Ẩn bàn phím hệ thống (nếu nó đang hiện)
      FocusManager.instance.primaryFocus?.unfocus();

      // Hiển thị Bottom Sheet chứa bàn phím custom
      _showCustomNumpadSheet();
    }
  }

  void _showCustomNumpadSheet() {
    // Tự động đóng Bottom Sheet nếu màn hình bị dispose
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Cho phép Bottom Sheet chiếm toàn bộ chiều rộng
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomNumpad(
          onKeyPress: _handleKeyPress,
          onErasePress: _handleErasePress,
          buttonColor: Colors.indigo.shade400,
          textColor: Colors.white,
          buttonSize: 70.0,
          fontSize: 28.0,
        );
      },
      // Khi Bottom Sheet đóng, đảm bảo focus được xóa khỏi TextField Số tiền
    ).whenComplete(() {
      if (_amountFocusNode.hasFocus) {
        _amountFocusNode.unfocus();
      }
    });
  }

  void _addTransaction() async {
    String title = _titleController.text;
    // ⚠️ SỬ DỤNG HÀM TỪ UTILS ĐỂ LẤY GIÁ TRỊ DOUBLE SẠCH
    double amount = parseToDouble(_amountController.text);

    if (title.isNotEmpty && amount > 0) {
      Transaction newTx = Transaction(
        title: title,
        amount: amount,
        date: date,
        type: type,
      );
      await _dbHelper.insertTransaction(newTx);
      _loadTransactions();

      // Reset fields after adding transaction
      setState(() {
        _titleController.clear();
        _amountController.text = '0';
        type = 'income';
        date = DateTime.now();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Giao dịch đã được thêm!')),
        );
      }
    }
  }

  // Hàm xử lý nhập phím (được truyền vào CustomNumpad)
  void _handleKeyPress(String value) {
    //Chuyển chuỗi định dạng hiện tại thành chuỗi thô
    String rawText = removeFormat(_amountController.text);

    //Logic cập nhật số tiền (trên chuỗi thô)
    if (value == '.') {
      if (rawText.contains('.')) return;
      if (rawText.isEmpty) rawText = '0';
    }

    setState(() {
      if (rawText == '0' && value != '.') {
        rawText = value;
      } else {
        rawText += value;
      }

      //SỬ DỤNG HÀM TỪ UTILS: Định dạng lại chuỗi thô và gán vào controller
      _amountController.text = formatAmount(rawText);
    });

    //Di chuyển con trỏ về cuối
    _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length));
  }

  // Hàm xử lý xoá phím (được truyền vào CustomNumpad)
  void _handleErasePress() {
    // 1. Chuyển chuỗi định dạng hiện tại thành chuỗi thô
    String rawText = removeFormat(_amountController.text);

    setState(() {
      if (rawText.isNotEmpty) {
        String newRawText = rawText.substring(0, rawText.length - 1);

        if (newRawText.isEmpty) {
          _amountController.text = '0';
        } else {
          // 2. SỬ DỤNG HÀM TỪ UTILS: Định dạng lại và gán vào controller
          _amountController.text = formatAmount(newRawText);
        }
      }
    });

    // 3. Di chuyển con trỏ về cuối
    _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length));
  }

  void _deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    _loadTransactions();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giao dịch đã được xóa!')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(1997),
      lastDate: DateTime(2101),
      helpText: 'Chọn Ngày Giao Dịch', // Tiêu đề của DatePicker
      cancelText: 'Hủy',
      confirmText: 'Xác nhận',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    // Nếu người dùng chọn một ngày (không nhấn hủy)
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Đóng bàn phím mặc định/unfocus khi chạm ra ngoài
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Bọc bằng GestureDetector để cho phép bỏ focus khỏi Title
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Thêm Giao Dịch',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              focusNode: _titleFocusNode, // Gắn FocusNode
              decoration: const InputDecoration(labelText: 'Mô tả'),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: _amountController,
              focusNode: _amountFocusNode,
              decoration: const InputDecoration(labelText: 'Số tiền'),
              //Ngăn bàn phím mặc định hiện lên
              readOnly: true,
              showCursor: true,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: type, // Giá trị hiện tại
              decoration: const InputDecoration(
                labelText: 'Loại Giao Dịch',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              ),
              items: [
                DropdownMenuItem(
                  value: 'income',
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.green),
                      const SizedBox(width: 8),
                      Text("income".tr()),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'expense',
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_downward, color: Colors.red),
                      const SizedBox(width: 8),
                      Text("expense".tr()),
                    ],
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  type = newValue!; // Cập nhật biến trạng thái
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Ngày Giao Dịch:',
                      style: TextStyle(fontSize: 16, color: Colors.black54)),
                  TextButton.icon(
                    onPressed: () => _selectDate(context), // Gọi hàm chọn ngày
                    icon: const Icon(Icons.calendar_today, color: Colors.green),
                    label: Text(
                      DateFormat('dd/MM/yyyy').format(date),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _addTransaction,
              child: const Text('Thêm'),
            ),
            const SizedBox(height: 300),
          ],
        ),
      ),
    );
  }
}
