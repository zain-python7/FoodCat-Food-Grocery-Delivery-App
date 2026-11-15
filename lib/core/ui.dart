import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'data.dart';
import 'theme.dart';

// ---------- helpers ----------
String rs(num n) {
  final neg = n < 0;
  final s = n.abs().round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '${neg ? '- ' : ''}Rs. $b';
}

void toast(BuildContext c, String m) {
  final sm = ScaffoldMessenger.of(c);
  sm.hideCurrentSnackBar();
  sm.showSnackBar(SnackBar(content: Text(m), duration: const Duration(milliseconds: 2200)));
}

Route<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) {
        final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return FadeTransition(
          opacity: c,
          child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(c), child: child),
        );
      },
    );

Future<T?> go<T>(BuildContext c, Widget p) => Navigator.of(c).push<T>(fadeRoute<T>(p));
Future<void> goReplace(BuildContext c, Widget p) => Navigator.of(c).pushReplacement(fadeRoute<void>(p));
void goRoot(BuildContext c, Widget p) => Navigator.of(c).pushAndRemoveUntil(fadeRoute<void>(p), (_) => false);

String? vReq(String? v, String msg) => (v ?? '').trim().isEmpty ? msg : null;
String? vEmail(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Enter your email address';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(s)) return 'Enter a valid email address';
  return null;
}

String? vPhone(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Enter your phone number';
  final d = s.replaceAll(RegExp(r'\D'), '').length;
  if (!RegExp(r'^\+?[0-9\s\-()]+$').hasMatch(s) || d < 10 || d > 14) return 'Enter a valid phone number';
  return null;
}

String? vPass(String? v) {
  final s = v ?? '';
  if (s.isEmpty) return 'Enter your password';
  if (s.length < 6) return 'Password must be at least 6 characters';
  return null;
}

// ---------- animation primitives ----------
class Reveal extends StatelessWidget {
  final int i;
  final double dy;
  final Widget child;
  const Reveal({super.key, this.i = 0, this.dy = 24, required this.child});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: 420 + i * 70),
        curve: Curves.easeOutCubic,
        builder: (_, v, ch) => Opacity(opacity: v.clamp(0.0, 1.0), child: Transform.translate(offset: Offset(0, dy * (1 - v)), child: ch)),
        child: child,
      );
}

class Tap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const Tap({super.key, required this.child, this.onTap, this.scale = 0.96});
  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  bool down = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onTap == null ? null : (_) => setState(() => down = true),
        onTapUp: widget.onTap == null ? null : (_) => setState(() => down = false),
        onTapCancel: widget.onTap == null ? null : () => setState(() => down = false),
        onTap: widget.onTap,
        child: AnimatedScale(scale: down ? widget.scale : 1, duration: const Duration(milliseconds: 110), curve: Curves.easeOut, child: widget.child),
      );
}

/// Gentle floating motion for hero artwork.
class Floaty extends StatefulWidget {
  final Widget child;
  final double amount;
  const Floaty({super.key, required this.child, this.amount = 6});
  @override
  State<Floaty> createState() => _FloatyState();
}

class _FloatyState extends State<Floaty> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: c,
        builder: (_, ch) => Transform.translate(offset: Offset(0, -widget.amount * Curves.easeInOut.transform(c.value)), child: ch),
        child: widget.child,
      );
}

class CountUp extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final String Function(num)? fmt;
  const CountUp(this.value, {super.key, this.style, this.fmt});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.toDouble()),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => Text((fmt ?? rs)(v), style: style),
      );
}

// ---------- buttons & cards ----------
class GradBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading;
  final Gradient? gradient;
  final double h;
  const GradBtn(this.label, {super.key, this.onTap, this.icon, this.loading = false, this.gradient, this.h = 56});
  @override
  Widget build(BuildContext context) {
    final off = onTap == null && !loading;
    return Tap(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: off ? null : (gradient ?? C.hero),
          color: off ? C.line : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: off ? [] : [BoxShadow(color: (gradient == null ? C.orange : C.navy).withOpacity(0.28), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: loading
              ? const SizedBox(key: ValueKey('l'), width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Row(key: const ValueKey('t'), mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[Icon(icon, color: off ? C.faint : Colors.white, size: 20), const SizedBox(width: 8)],
                  Text(label, style: TextStyle(color: off ? C.faint : Colors.white, fontWeight: FontWeight.w800, fontSize: 15.5)),
                ]),
        ),
      ),
    );
  }
}

class OutBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color color;
  final double h;
  const OutBtn(this.label, {super.key, this.onTap, this.icon, this.color = C.orange, this.h = 52});
  @override
  Widget build(BuildContext context) => Tap(
        onTap: onTap,
        child: Container(
          height: h,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(0.35), width: 1.4)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, color: color, size: 19), const SizedBox(width: 8)],
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15)),
          ]),
        ),
      );
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final VoidCallback? onTap;
  final Color color;
  final double radius;
  final bool shadow;
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.margin = EdgeInsets.zero, this.onTap, this.color = Colors.white, this.radius = 20, this.shadow = true});
  @override
  Widget build(BuildContext context) => Padding(
        padding: margin,
        child: Tap(
          onTap: onTap,
          scale: 0.98,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius), boxShadow: shadow ? softShadow : null),
            child: child,
          ),
        ),
      );
}

class Pill extends StatelessWidget {
  final String text;
  final Color fg;
  final Color? bg;
  const Pill(this.text, {super.key, this.fg = C.orange, this.bg});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: bg ?? fg.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(color: fg, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
      );
}

class IconCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color color;
  final Color bg;
  final int badge;
  const IconCircle(this.icon, {super.key, this.onTap, this.size = 44, this.color = C.orange, this.bg = Colors.white, this.badge = 0});
  @override
  Widget build(BuildContext context) => Tap(
        onTap: onTap,
        child: Stack(clipBehavior: Clip.none, children: [
          Container(width: size, height: size, decoration: BoxDecoration(color: bg, shape: BoxShape.circle, boxShadow: softShadow), child: Icon(icon, color: color, size: size * 0.46)),
          if (badge > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(color: C.orange, shape: BoxShape.circle),
                child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ),
        ]),
      );
}

class Head extends StatelessWidget {
  final String title;
  final String? sub;
  final bool back;
  final Widget? trailing;
  const Head(this.title, {super.key, this.sub, this.back = true, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 14),
        child: Row(children: [
          if (back && Navigator.of(context).canPop()) ...[
            IconCircle(Icons.arrow_back_ios_new_rounded, color: C.ink, onTap: () => Navigator.of(context).maybePop()),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
              if (sub != null) Text(sub!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.muted, fontSize: 13, fontWeight: FontWeight.w500)),
            ]),
          ),
          if (trailing != null) trailing!,
        ]),
      );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
        child: Row(children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.2))),
          if (action != null) Tap(onTap: onAction, child: Text('$action  ›', style: const TextStyle(color: C.orange, fontWeight: FontWeight.w700, fontSize: 12))),
        ]),
      );
}

class Label extends StatelessWidget {
  final String text;
  const Label(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 0, 10),
        child: Text(text, style: const TextStyle(color: C.muted, fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
      );
}

class Rating extends StatelessWidget {
  final double r;
  final bool onDark;
  const Rating(this.r, {super.key, this.onDark = false});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Text(r.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: onDark ? Colors.white : C.ink)),
        const SizedBox(width: 2),
        const Icon(Icons.star_rounded, color: C.amber, size: 15),
      ]);
}

class QtyStepper extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  final int min;
  const QtyStepper({super.key, required this.qty, required this.onChanged, this.min = 1});
  @override
  Widget build(BuildContext context) {
    Widget b(IconData i, VoidCallback f, bool on) => Tap(
          onTap: on ? f : null,
          child: Container(width: 34, height: 34, decoration: BoxDecoration(color: on ? Colors.white : Colors.transparent, shape: BoxShape.circle), child: Icon(i, size: 18, color: on ? C.orange : C.faint)),
        );
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: C.tint, borderRadius: BorderRadius.circular(30)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        b(Icons.remove_rounded, () => onChanged(qty - 1), qty > min),
        SizedBox(
          width: 30,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (ch, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: ch)),
            child: Text('$qty', key: ValueKey(qty), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          ),
        ),
        b(Icons.add_rounded, () => onChanged(qty + 1), true),
      ]),
    );
  }
}

class Empty extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  const Empty(this.icon, this.title, this.sub, {super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Reveal(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 96, height: 96, decoration: const BoxDecoration(color: C.tint, shape: BoxShape.circle), child: Icon(icon, size: 44, color: C.orange)),
              const SizedBox(height: 18),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: C.muted, height: 1.4)),
            ]),
          ),
        ),
      );
}

