import 'package:flutter_test/flutter_test.dart';

import 'package:bokku_driver_app/screens/driver_app.dart';

void main() {
  testWidgets('driver app shows a dedicated sign-in screen', (tester) async {
    await tester.pumpWidget(const BokkuDriverApp());
    await tester.pumpAndSettle();

    expect(find.text('Bokku Driver'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });
}
