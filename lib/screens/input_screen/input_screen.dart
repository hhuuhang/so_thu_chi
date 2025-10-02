import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../database/database_helper.dart';
import 'package:intl/intl.dart';
import '../../modules/numpad.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputPageStateState();
}

class _InputPageStateState extends State<InputScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  // String title = '';
  // double amount = 0.0;
  String type = 'income';
  DateTime date = DateTime.now();

   bool _isNumpadVisible = false;
  final FocusNode _amountFocusNode = FocusNode();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _amountFocusNode.addListener(_handleFocusChange);
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

  void _addTransaction() async {
    // Get values from controllers
    String title = _titleController.text;
    double amount = double.tryParse(_amountController.text) ?? 0.0;

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
        _amountController.clear();
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

  void _handleFocusChange() {
    // Nếu TextField Số tiền nhận focus
    if (_amountFocusNode.hasFocus) {
      // Khi nhận focus, ẩn bàn phím mặc định (nếu lỡ hiện) và hiện Numpad custom
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        _isNumpadVisible = true;
      });
    } else {
      // Nếu mất focus, ẩn Numpad custom
      setState(() {
        _isNumpadVisible = false;
      });
    }
  }

   // Hàm xử lý nhập phím (được truyền vào CustomNumpad)
  void _handleKeyPress(String value) {
    // Logic cập nhật số tiền
    String currentText = _amountController.text;
    
    // Ngăn chặn nhiều dấu chấm thập phân
    if (value == '.' && currentText.contains('.')) return;
    
    setState(() {
      if (currentText == '0' && value != '.') {
        currentText = value;
      } else {
        currentText += value;
      }
      _amountController.text = currentText;
    });
    
    // Di chuyển con trỏ về cuối (để TextField luôn hiển thị số mới nhất)
    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountController.text.length)
    );
  }

  // Hàm xử lý xoá phím (được truyền vào CustomNumpad)
  void _handleErasePress() {
    String currentText = _amountController.text;
    setState(() {
      if (currentText.isNotEmpty) {
        String newText = currentText.substring(0, currentText.length - 1);
        _amountController.text = newText.isEmpty ? '0' : newText;
      }
    });
    
    // Di chuyển con trỏ về cuối
    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountController.text.length)
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _amountFocusNode.removeListener(_handleFocusChange); // Rất quan trọng!
    _amountFocusNode.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    // Đảm bảo ẩn bàn phím mặc định khi nhấn ra ngoài khu vực nhập
    return GestureDetector(
      onTap: () {
        // Mất focus khỏi bất kỳ TextField nào
        FocusScope.of(context).unfocus();
        // Ẩn Numpad custom
        setState(() {
          _isNumpadVisible = false;
        });
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ... (Tiêu đề và các phần tử khác giữ nguyên)

            // 1. TextField cho Mô tả (Title) - giữ nguyên
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              onTap: () => setState(() => _isNumpadVisible = false), // Ẩn numpad nếu click vào Title
            ),
            
            // 2. TextField cho Số tiền (Amount) - CHỈNH SỬA
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Số tiền'),
              // QUAN TRỌNG: Ngăn bàn phím mặc định hiện lên
              readOnly: true, 
              // Bỏ keyboardType vì đã dùng readOnly
              showCursor: true, // Hiển thị con trỏ để người dùng biết đang nhập
              focusNode: _amountFocusNode, // Gắn FocusNode
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            
            // ... (DropdownButton và TextButton giữ nguyên)
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _addTransaction,
              child: const Text('Thêm'),
            ),
            
            // QUAN TRỌNG: Vị trí của bàn phím custom
            // Sử dụng Spacer để đẩy các phần tử khác lên trên bàn phím
            SizedBox(height: _isNumpadVisible ? 10 : 0),
            
            // Bàn phím custom
            if (_isNumpadVisible)
              CustomNumpad(
                onKeyPress: _handleKeyPress,
                // Chắc chắn rằng _handleErasePress không có tham số (VoidCallback)
                onErasePress: _handleErasePress, 
                buttonColor: Colors.indigo.shade400,
                textColor: Colors.white,
                buttonSize: 70.0,
                fontSize: 28.0,
                specialValue: '.',
              ),
              
            // Tạo khoảng trống đệm nếu Numpad không hiện, để SingleChildScrollView không quá ngắn
            SizedBox(height: _isNumpadVisible ? 0 : 300),
          ],
        ),
      ),
    );
  }
}
