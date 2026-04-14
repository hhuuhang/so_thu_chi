import 'package:flutter_test/flutter_test.dart';

import 'package:so_thu_chi/models/transaction.dart';
import 'package:so_thu_chi/screens/report_screen/report_controller.dart';

void main() {
  group('ReportController', () {
    final transactions = <Transaction>[
      Transaction(
        id: 1,
        title: 'ăn trưa',
        amount: 30000,
        date: DateTime(2026, 4, 8, 12, 30),
        type: 'expense',
        category: 'Ăn uống',
      ),
      Transaction(
        id: 2,
        title: 'đổ xăng',
        amount: 70000,
        date: DateTime(2026, 4, 10, 8, 0),
        type: 'expense',
        category: 'Xăng xe',
      ),
      Transaction(
        id: 3,
        title: 'lương tháng 4',
        amount: 5000000,
        date: DateTime(2026, 4, 1, 9, 0),
        type: 'income',
        category: 'Lương',
      ),
      Transaction(
        id: 4,
        title: 'thưởng quý',
        amount: 1200000,
        date: DateTime(2026, 2, 2, 9, 0),
        type: 'income',
        category: 'Thưởng',
      ),
    ];

    test('builds monthly and yearly summaries with search filtering', () async {
      final controller = ReportController(
        initialDate: DateTime(2026, 4, 15),
        transactionLoader: () async => transactions,
      );

      await controller.loadTransactions();

      expect(controller.periodTitle, '04/2026');
      expect(controller.expense, 100000);
      expect(controller.income, 5000000);
      expect(controller.balance, 4900000);
      expect(controller.activeBreakdown.map((item) => item.name), [
        'Xăng xe',
        'Ăn uống',
      ]);

      controller.setSearchQuery('trưa');
      expect(controller.activeBreakdown.map((item) => item.name), ['Ăn uống']);

      controller.clearSearchQuery();
      controller.setActiveType(ReportCategoryType.income);
      expect(controller.activeBreakdown.map((item) => item.name), ['Lương']);

      await controller.setRangeMode(ReportRangeMode.yearly);
      expect(controller.periodTitle, '2026');
      expect(controller.income, 6200000);
      expect(
        controller.activeBreakdown.map((item) => item.name),
        ['Lương', 'Thưởng'],
      );
    });
  });
}
