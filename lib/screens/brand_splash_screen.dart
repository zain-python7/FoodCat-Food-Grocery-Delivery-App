import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/foodcat_colors.dart';
import 'auth_screen.dart';

class BrandSplashScreen extends StatefulWidget {
  const BrandSplashScreen({super.key});
  @override
  State<BrandSplashScreen> createState() => _BrandSplashScreenState();
}

class _BrandSplashScreenState extends State<BrandSplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: FoodCatColors.background,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Image.asset('assets/branding/foodcat_splash.png', fit: BoxFit.contain)
          .animate().fadeIn(duration: 650.ms).scale(begin: const Offset(.92, .92), end: const Offset(1, 1), curve: Curves.easeOutBack),
      ),
    ),
  );
}
