import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../database/database_helper.dart';
import '../../models/transaction.dart';
import '../input_screen/input_controller.dart';
import '../input_screen/input_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    this.transactionLoader,
    this.initialDay,
  });

  final Future<List<Transaction>> Function()? transactionLoader;
  final DateTime? initialDay;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static final NumberFormat _amountFormatter =
      NumberFormat.decimalPattern('vi_VN');
  static final DateFormat _dayHeaderFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _dayOfWeekFormatter = DateFormat('EEE', 'vi_VN');

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Map<DateTime, double> _dailyBalances = <DateTime, double>{};
  final Map<DateTime, List<Transaction>> _transactionsByDay =
      <DateTime, List<Transaction>>{};

  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final today = _normalizeDay(widget.initialDay ?? DateTime.now());
    _focusedDay = today;
    _selectedDay = today;
    _loadCalendarData();
  }

  Future<void> _loadCalendarData() async {
    try {
      final transactions = await (widget.transactionLoader?.call() ??
          _dbHelper.getTransactions());
      final balances = <DateTime, double>{};
      final transactionsByDay = <DateTime, List<Transaction>>{};

      for (final transaction in transactions) {
        final dateKey = _normalizeDay(transaction.date);
        final signedAmount = _toSignedAmount(transaction);

        balances.update(
          dateKey,
          (currentTotal) => currentTotal + signedAmount,
          ifAbsent: () => signedAmount,
        );
        transactionsByDay.putIfAbsent(dateKey, () => <Transaction>[]).add(
              transaction,
            );
      }

      for (final dayTransactions in transactionsByDay.values) {
        dayTransactions.sort((a, b) => a.date.compareTo(b.date));
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _dailyBalances
          ..clear()
          ..addAll(balances);
        _transactionsByDay
          ..clear()
          ..addAll(transactionsByDay);
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('CalendarScreen._loadCalendarData failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  DateTime _normalizeDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  double _toSignedAmount(Transaction transaction) {
    return transaction.type == 'income'
        ? transaction.amount
        : -transaction.amount;
  }

  double _balanceForDay(DateTime day) {
    return _dailyBalances[_normalizeDay(day)] ?? 0;
  }


  /// Tất cả giao dịch trong tháng của [month], sắp xếp mới nhất trước.
  List<Transaction> _transactionsForMonth(DateTime month) {
    final result = <Transaction>[];
    for (final entry in _transactionsByDay.entries) {
      if (entry.key.year == month.year && entry.key.month == month.month) {
        result.addAll(entry.value);
      }
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  String _formatCompactAmount(double amount) {
    final sign = amount < 0
        ? '-'
        : amount > 0
            ? '+'
            : '';
    final formattedAmount = _amountFormatter.format(amount.abs().round());
    return '$sign$formattedAmountđ';
  }

  Color _amountColor(double amount) {
    if (amount > 0) {
      return Colors.green.shade400;
    }

    if (amount < 0) {
      return Colors.red.shade300;
    }

    return Colors.grey.shade500;
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day, {
    required bool isOutside,
    bool isSelected = false,
    bool isToday = false,
  }) {
    final balance = _balanceForDay(day);
    final amountColor = isOutside
        ? _amountColor(balance).withOpacity(0.55)
        : _amountColor(balance);
    final borderColor = isSelected
        ? Colors.blue.shade300
        : isToday
            ? Colors.lightBlue.shade200
            : Colors.white.withOpacity(isOutside ? 0.08 : 0.12);
    final backgroundColor = isSelected
        ? Colors.blue.withOpacity(0.18)
        : isToday
            ? Colors.lightBlue.withOpacity(0.1)
            : Colors.white.withOpacity(isOutside ? 0.02 : 0.04);
    final dayTextColor = isSelected
        ? Colors.white
        : isOutside
            ? Colors.grey.shade600
            : Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact =
              constraints.maxWidth < 38 || constraints.maxHeight < 38;
          final dayFontSize = isCompact ? 12.0 : 15.0;
          final amountFontSize = isCompact ? 8.0 : 11.0;

          return Padding(
            padding: EdgeInsets.all(isCompact ? 2 : 4),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: dayTextColor,
                      fontSize: dayFontSize,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatCompactAmount(balance),
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: amountColor,
                        fontSize: amountFontSize,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- Transaction card (no time subtitle) ----------
  Widget _buildTransactionCard(Transaction transaction) {
    final isIncome = transaction.type == 'income';
    final signedAmount = _toSignedAmount(transaction);
    final amountColor = isIncome ? Colors.green.shade400 : Colors.red.shade300;
    final note = transaction.title.trim();

    return GestureDetector(
      onTap: () => _openEditScreen(transaction),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: amountColor.withOpacity(0.18),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: amountColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      note,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _formatCompactAmount(signedAmount),
              style: TextStyle(
                color: amountColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens InputScreen pre-loaded with [transaction] for editing.
  Future<void> _openEditScreen(Transaction transaction) async {
    final controller =
        Provider.of<InputController>(context, listen: false);
    controller.loadForEdit(transaction);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider<InputController>.value(
          value: controller,
          child: const InputScreen(),
        ),
      ),
    );

    // After returning, reset and reload calendar data.
    controller.resetToCreateMode();
    await _loadCalendarData();
  }

  // ---------- Day header row ----------
  Widget _buildDayHeader(DateTime day) {
    final balance = _balanceForDay(day);
    final balanceColor = _amountColor(balance);
    final dayLabel =
        '${_dayHeaderFormatter.format(day)} (${_dayOfWeekFormatter.format(day)})';

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Row(
        children: [
          Text(
            dayLabel,
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            _formatCompactAmount(balance),
            style: TextStyle(
              color: balanceColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Grouped transaction list ----------
  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Collect days that belong to the focused month, sorted newest first.
    final days = _transactionsByDay.keys
        .where((d) =>
            d.year == _focusedDay.year && d.month == _focusedDay.month)
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (days.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.event_note_rounded,
            size: 40,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Không có giao dịch trong tháng này.',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }

    // Build flat list of items: header + transactions per day.
    final items = <_ListItem>[];
    for (final day in days) {
      items.add(_DayHeaderItem(day));
      final txs = _transactionsByDay[day]!;
      // Within a day show newest first.
      final sorted = txs.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      for (final tx in sorted) {
        items.add(_TransactionItem(tx));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is _DayHeaderItem) {
          return _buildDayHeader(item.day);
        } else if (item is _TransactionItem) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildTransactionCard(item.transaction),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final rowHeight = constraints.maxWidth / 7;

                  return TableCalendar<Transaction>(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(3000, 1, 1),
                    focusedDay: _focusedDay,
                    currentDay: _normalizeDay(DateTime.now()),
                    locale: 'vi_VN',
                    calendarFormat: CalendarFormat.month,
                    availableGestures: AvailableGestures.horizontalSwipe,
                    sixWeekMonthsEnforced: true,
                    rowHeight: rowHeight,
                    daysOfWeekHeight: 28,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: true,
                      isTodayHighlighted: false,
                      cellMargin: EdgeInsets.zero,
                      cellPadding: EdgeInsets.zero,
                      defaultDecoration: BoxDecoration(),
                      outsideDecoration: BoxDecoration(),
                      todayDecoration: BoxDecoration(),
                      selectedDecoration: BoxDecoration(),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Colors.grey.shade300,
                        fontWeight: FontWeight.w600,
                      ),
                      weekendStyle: TextStyle(
                        color: Colors.red.shade200,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders<Transaction>(
                      defaultBuilder: (context, day, focusedDay) {
                        return _buildDayCell(
                          context,
                          day,
                          isOutside: day.month != focusedDay.month,
                        );
                      },
                      outsideBuilder: (context, day, focusedDay) {
                        return _buildDayCell(
                          context,
                          day,
                          isOutside: true,
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return _buildDayCell(
                          context,
                          day,
                          isOutside: day.month != focusedDay.month,
                          isToday: true,
                        );
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        return _buildDayCell(
                          context,
                          day,
                          isOutside: day.month != focusedDay.month,
                          isSelected: true,
                        );
                      },
                    ),
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = _normalizeDay(selectedDay);
                        _focusedDay = _normalizeDay(focusedDay);
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = _normalizeDay(focusedDay);
                      });
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiết tháng ${DateFormat('MM/yyyy').format(_focusedDay)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_transactionsForMonth(_focusedDay).length} giao dịch',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildTransactionList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper sealed classes for the grouped list
// ---------------------------------------------------------------------------

sealed class _ListItem {}

final class _DayHeaderItem extends _ListItem {
  _DayHeaderItem(this.day);
  final DateTime day;
}

final class _TransactionItem extends _ListItem {
  _TransactionItem(this.transaction);
  final Transaction transaction;
}
