import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kasirku/daftar_barang.dart';
import 'package:kasirku/logout.dart';

void main() {
  testWidgets('DaftarBarangPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DaftarBarangPage(),
      ),
    );

    expect(find.text('Daftar Barang'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
