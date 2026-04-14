import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../database/database_helper.dart';
import '../../models/transaction.dart';

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
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormatter = DateFormat('HH:mm');

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

  List<Transaction> _transactionsForDay(DateTime day) {
    return _transactionsByDay[_normalizeDay(day)] ?? const <Transaction>[];
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

  Widget _buildTransactionCard(Transaction transaction) {
    final isIncome = transaction.type == 'income';
    final signedAmount = _toSignedAmount(transaction);
    final amountColor = isIncome ? Colors.green.shade400 : Colors.red.shade300;
    final note = transaction.title.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: amountColor.withOpacity(0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: amountColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mục: ${transaction.category}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isIncome ? 'Thu' : 'Chi'} lúc ${_timeFormatter.format(transaction.date)}',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Ghi chú: $note',
                    style: TextStyle(
                      color: Colors.grey.shade200,
                      fontSize: 13,
                      height: 1.35,
                    ),
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
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final dayTransactions = _transactionsForDay(_selectedDay);

    if (dayTransactions.isEmpty) {
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
              'Không có giao dịch trong ngày này.',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: dayTransactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _buildTransactionCard(dayTransactions[index]);
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
                      'Chi tiết thu chi ${_dateFormatter.format(_selectedDay)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_transactionsForDay(_selectedDay).length} giao dịch',
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
