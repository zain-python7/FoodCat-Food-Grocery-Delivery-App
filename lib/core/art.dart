import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'data.dart';
import 'theme.dart';

const _artBg = {
  Art.burger: Color(0xFFFFE5D8),
  Art.chicken: Color(0xFFFFE9CF),
  Art.pizza: Color(0xFFFFE3D2),
  Art.fries: Color(0xFFFFEBD0),
  Art.biryani: Color(0xFFFFE8C9),
  Art.drink: Color(0xFFFFE0D4),
  Art.dessert: Color(0xFFFFE1E3),
  Art.noodles: Color(0xFFFFE6CB),
};

/// Food illustration drawn with vectors (no image downloads needed).
class FoodArt extends StatelessWidget {
  final Art kind;
  final double? size;
  final double radius;
  final Color? bg;
  final double scale;
  const FoodArt(this.kind, {super.key, this.size, this.radius = 18, this.bg, this.scale = 1});
  @override
  Widget build(BuildContext context) {
    final color = bg ?? _artBg[kind]!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
      child: CustomPaint(painter: _ArtPainter(kind, color, scale)),
    );
  }
}

class _ArtPainter extends CustomPainter {
  final Art kind;
  final Color bg;
  final double scale;
  _ArtPainter(this.kind, this.bg, this.scale);

