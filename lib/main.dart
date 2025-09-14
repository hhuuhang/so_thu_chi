import 'package:flutter/material.dart';
import 'models/transaction.dart';
import 'database/database_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tổng Quan Thu Chi',
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
  Map<String, Map<String, double>> _chartData = {};

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    List<Transaction> transactions = await _dbHelper.getTransactions();
    double income = 0.0;
    double expense = 0.0;
    Map<String, Map<String, double>> chartData = {};
    for (var tx in transactions) {
      String dateKey = DateFormat('dd/MM/yyyy').format(tx.date);
      if (!chartData.containsKey(dateKey)) {
        chartData[dateKey] = {'income': 0.0, 'expense': 0.0};
      }
      if (tx.type == 'income') {
        income += tx.amount;
        chartData[dateKey]!['income'] =
            chartData[dateKey]!['income']! + tx.amount;
      } else {
        expense += tx.amount;
        chartData[dateKey]!['expense'] =
            chartData[dateKey]!['expense']! + tx.amount;
      }
    }
    setState(() {
      _transactions = transactions;
      _income = income;
      _expense = expense;
      _balance = income - expense;
      _chartData = chartData;
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
                  setState(() {});
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

  Widget _buildBarChart() {
    List<BarChartGroupData> barGroups = [];
    List<String> dateKeys = _chartData.keys.toList();
    dateKeys.sort((a, b) => DateFormat('dd/MM/yyyy')
        .parse(a)
        .compareTo(DateFormat('dd/MM/yyyy').parse(b)));

    for (int i = 0; i < dateKeys.length && i < 7; i++) {
      String date = dateKeys[i];
      double income = _chartData[date]!['income']!;
      double expense = _chartData[date]!['expense']!;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: income,
              color: Colors.green,
              width: 10,
            ),
            BarChartRodData(
              toY: expense,
              color: Colors.red,
              width: 10,
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    NumberFormat.compactCurrency(locale: 'vi_VN', symbol: '')
                        .format(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < dateKeys.length) {
                    return Text(
                      dateKeys[value.toInt()].split('/')[0], // Hiển thị ngày
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
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
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text('Biểu đồ Thu Chi',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                _buildBarChart(),
              ],
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
