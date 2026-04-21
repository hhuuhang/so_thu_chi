import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../category_catalog.dart';
import '../../models/transaction.dart';
import '../../theme/app_colors.dart';
import 'report_controller.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({
    super.key,
    this.controller,
  });

  final ReportController? controller;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late final ReportController _controller;
  late final bool _ownsController;
  int _touchedSectionIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ReportController();
    _ownsController = widget.controller == null;
    _controller.loadTransactions();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  String _formatAmount(BuildContext context, double amount) {
    final locale = Localizations.localeOf(context).toString();
    final formatter = NumberFormat.decimalPattern(locale);
    return '${formatter.format(amount.abs().round())}đ';
  }

  String _formatSignedAmount(
    BuildContext context,
    double amount, {
    bool alwaysShowSign = false,
  }) {
    final sign = amount < 0
        ? '-'
        : amount > 0
            ? '+'
            : alwaysShowSign
                ? '+'
                : '';
    return '$sign${_formatAmount(context, amount)}';
  }



  String _truncateCategoryLabel(String value) {
    if (value.length <= 10) {
      return value;
    }

    return '${value.substring(0, 9)}…';
  }

  String _transactionTitle(Transaction transaction) {
    final trimmedTitle = transaction.title.trim();
    return trimmedTitle.isEmpty ? transaction.category : trimmedTitle;
  }

  Future<void> _handleSearchPressed() async {
    final appliedQuery = await showSearch<String?>(
      context: context,
      delegate: _ReportSearchDelegate(
        initialQuery: _controller.searchQuery,
        categories: _controller.searchableBreakdown,
        formatAmount: (amount) => _formatAmount(context, amount),
      ),
    );

    if (!mounted || appliedQuery == null) {
      return;
    }

    _controller.setSearchQuery(appliedQuery);
  }

  Future<void> _showCategoryDetails(
    CategoryBreakdown item,
    Color accentColor,
  ) async {
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final dateFormatter = DateFormat('dd/MM/yyyy • HH:mm', locale);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.74,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colors.bottomSheetBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(
                  color: colors.subtleDivider,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.bottomSheetHandle,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            iconForCategory(item.name, item.type),
                            color: accentColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.transactions.length} ${'reportTransactionsLabel'.tr()}',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatSignedAmount(
                            context,
                            item.type == 'expense' ? -item.amount : item.amount,
                            alwaysShowSign: item.type == 'income',
                          ),
                          style: TextStyle(
                            color: item.type == 'income'
                                ? colors.incomeAccent
                                : colors.expenseColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: item.transactions.length,
                      separatorBuilder: (_, __) => Divider(
                        color: colors.subtleDivider,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final transaction = item.transactions[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _transactionTitle(transaction),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateFormatter.format(transaction.date),
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _formatSignedAmount(
                                  context,
                                  item.type == 'expense'
                                      ? -transaction.amount
                                      : transaction.amount,
                                  alwaysShowSign: item.type == 'income',
                                ),
                                style: TextStyle(
                                  color: item.type == 'income'
                                      ? colors.incomeAccent
                                      : colors.expenseColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopToolbar() {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        const SizedBox(width: 44, height: 44),
        Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.toolbarBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ReportModeChip(
                      label: 'reportMonthly'.tr(),
                      isSelected:
                          _controller.rangeMode == ReportRangeMode.monthly,
                      onTap: () => _controller.setRangeMode(
                        ReportRangeMode.monthly,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _ReportModeChip(
                      label: 'reportYearly'.tr(),
                      isSelected: _controller.rangeMode == ReportRangeMode.yearly,
                      onTap: () => _controller.setRangeMode(
                        ReportRangeMode.yearly,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'reportSearch'.tr(),
          onPressed: _handleSearchPressed,
          icon: Icon(
            Icons.search_rounded,
            size: 38,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodNavigator() {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton(
          onPressed: () => _controller.shiftPeriod(-1),
          icon: const Icon(Icons.chevron_left_rounded, size: 34),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: colors.elevatedCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Center(
              child: Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    _controller.periodTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    '(${_controller.periodRangeLabel})',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _controller.shiftPeriod(1),
          icon: const Icon(Icons.chevron_right_rounded, size: 34),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'reportExpense'.tr(),
                value: _formatSignedAmount(context, -_controller.expense),
                valueColor: colors.expenseColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'reportIncome'.tr(),
                value: _formatSignedAmount(
                  context,
                  _controller.income,
                  alwaysShowSign: true,
                ),
                valueColor: colors.incomeAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _SummaryCard(
          label: 'reportNet'.tr(),
          value: _formatSignedAmount(
            context,
            _controller.balance,
            alwaysShowSign: _controller.balance > 0,
          ),
          valueColor: _controller.balance < 0
              ? colors.expenseColor
              : (_controller.balance > 0 ? colors.incomeAccent : colors.textPrimary),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildBreakdownSwitch() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.strongDivider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BreakdownTab(
              label: 'reportExpense'.tr(),
              isSelected: _controller.activeType == ReportCategoryType.expense,
              onTap: () {
                setState(() {
                  _touchedSectionIndex = -1;
                });
                _controller.setActiveType(ReportCategoryType.expense);
              },
            ),
          ),
          Expanded(
            child: _BreakdownTab(
              label: 'reportIncome'.tr(),
              isSelected: _controller.activeType == ReportCategoryType.income,
              onTap: () {
                setState(() {
                  _touchedSectionIndex = -1;
                });
                _controller.setActiveType(ReportCategoryType.income);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBanner() {
    if (!_controller.hasActiveSearch) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.bannerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.bannerBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 18,
            color: colors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${'reportSearchResultFor'.tr()} "${_controller.searchQuery}"',
              style: TextStyle(fontSize: 13, color: colors.textPrimary),
            ),
          ),
          TextButton(
            onPressed: _controller.clearSearchQuery,
            child: Text('reportClearFilter'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartSection() {
    final colors = Theme.of(context).colorScheme;
    final categories = _controller.activeBreakdown;

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 44),
        child: Column(
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              color: colors.textTertiary,
              size: 46,
            ),
            const SizedBox(height: 12),
            Text(
              'reportNoDataInRange'.tr(),
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    final selectedType = _controller.activeType;

    final sections = categories.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == _touchedSectionIndex;
      final color = colorForCategory(item.name, selectedType.toString().split('.').last,
          isDark: colors.brightness == Brightness.dark);
      final showLabel = item.percentage >= 0.08 || isTouched;

      return PieChartSectionData(
        color: color,
        value: item.amount,
        radius: isTouched ? 120 : 110,
        title: showLabel ? _truncateCategoryLabel(item.name) : '',
        titleStyle: TextStyle(
          color: Colors.white,
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.w700,
        ),
        titlePositionPercentageOffset: 0.74,
      );
    }).toList();

    return SizedBox(
      height: 340,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 60,
          sectionsSpace: 0,
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              if (!event.isInterestedForInteractions ||
                  response?.touchedSection == null) {
                setState(() {
                  _touchedSectionIndex = -1;
                });
                return;
              }

              setState(() {
                _touchedSectionIndex =
                    response!.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          sections: sections,
        ),
      ),
    );
  }

  Widget _buildCategoryRow(CategoryBreakdown item, int index) {
    final colors = Theme.of(context).colorScheme;
    final color = colorForCategory(item.name, _controller.activeType.toString().split('.').last,
        isDark: colors.brightness == Brightness.dark);

    return InkWell(
      onTap: () => _showCategoryDetails(item, color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.subtleDivider),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Icon(
                iconForCategory(item.name, item.type),
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatAmount(context, item.amount),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(item.percentage * 100).toStringAsFixed(1)} %',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textTertiary,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          body: SafeArea(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _controller.loadTransactions,
                    color: colors.primary,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            child: Column(
                              children: [
                                _buildTopToolbar(),
                                const SizedBox(height: 18),
                                _buildPeriodNavigator(),
                                const SizedBox(height: 16),
                                _buildSummaryCards(),
                                const SizedBox(height: 18),
                                _buildBreakdownSwitch(),
                                _buildSearchBanner(),
                                const SizedBox(height: 12),
                                _buildPieChartSection(),
                              ],
                            ),
                          ),
                        ),
                        if (_controller.activeBreakdown.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Text(
                                  _controller.hasActiveSearch
                                      ? 'reportNoSearchResults'.tr()
                                      : 'reportNoDataInRange'.tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          SliverList.builder(
                            itemCount: _controller.activeBreakdown.length,
                            itemBuilder: (context, index) {
                              return _buildCategoryRow(
                                _controller.activeBreakdown[index],
                                index,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _ReportModeChip extends StatelessWidget {
  const _ReportModeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? colors.chipSelectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? colors.chipSelectedText
                : colors.chipUnselectedText,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isFullWidth = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isFullWidth ? 18 : 16,
      ),
      decoration: BoxDecoration(
        color: colors.summaryCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.summaryCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isFullWidth ? 24 : 20,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownTab extends StatelessWidget {
  const _BreakdownTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isSelected ? colors.primary : colors.textPrimary,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 3,
            color: isSelected ? colors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _ReportSearchDelegate extends SearchDelegate<String?> {
  _ReportSearchDelegate({
    required String initialQuery,
    required this.categories,
    required this.formatAmount,
  }) {
    query = initialQuery;
  }

  final List<CategoryBreakdown> categories;
  final String Function(double amount) formatAmount;

  Iterable<CategoryBreakdown> _matchResults(String rawQuery) {
    final normalizedQuery = rawQuery.toLowerCase().trim();

    if (normalizedQuery.isEmpty) {
      return categories;
    }

    return categories.where((item) {
      if (item.name.toLowerCase().contains(normalizedQuery)) {
        return true;
      }

      return item.transactions.any((transaction) {
        return transaction.title.toLowerCase().contains(normalizedQuery) ||
            transaction.category.toLowerCase().contains(normalizedQuery);
      });
    });
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final baseTheme = Theme.of(context);
    final colors = baseTheme.colorScheme;
    return baseTheme.copyWith(
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: colors.textTertiary),
      ),
      textTheme: baseTheme.textTheme.apply(bodyColor: colors.onSurface),
    );
  }

  @override
  String get searchFieldLabel => 'reportSearchHint'.tr();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: const Icon(Icons.close_rounded),
        ),
      IconButton(
        onPressed: () => close(context, query.trim()),
        icon: const Icon(Icons.check_rounded),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResultList(context);
  }

  Widget _buildResultList(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final results = _matchResults(query).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'reportNoSearchResults'.tr(),
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 15,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: results.length,
      separatorBuilder: (_, __) => Divider(
        color: colors.subtleDivider,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          onTap: () => close(context, query.trim().isEmpty ? item.name : query),
          title: Text(
            item.name,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            '${item.transactions.length} ${'reportTransactionsLabel'.tr()}',
            style: TextStyle(color: colors.textSecondary),
          ),
          trailing: Text(
            formatAmount(item.amount),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }
}
