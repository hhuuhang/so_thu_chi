import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'report_controller.dart';
import 'package:easy_localization/easy_localization.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportController _controller = ReportController();

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu 7 ngày gần nhất ngay khi màn hình khởi tạo
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 6));
    _controller.loadTransactions(startDate: startDate, endDate: endDate);
  }

  // Tách biệt logic định dạng số tiền (Có thể đặt trong extension nếu muốn)
  String _formatAmount(double amount, BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return NumberFormat.currency(
      locale: locale,
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount);
  }

  // Tách biệt logic định dạng ngày
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Xây dựng Biểu đồ
  Widget _buildBarChart(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    List<String> dateKeys = _controller.chartData.keys.toList();
    dateKeys.sort((a, b) => DateFormat('dd/MM/yyyy')
        .parse(a)
        .compareTo(DateFormat('dd/MM/yyyy').parse(b)));

    for (int i = 0; i < dateKeys.length && i < 7; i++) {
      String date = dateKeys[i];
      double income = _controller.chartData[date]!['income']!;
      double expense = _controller.chartData[date]!['expense']!;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: income, color: Colors.green, width: 8),
            BarChartRodData(toY: expense, color: Colors.red, width: 8),
          ],
        ),
      );
    }

    final locale = Localizations.localeOf(context).toString();

    return Container(
      height: 200,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 16),
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
                    NumberFormat.compactCurrency(locale: locale, symbol: '')
                        .format(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < dateKeys.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4,
                      child: Text(
                        dateKeys[value.toInt()].split('/')[0],
                        style: const TextStyle(fontSize: 10),
                      ),
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
          gridData: const FlGridData(show: true, drawVerticalLine: false),
        ),
      ),
    );
  }

  // Xây dựng Danh sách Giao dịch
  Widget _buildTransactionList(BuildContext context) {
    return Expanded(
      child: _controller.transactions.isEmpty
          ? Center(child: Text("noTransactions".tr()))
          : ListView.builder(
              itemCount: _controller.transactions.length,
              itemBuilder: (context, index) {
                final tx = _controller.transactions[index];
                bool isIncome = tx.type == 'income';
                return ListTile(
                  title: Text(tx.title),
                  subtitle: Text(
                      '${_formatDate(tx.date)} - ${isIncome ? "income".tr() : "expense".tr()}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatAmount(tx.amount, context),
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        color: Colors.grey,
                        onPressed: () async {
                          await _controller.deleteTransaction(tx.id!);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("transactionDeleted".tr())),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // # SỬ DỤNG LISTENABLEBUILDER ĐỂ LẮNG NGHE LOGIC (Controller)
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        if (_controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(), // Hiển thị vòng xoay tải
          );
        }
        return Column(
          children: [
            // # THẺ TỔNG QUAN (Card)
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("balance".tr(),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      _formatAmount(_controller.balance, context),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _controller.balance >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("income".tr(),
                                style: const TextStyle(color: Colors.green)),
                            Text(_formatAmount(_controller.income, context),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("expense".tr(),
                                style: const TextStyle(color: Colors.red)),
                            Text(_formatAmount(_controller.expense, context),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // # BIỂU ĐỒ (Chỉ hiển thị khi có dữ liệu)
            if (_controller.chartData.isNotEmpty)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text("chartTitle".tr(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    _buildBarChart(context),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("noTransactions".tr(),
                    style: const TextStyle(fontStyle: FontStyle.italic)),
              ),

            // # DANH SÁCH GIAO DỊCH
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("transactionHistory".tr(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            _buildTransactionList(context),
          ],
        );
      },
    );
  }
}
