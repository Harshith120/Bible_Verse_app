import 'package:bible_verse_app/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ErrorView displays error message and triggers onRetry on button click', (WidgetTester tester) async {
    bool retryPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: 'No internet connection',
            onRetry: () {
              retryPressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Oops! Something went wrong'), findsOneWidget);
    expect(find.text('No internet connection'), findsOneWidget);
    expect(find.byKey(const Key('retry_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('retry_button')));
    await tester.pump();

    expect(retryPressed, isTrue);
  });
}
