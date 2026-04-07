import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:so_thu_chi/models/transaction.dart';
import 'package:so_thu_chi/screens/calendar_screen/calendar_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('vi_VN');
  });

  Future<void> pumpCalendarAtSize(
    WidgetTester tester,
    Size size,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final selectedDay = DateTime(2026, 4, 8);
    final transactions = <Transaction>[
      Transaction(
        id: 1,
        title: 'buffet',
        amount: 160000,
        date: DateTime(2026, 4, 8, 0, 10),
        type: 'expense',
        category: 'Ăn uống',
      ),
      Transaction(
        id: 2,
        title: 'thưởng quý',
        amount: 5000000,
        date: DateTime(2026, 4, 15, 8, 30),
        type: 'income',
        category: 'Thưởng',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: CalendarScreen(
          initialDay: selectedDay,
          transactionLoader: () async => transactions,
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets(
    'calendar screen renders without overflow on common phone widths',
    (tester) async {
      const screenSizes = <Size>[
        Size(320, 740),
        Size(360, 800),
        Size(393, 852),
        Size(430, 932),
      ];

      for (final size in screenSizes) {
        await pumpCalendarAtSize(tester, size);

        expect(find.byType(CalendarScreen), findsOneWidget);
        expect(find.text('Chi tiết thu chi 08/04/2026'), findsOneWidget);
        expect(find.text('Mục: Ăn uống'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'screen size $size');
      }
    },
  );
}