  Paint _p(Color c) => Paint()..color = c..style = PaintingStyle.fill;
  Paint _s(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) * scale;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    // Everything is drawn in a -0.5..0.5 box scaled by s.
    canvas.scale(s, s);
    switch (kind) {
      case Art.burger:
        _burger(canvas, false);
        break;
      case Art.chicken:
        _burger(canvas, true);
        break;
      case Art.pizza:
        _pizza(canvas);
        break;
      case Art.fries:
        _fries(canvas);
        break;
      case Art.biryani:
        _bowl(canvas, rice: true);
        break;
      case Art.noodles:
        _bowl(canvas, rice: false);
        break;
      case Art.drink:
        _drink(canvas);
        break;
      case Art.dessert:
        _donut(canvas);
        break;
    }
    canvas.restore();
  }

  void _shadow(Canvas c, double w, double y) {
    c.drawOval(Rect.fromCenter(center: Offset(0, y), width: w, height: 0.075), _p(const Color(0x40C9A18D)));
  }

  void _burger(Canvas c, bool chicken) {
    _shadow(c, 0.56, 0.27);
    // bottom bun
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.26, 0.15, 0.52, 0.1), const Radius.circular(0.05)), _p(const Color(0xFFE9A94F)));
    // patty
    final patty = Path()
      ..moveTo(-0.28, 0.06)
      ..quadraticBezierTo(-0.30, 0.17, 0, 0.17)
      ..quadraticBezierTo(0.30, 0.17, 0.28, 0.06)
      ..close();
    c.drawPath(patty, _p(chicken ? const Color(0xFFD98A3D) : const Color(0xFF9B542F)));
    // cheese
    final cheese = Path()
      ..moveTo(-0.27, 0.02)
      ..lineTo(0.27, 0.02)
      ..lineTo(0.27, 0.07)
      ..lineTo(0.12, 0.07)
      ..lineTo(0.09, 0.13)
      ..lineTo(0.06, 0.07)
      ..lineTo(-0.27, 0.07)
      ..close();
    c.drawPath(cheese, _p(const Color(0xFFF3C45E)));
    // lettuce
    final lettuce = Path()..moveTo(-0.28, 0.0);
    for (var i = 0; i < 7; i++) {
      final x0 = -0.28 + i * 0.08;
      lettuce.quadraticBezierTo(x0 + 0.02, 0.05, x0 + 0.04, 0.0);
      lettuce.quadraticBezierTo(x0 + 0.06, -0.035, x0 + 0.08, 0.0);
    }
    lettuce
      ..lineTo(0.28, -0.04)
      ..lineTo(-0.28, -0.04)
      ..close();
    c.drawPath(lettuce, _p(const Color(0xFF68A65C)));
    // tomato
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.25, -0.075, 0.5, 0.04), const Radius.circular(0.02)), _p(const Color(0xFFE5484D)));
    // top bun
    final top = Path()
      ..moveTo(-0.27, -0.07)
      ..cubicTo(-0.30, -0.36, 0.30, -0.36, 0.27, -0.07)
      ..close();
    c.drawPath(top, _p(const Color(0xFFE9A94F)));
    c.drawPath(
      Path()
        ..moveTo(-0.17, -0.12)
        ..quadraticBezierTo(0, -0.19, 0.17, -0.12),
      _s(const Color(0xFFF9D98C), 0.03),
    );
    for (final p in const [Offset(-0.1, -0.2), Offset(0.0, -0.23), Offset(0.1, -0.2), Offset(-0.05, -0.15), Offset(0.06, -0.15)]) {
      c.drawOval(Rect.fromCenter(center: p, width: 0.04, height: 0.022), _p(const Color(0xFFFFF0C4)));
    }
  }

  void _pizza(Canvas c) {
    _shadow(c, 0.62, 0.3);
    c.drawCircle(const Offset(0, 0.02), 0.3, _p(const Color(0xFFE2A04A)));
    c.drawCircle(const Offset(0, 0.02), 0.26, _p(const Color(0xFFF6D27A)));
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + 0.2;
      c.drawLine(const Offset(0, 0.02), Offset(math.cos(a) * 0.26, 0.02 + math.sin(a) * 0.26), _s(const Color(0x33C98A3C), 0.008));
    }
    const pep = [Offset(-0.1, -0.08), Offset(0.1, -0.07), Offset(0.0, 0.05), Offset(-0.14, 0.1), Offset(0.14, 0.11), Offset(0.0, -0.17), Offset(0.02, 0.18)];
    for (final p in pep) {
      c.drawCircle(p.translate(0, 0.02), 0.04, _p(const Color(0xFFC8402F)));
      c.drawCircle(p.translate(-0.01, 0.01), 0.012, _p(const Color(0x55FFFFFF)));
    }
    for (final p in const [Offset(-0.05, -0.02), Offset(0.15, 0.02), Offset(-0.18, 0.0)]) {
      c.drawOval(Rect.fromCenter(center: p, width: 0.045, height: 0.025), _p(const Color(0xFF4FA55B)));
    }
  }

  void _fries(Canvas c) {
    _shadow(c, 0.5, 0.29);
    const cols = [Color(0xFFF3C45E), Color(0xFFEDB546), Color(0xFFF7D372)];
    const xs = [-0.15, -0.09, -0.03, 0.03, 0.09, 0.15];
    const hs = [0.26, 0.32, 0.22, 0.34, 0.25, 0.3];
    for (var i = 0; i < xs.length; i++) {
      c.save();
      c.translate(xs[i], 0.0);
      c.rotate((i - 2.5) * 0.06);
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-0.025, -hs[i] + 0.08, 0.05, hs[i]), const Radius.circular(0.012)), _p(cols[i % 3]));
      c.restore();
    }
    final box = Path()
      ..moveTo(-0.2, 0.0)
      ..lineTo(0.2, 0.0)
      ..lineTo(0.16, 0.26)
      ..lineTo(-0.16, 0.26)
      ..close();
    c.drawPath(box, _p(const Color(0xFFE5484D)));
    c.drawPath(
      Path()
        ..moveTo(-0.05, 0.0)
        ..lineTo(0.05, 0.0)
        ..lineTo(0.04, 0.26)
        ..lineTo(-0.04, 0.26)
        ..close(),
      _p(const Color(0xFFFFF3E6)),
    );
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.21, -0.015, 0.42, 0.04), const Radius.circular(0.02)), _p(const Color(0xFFC93A3F)));
  }

  void _bowl(Canvas c, {required bool rice}) {
    _shadow(c, 0.6, 0.28);
    if (rice) {
      final mound = Path()
        ..moveTo(-0.26, 0.04)
        ..cubicTo(-0.24, -0.26, 0.24, -0.26, 0.26, 0.04)
        ..close();
      c.drawPath(mound, _p(const Color(0xFFF3D9A0)));
      const dots = [Offset(-0.12, -0.04), Offset(0.0, -0.1), Offset(0.12, -0.03), Offset(-0.04, 0.0), Offset(0.07, 0.0)];
      for (var i = 0; i < dots.length; i++) {
        c.drawCircle(dots[i], 0.022, _p(i.isEven ? const Color(0xFFE67E3C) : const Color(0xFF68A65C)));
      }
    } else {
      for (var i = 0; i < 6; i++) {
        final y = -0.13 + i * 0.03;
        final p = Path()..moveTo(-0.24, y + 0.05);
        p.cubicTo(-0.12, y - 0.07, 0.0, y + 0.1, 0.12, y - 0.03);
        p.quadraticBezierTo(0.18, y - 0.07, 0.24, y + 0.05);
        c.drawPath(p, _s(i.isEven ? const Color(0xFFF3C45E) : const Color(0xFFE9AE45), 0.026));
      }
      c.drawCircle(const Offset(-0.08, -0.07), 0.025, _p(const Color(0xFF68A65C)));
      c.drawCircle(const Offset(0.1, -0.03), 0.022, _p(const Color(0xFFE5484D)));
      c.drawLine(const Offset(0.1, -0.3), const Offset(0.2, 0.0), _s(const Color(0xFF9B542F), 0.018));
      c.drawLine(const Offset(0.15, -0.3), const Offset(0.24, 0.0), _s(const Color(0xFF9B542F), 0.018));
    }
    final bowl = Path()
      ..moveTo(-0.3, 0.04)
      ..lineTo(0.3, 0.04)
      ..quadraticBezierTo(0.27, 0.27, 0, 0.27)
      ..quadraticBezierTo(-0.27, 0.27, -0.3, 0.04)
      ..close();
    c.drawPath(bowl, _p(const Color(0xFF2F6FB2)));
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.31, 0.02, 0.62, 0.045), const Radius.circular(0.022)), _p(const Color(0xFF3F86CF)));
    if (rice) {
      for (var i = 0; i < 3; i++) {
        final x = -0.09 + i * 0.09;
        final p = Path()
          ..moveTo(x, -0.2)
          ..quadraticBezierTo(x - 0.03, -0.25, x, -0.3)
          ..quadraticBezierTo(x + 0.03, -0.35, x, -0.38);
        c.drawPath(p, _s(const Color(0x55A89C94), 0.014));
      }
    }
  }

  void _drink(Canvas c) {
    _shadow(c, 0.42, 0.3);
    // straw
    c.drawLine(const Offset(0.05, -0.34), const Offset(0.01, -0.06), _s(C.orange, 0.04));
    // cup
    final cup = Path()
      ..moveTo(-0.17, -0.1)
      ..lineTo(0.17, -0.1)
      ..lineTo(0.13, 0.29)
      ..lineTo(-0.13, 0.29)
      ..close();
    c.drawPath(cup, _p(const Color(0xFFFFFFFF)));
    // coffee layers
    c.save();
    c.clipPath(cup);
    c.drawRect(const Rect.fromLTWH(-0.2, 0.0, 0.4, 0.3), _p(const Color(0xFFB9784A)));
    c.drawRect(const Rect.fromLTWH(-0.2, -0.1, 0.4, 0.1), _p(const Color(0xFFF4E3D0)));
    c.drawRect(const Rect.fromLTWH(-0.2, 0.12, 0.4, 0.2), _p(const Color(0xFF8A5030)));
    c.restore();
    // ice cubes
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.08, -0.06, 0.07, 0.07), const Radius.circular(0.015)), _p(const Color(0x88FFFFFF)));
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.02, -0.03, 0.06, 0.06), const Radius.circular(0.015)), _p(const Color(0x77FFFFFF)));
    // lid
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.2, -0.14, 0.4, 0.05), const Radius.circular(0.025)), _p(C.orange));
    // sleeve
    c.drawPath(
      Path()
        ..moveTo(-0.153, 0.08)
        ..lineTo(0.153, 0.08)
        ..lineTo(0.143, 0.18)
        ..lineTo(-0.143, 0.18)
        ..close(),
      _p(const Color(0xCCFF653D)),
    );
  }

  void _donut(Canvas c) {
    _shadow(c, 0.56, 0.27);
    c.drawCircle(const Offset(0, 0.03), 0.27, _p(const Color(0xFFE9A94F)));
    c.drawCircle(const Offset(0, 0.0), 0.27, _p(const Color(0xFFF58FB0)));
    c.drawCircle(const Offset(0, 0.0), 0.095, _p(bg));
    const sp = [Offset(-0.16, -0.12), Offset(0.12, -0.17), Offset(0.19, 0.02), Offset(-0.19, 0.05), Offset(0.02, 0.2), Offset(-0.09, 0.17), Offset(0.12, 0.15), Offset(-0.03, -0.2)];
    const cs = [Color(0xFFFFFFFF), Color(0xFFFFE066), Color(0xFF5BC0EB), Color(0xFFFFFFFF)];
    for (var i = 0; i < sp.length; i++) {
      c.save();
      c.translate(sp[i].dx, sp[i].dy);
      c.rotate(i * 0.9);
      c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.02, -0.006, 0.04, 0.012), const Radius.circular(0.006)), _p(cs[i % 4]));
      c.restore();
    }
    c.drawArc(Rect.fromCircle(center: const Offset(0, 0), radius: 0.22), 3.6, 1.0, false, _s(const Color(0x66FFFFFF), 0.02));
  }

  @override
  bool shouldRepaint(covariant _ArtPainter old) => old.kind != kind || old.bg != bg || old.scale != scale;
}

