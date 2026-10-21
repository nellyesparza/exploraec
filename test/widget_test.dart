import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exploraec/main.dart';

void main() {
  testWidgets('Pantalla de bienvenida muestra título y botón', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExploraEcApp());

    expect(find.text('ExploraEC'), findsOneWidget);
    expect(find.text('Descubre y guarda lugares cerca de ti'), findsOneWidget);
    expect(find.byIcon(Icons.explore_outlined), findsOneWidget);

    await tester.tap(find.text('Empezar'));
    await tester.pump();
    expect(find.text('¡Vamos a explorar!'), findsOneWidget);
  });
}
