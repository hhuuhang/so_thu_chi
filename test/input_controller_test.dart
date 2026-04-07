import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:so_thu_chi/screens/input_screen/input_controller.dart';

void main() {
  testWidgets(
    'allows saving a transaction when note is empty',
    (tester) async {
      final savedTitles = <String>[];
      final controller = InputController(
        insertTransaction: (transaction) async {
          savedTitles.add(transaction.title);
          return 1;
        },
      );

      late BuildContext capturedContext;

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  capturedContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      controller.titleController.text = '';
      controller.amountController.text = '160000';

      await controller.addTransaction(capturedContext);
      await tester.pump();

      expect(savedTitles, ['']);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(controller.amountController.text, '0');
      expect(controller.titleController.text, isEmpty);
    },
  );
}