// ---------------------------------------------------------------------------
// Map mock used by tracking and rider navigation
// ---------------------------------------------------------------------------
class MapView extends StatefulWidget {
  final double height;
  final double? progress; // null = loops continuously
  final BorderRadius radius;
  const MapView({super.key, this.height = 300, this.progress, this.radius = BorderRadius.zero});
  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: widget.radius,
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: c,
            builder: (_, __) => CustomPaint(painter: _MapPainter(widget.progress ?? Curves.easeInOut.transform(c.value), c.value)),
          ),
        ),
      );
}

class _MapPainter extends CustomPainter {
  final double t;
  final double pulse;
  _MapPainter(this.t, this.pulse);

  static const _route = [Offset(0.14, 0.82), Offset(0.14, 0.56), Offset(0.46, 0.56), Offset(0.46, 0.3), Offset(0.84, 0.3)];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF4EEE8));
    // blocks
    final block = Paint()..color = const Color(0xFFE9E1D9);
    final park = Paint()..color = const Color(0xFFD8EBD3);
    for (var i = 0; i < 4; i++) {
      for (var j = 0; j < 5; j++) {
        final r = Rect.fromLTWH(w * (0.03 + j * 0.2), h * (0.04 + i * 0.25), w * 0.15, h * 0.18);
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(10)), (i + j) % 7 == 3 ? park : block);
      }
    }
    // roads
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    for (final x in const [0.11, 0.31, 0.51, 0.71, 0.91]) {
      canvas.drawLine(Offset(w * x, 0), Offset(w * x, h), road);
    }
    for (final y in const [0.225, 0.475, 0.725]) {
      canvas.drawLine(Offset(0, h * y), Offset(w, y * h), road);
    }
    // route
    final pts = [for (final p in _route) Offset(p.dx * w, p.dy * h)];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, Paint()..color = C.orange.withOpacity(0.22)..style = PaintingStyle.stroke..strokeWidth = 10..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round);
    final metric = path.computeMetrics().first;
    final len = metric.length;
    canvas.drawPath(metric.extractPath(0, len * t), Paint()..color = C.orange..style = PaintingStyle.stroke..strokeWidth = 5..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round);
    // restaurant + home pins
    _pin(canvas, pts.first, const Color(0xFF222B3A), Icons.storefront_rounded);
    _pin(canvas, pts.last, C.green, Icons.home_rounded);
    // rider
    final tan = metric.getTangentForOffset(len * t);
    if (tan != null) {
      final r = 16 + 7 * math.sin(pulse * math.pi * 2).abs();
      canvas.drawCircle(tan.position, r, Paint()..color = C.orange.withOpacity(0.16));
      canvas.drawCircle(tan.position, 13, Paint()..color = Colors.white);
      canvas.drawCircle(tan.position, 9, Paint()..color = C.orange);
      _icon(canvas, tan.position, Icons.two_wheeler_rounded, 13, Colors.white);
    }
  }

  void _pin(Canvas canvas, Offset o, Color color, IconData icon) {
    canvas.drawCircle(o.translate(0, 3), 17, Paint()..color = const Color(0x33000000));
    canvas.drawCircle(o, 17, Paint()..color = Colors.white);
    canvas.drawCircle(o, 13, Paint()..color = color);
    _icon(canvas, o, icon, 15, Colors.white);
  }

  void _icon(Canvas canvas, Offset o, IconData icon, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: String.fromCharCode(icon.codePoint), style: TextStyle(fontSize: size, fontFamily: icon.fontFamily, package: icon.fontPackage, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, o - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.t != t || old.pulse != pulse;
}

// ---------------------------------------------------------------------------
// Charts
// ---------------------------------------------------------------------------
class LineChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height;
  final bool light;
  const LineChart(this.values, {super.key, this.color = C.orange, this.height = 140, this.light = false});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1300),
        curve: Curves.easeOutCubic,
        builder: (_, t, __) => SizedBox(height: height, width: double.infinity, child: CustomPaint(painter: _LinePainter(values, color, t, light))),
      );
}

