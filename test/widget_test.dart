import 'package:flutter_test/flutter_test.dart';
import 'package:foodcat/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodcat/data/cart_provider.dart';

void main() {
  testWidgets('FoodCat app renders', (tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(create: (_) => CartProvider(), child: const FoodCatApp()));
    expect(find.text('foodcat'), findsOneWidget);
  });
}
