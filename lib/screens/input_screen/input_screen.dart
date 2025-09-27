import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../database/database_helper.dart';
import 'package:intl/intl.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
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
            controller: _titleController, // Use controller
            decoration: const InputDecoration(labelText: 'Mô tả'),
          ),
          TextField(
            controller: _amountController, // Use controller
            decoration: const InputDecoration(labelText: 'Số tiền'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Loại: '),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: type,
                items: ['income', 'expense'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'income' ? 'Thu' : 'Chi'),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => type = newValue!),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              final newDate = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (newDate != null) {
                setState(() {
                  date = newDate;
                });
              }
            },
            child: Text(
              'Chọn ngày: ${DateFormat('dd/MM/yyyy').format(date)}',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addTransaction,
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}
