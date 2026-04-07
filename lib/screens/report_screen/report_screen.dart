import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'report_controller.dart';

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
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 6));
    _controller.loadTransactions(startDate: startDate, endDate: endDate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatAmount(double amount, BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return NumberFormat.currency(
      locale: locale,
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  Widget _buildBarChart(BuildContext context) {
    final barGroups = <BarChartGroupData>[];
    final dateKeys = _controller.chartData.keys.toList()
      ..sort(
        (a, b) => DateFormat('dd/MM/yyyy')
            .parse(a)
            .compareTo(DateFormat('dd/MM/yyyy').parse(b)),
      );

    for (var i = 0; i < dateKeys.length && i < 7; i++) {
      final date = dateKeys[i];
      final income = _controller.chartData[date]!['income']!;
      final expense = _controller.chartData[date]!['expense']!;

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

    return SizedBox(
      height: 200,
      child: Padding(
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
                    if (value.toInt() >= dateKeys.length) {
                      return const SizedBox.shrink();
                    }

                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4,
                      child: Text(
                        dateKeys[value.toInt()].split('/')[0],
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: true, drawVerticalLine: false),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryReportList(
    BuildContext context,
    Map<String, double> reportData,
    Color color,
  ) {
    if (reportData.isEmpty) {
      return Center(
        child: Text(
          'noDataForCategory'.tr(),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    final sortedCategories = reportData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalAmount = reportData.values.fold(0.0, (sum, item) => sum + item);

    return ListView.builder(
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final entry = sortedCategories[index];
        final percentage = totalAmount > 0 ? entry.value / totalAmount : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatAmount(entry.value, context),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(percentage * 100).toStringAsFixed(1)}%',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionHistoryList(BuildContext context) {
    if (_controller.transactions.isEmpty) {
      return Center(child: Text('noTransactions'.tr()));
    }

    return ListView.builder(
      itemCount: _controller.transactions.length,
      itemBuilder: (context, index) {
        final tx = _controller.transactions[index];
        final isIncome = tx.type == 'income';
        final title = tx.title.trim().isEmpty ? tx.category : tx.title.trim();
        final subtitleText = '${_formatDate(tx.date)} - ${tx.category}';

        return ListTile(
          title: Text(title),
          subtitle: Text(subtitleText),
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
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('transactionDeleted'.tr())),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        if (_controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text('reportTitle'.tr()),
              bottom: TabBar(
                indicatorColor: Colors.blue.shade300,
                tabs: [
                  Tab(text: 'Expense by Category'.tr()),
                  Tab(text: 'Income by Category'.tr()),
                  Tab(text: 'History'.tr()),
                ],
              ),
            ),
            body: Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'balance'.tr(),
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
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
                                Text(
                                  'income'.tr(),
                                  style: const TextStyle(color: Colors.green),
                                ),
                                Text(
                                  _formatAmount(_controller.income, context),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'expense'.tr(),
                                  style: const TextStyle(color: Colors.red),
                                ),
                                Text(
                                  _formatAmount(_controller.expense, context),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_controller.chartData.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            'chartTitle'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildBarChart(context),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'noTransactions'.tr(),
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildCategoryReportList(
                        context,
                        _controller.expenseByCategory,
                        Colors.red,
                      ),
                      _buildCategoryReportList(
                        context,
                        _controller.incomeByCategory,
                        Colors.green,
                      ),
                      _buildTransactionHistoryList(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
