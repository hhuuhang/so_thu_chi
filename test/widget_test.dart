import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:so_thu_chi/screens/input_screen/input_controller.dart';
import 'package:so_thu_chi/screens/input_screen/input_screen.dart';

void main() {
  testWidgets(
    'input flow renders with provider wiring',
    (WidgetTester tester) async {
      await initializeDateFormatting('vi_VN');

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => InputController(),
          child: const MaterialApp(
            home: InputScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(InputScreen), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Danh mục'), findsOneWidget);

      await tester.tap(find.text('Tiền thu'));
      await tester.pump();

      expect(find.text('Khác'), findsOneWidget);
    },
  );
}
