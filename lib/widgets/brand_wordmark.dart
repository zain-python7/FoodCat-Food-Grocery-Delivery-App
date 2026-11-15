import 'package:flutter/material.dart';

const foodCatPink = Color(0xFFE21B70);
const foodCatInk = Color(0xFF29232D);

class FoodCatWordmark extends StatelessWidget {
  final double fontSize;
  const FoodCatWordmark({super.key, this.fontSize = 23});

  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900, letterSpacing: -1),
      children: const [
        TextSpan(text: 'food', style: TextStyle(color: foodCatInk)),
        TextSpan(text: 'cat', style: TextStyle(color: foodCatPink)),
      ],
    ),
  );
}
