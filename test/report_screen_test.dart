import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:so_thu_chi/models/transaction.dart';
import 'package:so_thu_chi/screens/report_screen/report_controller.dart';
import 'package:so_thu_chi/screens/report_screen/report_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    await initializeDateFormatting('vi_VN');
  });

  testWidgets('report screen renders new layout and applies search filter',
      (tester) async {
    final controller = ReportController(
      initialDate: DateTime(2026, 4, 15),
      transactionLoader: () async => <Transaction>[
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
          title: 'đi tàu',
          amount: 64000,
          date: DateTime(2026, 4, 9, 8, 0),
          type: 'expense',
          category: 'Đi lại',
        ),
        Transaction(
          id: 3,
          title: 'lương tháng 4',
          amount: 5000000,
          date: DateTime(2026, 4, 1, 9, 0),
          type: 'income',
          category: 'Lương',
        ),
      ],
    );

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('vi'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('vi'),
        startLocale: const Locale('vi'),
        child: Builder(
          builder: (context) {
            return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: ThemeData.dark(),
              home: ReportScreen(controller: controller),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hàng Tháng'), findsOneWidget);
    expect(find.text('04/2026'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Tìm kiếm danh mục hoặc ghi chú'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'trưa');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('Kết quả cho'), findsOneWidget);
    expect(controller.searchQuery, 'trưa');
    expect(controller.activeBreakdown.map((item) => item.name), ['Ăn uống']);
  });
}