class AppField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool obscure;
  final TextInputType? keyboard;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmit;
  final TextInputAction? action;
  final int maxLines;
  final String? hint;
  const AppField(this.controller, this.label, this.icon, {super.key, this.validator, this.obscure = false, this.keyboard, this.onChanged, this.onSubmit, this.action, this.maxLines = 1, this.hint});
  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  bool hide = true;
  OutlineInputBorder _b(Color c, [double w = 1]) => OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c, width: w));
  @override
  Widget build(BuildContext context) => TextFormField(
        controller: widget.controller,
        obscureText: widget.obscure && hide,
        keyboardType: widget.keyboard,
        textInputAction: widget.action,
        maxLines: widget.obscure ? 1 : widget.maxLines,
        validator: widget.validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmit,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          floatingLabelStyle: const TextStyle(color: C.orange, fontWeight: FontWeight.w700),
          labelStyle: const TextStyle(color: C.muted, fontWeight: FontWeight.w500),
          prefixIcon: Icon(widget.icon, size: 21, color: C.muted),
          suffixIcon: widget.obscure ? IconButton(icon: Icon(hide ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20), onPressed: () => setState(() => hide = !hide)) : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          border: _b(C.line),
          enabledBorder: _b(C.line),
          focusedBorder: _b(C.orange, 1.6),
          errorBorder: _b(C.red),
          focusedErrorBorder: _b(C.red, 1.6),
          errorStyle: const TextStyle(color: C.red, fontWeight: FontWeight.w600, fontSize: 12.5),
        ),
      );
}

/// Choice chips (single select) with a smooth colour change.
class Chips extends StatelessWidget {
  final List<String> items;
  final String selected;
  final ValueChanged<String> onTap;
  final EdgeInsets padding;
  const Chips(this.items, {super.key, required this.selected, required this.onTap, this.padding = const EdgeInsets.symmetric(horizontal: 24)});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: padding,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final on = items[i] == selected;
            return Tap(
              onTap: () => onTap(items[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: on ? C.orange : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: on ? C.orange : C.line)),
                child: Text(items[i], style: TextStyle(color: on ? Colors.white : C.ink, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            );
          },
        ),
      );
}

// ---------- bottom navigation ----------
class NavItem {
  final IconData icon, active;
  final String label;
  const NavItem(this.icon, this.active, this.label);
}

class AppNav extends StatelessWidget {
  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onTap;
  const AppNav({super.key, required this.items, required this.index, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(top: 8, bottom: MediaQuery.of(context).padding.bottom + 8),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.line))),
        child: Row(children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: Tap(
                onTap: () => onTap(i),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    width: i == index ? 58 : 40,
                    height: 32,
                    decoration: BoxDecoration(color: i == index ? C.tint : Colors.transparent, borderRadius: BorderRadius.circular(16)),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(i == index ? items[i].active : items[i].icon, key: ValueKey(i == index), color: i == index ? C.orange : C.faint, size: 23),
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: i == index ? C.orange : C.faint),
                    child: Text(items[i].label),
                  ),
                ]),
              ),
            ),
        ]),
      );
}

/// Fade between tab pages.
class TabFade extends StatelessWidget {
  final int index;
  final List<Widget> pages;
  const TabFade({super.key, required this.index, required this.pages});
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOut,
        transitionBuilder: (ch, a) => FadeTransition(opacity: a, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.015), end: Offset.zero).animate(a), child: ch)),
        child: KeyedSubtree(key: ValueKey(index), child: pages[index]),
      );
}

/// Simple editable form page used for profile-style screens.
class FormPage extends StatefulWidget {
  final String title;
  final String? sub;
  final List<(String, String, IconData)> fields; // label, initial, icon
  final void Function(List<String> values) onSave;
  const FormPage(this.title, this.fields, this.onSave, {super.key, this.sub});
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _f = GlobalKey<FormState>();
  late final List<TextEditingController> cs = [for (final f in widget.fields) TextEditingController(text: f.$2)];
  bool busy = false;
  @override
  void dispose() {
    for (final c in cs) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_f.currentState!.validate()) return;
    setState(() => busy = true);
    await Future.delayed(const Duration(milliseconds: 600));
    widget.onSave([for (final c in cs) c.text.trim()]);
    if (!mounted) return;
    toast(context, 'Saved successfully');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          Head(widget.title, sub: widget.sub),
          Expanded(
            child: Form(
              key: _f,
              child: ListView(padding: const EdgeInsets.fromLTRB(24, 8, 24, 24), children: [
                for (var i = 0; i < widget.fields.length; i++)
                  Reveal(
                    i: i,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: AppField(cs[i], widget.fields[i].$1, widget.fields[i].$3, validator: (v) => vReq(v, 'Please fill in ${widget.fields[i].$1.toLowerCase()}')),
                    ),
                  ),
                const SizedBox(height: 8),
                GradBtn('Save changes', loading: busy, onTap: _save),
              ]),
            ),
          ),
        ]),
      );
}

double lerpD(double a, double b, double t) => a + (b - a) * t;
double clamp01(double v) => math.max(0, math.min(1, v));

Color statusColor(OStatus s) {
  switch (s) {
    case OStatus.placed:
      return C.amber;
    case OStatus.accepted:
    case OStatus.preparing:
      return const Color(0xFF3F86CF);
    case OStatus.ready:
      return const Color(0xFF7A5AF8);
    case OStatus.pickedUp:
      return C.orange;
    case OStatus.delivered:
      return C.green;
    case OStatus.rejected:
      return C.red;
  }
}
