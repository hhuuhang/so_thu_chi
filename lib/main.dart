import 'package:flutter/material.dart';
import 'models/transaction.dart';
import 'database/database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Thu Chi',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Transaction> _transactions = [];
  double _balance = 0.0;
  double _income = 0.0;
  double _expense = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    List<Transaction> transactions = await _dbHelper.getTransactions();
    double income = 0.0;
    double expense = 0.0;
    for (var tx in transactions) {
      if (tx.type == 'income') {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }
    setState(() {
      _transactions = transactions;
      _income = income;
      _expense = expense;
      _balance = income - expense;
    });
  }

  void _addTransaction(
      String title, double amount, DateTime date, String type) async {
    Transaction newTx =
        Transaction(title: title, amount: amount, date: date, type: type);
    await _dbHelper.insertTransaction(newTx);
    _loadTransactions();
  }

  void _deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    _loadTransactions();
  }

  void _showAddTransactionDialog() {
    String title = '';
    double amount = 0.0;
    DateTime date = DateTime.now();
    String type = 'expense';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm Giao Dịch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Mô tả'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Số tiền'),
                keyboardType: TextInputType.number,
                onChanged: (value) => amount = double.tryParse(value) ?? 0.0,
              ),
              Row(
                children: [
                  const Text('Loại: '),
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
              TextButton(
                onPressed: () async {
                  date = (await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      )) ??
                      date;
                },
                child: Text(
                    'Chọn ngày: ${date.toLocal().toString().split(' ')[0]}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (title.isNotEmpty && amount > 0) {
                  _addTransaction(title, amount, date, type);
                  Navigator.pop(context);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản Lý Thu Chi')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Số dư: ${_balance.toStringAsFixed(0)} ₫',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Thu: ${_income.toStringAsFixed(0)} ₫'),
                  Text('Chi: ${_expense.toStringAsFixed(0)} ₫'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                Transaction tx = _transactions[index];
                return ListTile(
                  title: Text(tx.title),
                  subtitle: Text(
                      '${tx.formattedDate} - ${tx.type == 'income' ? 'Thu' : 'Chi'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tx.formattedAmount,
                          style: TextStyle(
                              color: tx.type == 'income'
                                  ? Colors.green
                                  : Colors.red)),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTransaction(tx.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