class _LinePainter extends CustomPainter {
  final List<double> v;
  final Color color;
  final double t;
  final bool light;
  _LinePainter(this.v, this.color, this.t, this.light);
  @override
  void paint(Canvas canvas, Size size) {
    if (v.length < 2) return;
    final mx = v.reduce(math.max), mn = v.reduce(math.min);
    final span = (mx - mn) == 0 ? 1.0 : (mx - mn);
    final pts = <Offset>[
      for (var i = 0; i < v.length; i++) Offset(size.width * i / (v.length - 1), size.height * 0.1 + (size.height * 0.78) * (1 - (v[i] - mn) / span)),
    ];
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final mid = (pts[i].dx + pts[i + 1].dx) / 2;
      line.cubicTo(mid, pts[i].dy, mid, pts[i + 1].dy, pts[i + 1].dx, pts[i + 1].dy);
    }
    final area = Path.from(line)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * t, size.height));
    canvas.drawPath(area, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color.withOpacity(light ? 0.35 : 0.28), color.withOpacity(0)]).createShader(Offset.zero & size));
    canvas.drawPath(line, Paint()..color = light ? Colors.white : color..style = PaintingStyle.stroke..strokeWidth = 3.2..strokeCap = StrokeCap.round);
    canvas.restore();
    final last = pts.last;
    if (t > 0.98) {
      canvas.drawCircle(last, 6, Paint()..color = Colors.white);
      canvas.drawCircle(last, 4, Paint()..color = light ? Colors.white : color);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => old.t != t || old.v != v || old.color != color;
}

class BarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final double height;
  const BarChart(this.values, this.labels, {super.key, this.color = C.orange, this.height = 150});
  @override
  Widget build(BuildContext context) {
    final mx = values.reduce(math.max);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (_, t, __) => SizedBox(
        height: height,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: math.max(0.04, values[i] / mx * t),
                      child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color, color.withOpacity(0.55)]), borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(labels[i], style: const TextStyle(fontSize: 10.5, color: C.muted, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Animated tick that draws itself.
class DrawCheck extends StatelessWidget {
  final double size;
  final Color color;
  const DrawCheck({super.key, this.size = 110, this.color = C.green});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (_, t, __) => Transform.scale(
          scale: 0.6 + 0.4 * Curves.elasticOut.transform(math.min(1, t * 1.15)),
          child: SizedBox(width: size, height: size, child: CustomPaint(painter: _CheckPainter(t, color))),
        ),
      );
}

class _CheckPainter extends CustomPainter {
  final double t;
  final Color color;
  _CheckPainter(this.t, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, size.width / 2, Paint()..color = color.withOpacity(0.14));
    canvas.drawCircle(c, size.width / 2 * 0.78, Paint()..color = color);
    final p = Path()
      ..moveTo(size.width * 0.31, size.height * 0.52)
      ..lineTo(size.width * 0.45, size.height * 0.66)
      ..lineTo(size.width * 0.71, size.height * 0.37);
    final m = p.computeMetrics().first;
    final draw = clamp((t - 0.25) / 0.55);
    canvas.drawPath(m.extractPath(0, m.length * draw), Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = size.width * 0.075..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
  }

  double clamp(double v) => math.max(0, math.min(1, v));
  @override
  bool shouldRepaint(covariant _CheckPainter old) => old.t != t;
}
