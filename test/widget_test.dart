import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:northwind_mobile/core/widgets/charts.dart';

void main() {
  testWidgets('SimpleBarChart muestra las etiquetas de datos',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SimpleBarChart(
            data: [
              BarDatum('Ene', 10),
              BarDatum('Feb', 20),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Ene'), findsOneWidget);
    expect(find.text('Feb'), findsOneWidget);
  });

  testWidgets('SimpleBarChart muestra mensaje vacío sin datos',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SimpleBarChart(data: []),
        ),
      ),
    );

    expect(find.text('Sin datos para graficar.'), findsOneWidget);
  });
}
