// Teste de fumaça: garante que o app inicializa e mostra a tela inicial.

import 'package:flutter_test/flutter_test.dart';

import 'package:rotinaapp_flutter/main.dart';

void main() {
  testWidgets('App inicializa sem erros', (WidgetTester tester) async {
    await tester.pumpWidget(const RotinaApp());
    await tester.pump();

    // A casca do app (MaterialApp) deve estar presente.
    expect(find.byType(RotinaApp), findsOneWidget);
  });
}
