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
  @override
  void initState() {
    super.initState();
    _loadTransactions();
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

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
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
     return Scaffold(
      // Body được chia thành 2 phần: phần cuộn (inputs) và phần cố định (numpad)
      body: Column(
        children: [
          // 1. PHẦN TRÊN: Dữ liệu nhập (có thể cuộn)
          Expanded( 
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              // Bao bọc bằng GestureDetector để cho phép bỏ focus khỏi Title nếu có
              child: GestureDetector(
                onTap: () {
                   // Bỏ focus khỏi các text field trong vùng cuộn
                   FocusManager.instance.primaryFocus?.unfocus(); 
                },
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
                    
                    // TextField Mô tả (sử dụng bàn phím hệ thống)
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Mô tả'),
                      keyboardType: TextInputType.text,
                    ),
                    
                    // TextField Số tiền (Không readOnly để có con trỏ, nhưng KHÔNG dùng keyboardType)
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Số tiền'),
                      // Đặt readOnly: true nếu bạn muốn ngăn gõ tay hoàn toàn
                      // Đặt readOnly: false nếu bạn muốn cho phép gõ tay/dán số
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
                    // Thêm nút test (nếu cần)
              
                  ],
                ),
              ),
            ),
          ),

          // 2. PHẦN DƯỚI: Bàn phím custom (Cố định, không cuộn)
          CustomNumpad(
            onKeyPress: _handleKeyPress,
            onErasePress: _handleErasePress,
            buttonColor: Colors.indigo.shade400,
            textColor: Colors.white,
            buttonSize: 70.0,
            fontSize: 28.0,
            specialValue: '.',
          ),
        ],
      ),
    );
  }
}
