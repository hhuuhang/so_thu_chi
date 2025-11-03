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
  int _selectedViewIndex = 0;

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu 7 ngày gần nhất ngay khi màn hình khởi tạo
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 6));
    _controller.loadTransactions(startDate: startDate, endDate: endDate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  // ⚠️ WIDGET MỚI: Xây dựng Danh sách Báo cáo theo Danh mục
  Widget _buildCategoryReportList(
      BuildContext context, Map<String, double> reportData, Color color) {
    if (reportData.isEmpty) {
      return Center(
        child: Text("noDataForCategory".tr(),
            style: const TextStyle(fontStyle: FontStyle.italic)),
      );
    }

    // Sắp xếp danh mục theo số tiền giảm dần
    final sortedCategories = reportData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Tính tổng số tiền (cần cho việc tính phần trăm)
    final double totalAmount =
        reportData.values.fold(0.0, (sum, item) => sum + item);

    return ListView.builder(
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final entry = sortedCategories[index];
        final double percentage =
            totalAmount > 0 ? (entry.value / totalAmount) : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Row(
            children: [
              // ⚠️ Tên danh mục
              Expanded(
                flex: 4,
                child: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),

              // ⚠️ Số tiền và Phần trăm
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

  // ⚠️ WIDGET CŨ: Danh sách Giao dịch (Đổi tên và chỉnh lại)
  Widget _buildTransactionHistoryList(BuildContext context) {
    return _controller.transactions.isEmpty
        ? Center(child: Text("noTransactions".tr()))
        : ListView.builder(
            itemCount: _controller.transactions.length,
            itemBuilder: (context, index) {
              final tx = _controller.transactions[index];
              bool isIncome = tx.type == 'income';

              // ⚠️ Cập nhật để hiển thị category
              String subtitleText = '${_formatDate(tx.date)} - ${tx.category}';

              return ListTile(
                title: Text(tx.title),
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
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("transactionDeleted".tr())),
                          );
                        }
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // ⚠️ Bọc Scaffold bằng DefaultTabController
        return DefaultTabController(
            length: 3, // 2 tab Báo cáo Danh mục + 1 tab Lịch sử Giao dịch
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text("reportTitle".tr()),
                // ⚠️ Thêm TabBar cho các chế độ xem
                bottom: TabBar(
                  indicatorColor: Colors.blue.shade300,
                  tabs: [
                    Tab(
                        text: "Expense by Category"
                            .tr()), // Chi tiêu theo Danh mục
                    Tab(
                        text: "Income by Category"
                            .tr()), // Thu nhập theo Danh mục
                    Tab(text: "History".tr()), // Lịch sử giao dịch
                  ],
                  onTap: (index) {
                    setState(() {
                      _selectedViewIndex = index;
                    });
                  },
                ),
              ),
              body: Column(
                children: [
                  // # 1. THẺ TỔNG QUAN (BALANCE/INCOME/EXPENSE)
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("balance".tr(),
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey)),
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
                                      style:
                                          const TextStyle(color: Colors.green)),
                                  Text(
                                      _formatAmount(
                                          _controller.income, context),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("expense".tr(),
                                      style:
                                          const TextStyle(color: Colors.red)),
                                  Text(
                                      _formatAmount(
                                          _controller.expense, context),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // # 2. BIỂU ĐỒ (Giữ nguyên)
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

                  // # 3. HIỂN THỊ CHI TIẾT THEO TAB
                  // Sử dụng Expanded để TabBarView chiếm hết không gian còn lại
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1: Chi tiêu theo Danh mục
                        _buildCategoryReportList(
                            context, _controller.expenseByCategory, Colors.red),

                        // Tab 2: Thu nhập theo Danh mục
                        _buildCategoryReportList(context,
                            _controller.incomeByCategory, Colors.green),

                        // Tab 3: Lịch sử Giao dịch
                        _buildTransactionHistoryList(context),
                      ],
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}
