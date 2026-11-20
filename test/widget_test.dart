import 'package:acuario_virtual/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Cambia la carga y el renderizado y permite pausar la escena', (tester) async {
    await tester.pumpWidget(const AcuarioApp());
    expect(find.textContaining('8 peces'), findsOneWidget);
    for (final nivel in ['Media', 'Alta']) {
      await tester.ensureVisible(find.text(nivel));
      await tester.tap(find.text(nivel));
      await tester.pump();
    }
    expect(find.textContaining('96 peces'), findsOneWidget);
    final optimizada = find.widgetWithText(ChoiceChip, 'Optimizada');
    await tester.ensureVisible(optimizada);
    await tester.tap(optimizada);
    await tester.pump();
    expect(tester.widget<ChoiceChip>(optimizada).selected, isTrue);
    final pausa = find.text('Pausar');
    await tester.ensureVisible(pausa);
    await tester.tap(pausa);
    await tester.pump();
    expect(find.text('Reanudar'), findsOneWidget);
    await tester.tap(find.byTooltip('Reiniciar escena'));
    await tester.pump();
    expect(find.text('Reanudar'), findsOneWidget);
    await tester.tap(find.text('Reanudar'));
    await tester.pump();
    expect(find.text('Pausar'), findsOneWidget);
  });
}
