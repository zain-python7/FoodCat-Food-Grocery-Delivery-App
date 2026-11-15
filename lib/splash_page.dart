import 'dart:async';
import 'package:flutter/material.dart';
import 'core/art.dart';
import 'core/data.dart';
import 'core/theme.dart';
import 'core/ui.dart';
import 'role_page.dart';

/// One-second splash with a smooth logo reveal.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) Navigator.of(context).pushReplacement(fadeRoute<void>(const RolePage()));
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    c.dispose();
    super.dispose();
  }

  Animation<double> _iv(double a, double b, [Curve curve = Curves.easeOutCubic]) => CurvedAnimation(parent: c, curve: Interval(a, b, curve: curve));

  @override
  Widget build(BuildContext context) {
    final logo = _iv(0.0, 0.6, Curves.easeOutBack);
    final word = _iv(0.25, 0.8);
    final tag = _iv(0.5, 1.0);
    return Scaffold(
      backgroundColor: C.orange,
      body: Container(
        decoration: const BoxDecoration(gradient: C.hero),
        child: Stack(children: [
          Positioned(top: -90, right: -70, child: Container(width: 260, height: 260, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
          Positioned(bottom: -110, left: -80, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.4, end: 1).animate(logo),
                child: FadeTransition(
                  opacity: _iv(0.0, 0.4),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 30, offset: const Offset(0, 14))]),
                    child: const ClipOval(child: FoodArt(Art.burger, radius: 0, bg: Colors.white, scale: 1.05)),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              FadeTransition(
                opacity: word,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(word),
                  child: const Text('foodie', style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
                ),
              ),
              const SizedBox(height: 6),
              FadeTransition(opacity: tag, child: const Text('GOOD FOOD. GOOD MOOD. DELIVERED.', style: TextStyle(color: Color(0xFFFFE9E0), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.6))),
            ]),
          ),
        ]),
      ),
    );
  }
}
