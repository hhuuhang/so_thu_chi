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
  final TextEditingController _amountController = TextEditingController(text: '0');
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
      isScrollControlled: true, // Cho phép Bottom Sheet chiếm toàn bộ chiều rộng
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomNumpad(
          onKeyPress: _handleKeyPress,
          onErasePress: _handleErasePress,
          buttonColor: Colors.indigo.shade400,
          textColor: Colors.white,
          buttonSize: 70.0,
          fontSize: 28.0,
          specialValue: '.',
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
    // Get values from controllers
    String title = _titleController.text;
    // Đảm bảo loại bỏ dấu phẩy/khoảng trắng trước khi parse nếu có
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

   // Hàm xử lý nhập phím (được truyền vào CustomNumpad)
  void _handleKeyPress(String value) {
    // Logic cập nhật số tiền
    String currentText = _amountController.text;
    
    // Ngăn chặn nhiều dấu chấm thập phân
     
    if (value == '.') {
      if (currentText.contains('.')) return; // Chỉ cho phép 1 dấu chấm
      if (currentText.isEmpty || currentText == '0') currentText = '0';
    }
    
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
        // Đóng bàn phím mặc định/unfocus khi chạm ra ngoài
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          // Bao bọc bằng GestureDetector để cho phép bỏ focus khỏi Title nếu có
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
              
              // 1. TextField Mô tả: Dùng bàn phím mặc định
            TextField(
              controller: _titleController,
              focusNode: _titleFocusNode, // Gắn FocusNode
              decoration: const InputDecoration(labelText: 'Mô tả'),
              keyboardType: TextInputType.text,
            ),
              
             // 2. TextField Số tiền: Kích hoạt Bottom Sheet (Không bàn phím mặc định)
            TextField(
              controller: _amountController,
              focusNode: _amountFocusNode, 
              decoration: const InputDecoration(labelText: 'Số tiền'),
              // QUAN TRỌNG: Ngăn bàn phím mặc định hiện lên
              readOnly: true, 
              showCursor: true, 
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
              
              // ... (DropdownButton và TextButton giữ nguyên)
              
              // Thêm khoảng trống lớn để đảm bảo SingleChildScrollView hoạt động tốt
              const SizedBox(height: 50),
              
              // Nút Thêm và Nút Test (giữ nguyên)
              ElevatedButton(
                onPressed: _addTransaction,
                child: const Text('Thêm'),
              ),
              const SizedBox(height: 300), 
              // Thêm nút test (nếu cần)
                    
            ],
          ),
        ),
      
    );
  }
}
