import 'package:bokku_mart/core/providers/riverpod_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _testValueProvider = Provider<int>((ref) => 42);

void main() {
  testWidgets('RiverpodBuilder renders a watched provider', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RiverpodBuilder<int>(
              provider: _testValueProvider,
              builder: (context, value) => Text('value: $value'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('value: 42'), findsOneWidget);
  });
}
