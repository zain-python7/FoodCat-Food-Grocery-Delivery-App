import 'package:flutter/material.dart';
import '../core/art.dart';
import '../core/data.dart';
import '../core/theme.dart';
import '../core/ui.dart';
import 'common.dart';

class RestaurantPage extends StatefulWidget {
  final Rest r;
  const RestaurantPage(this.r, {super.key});
  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  bool full = false;
  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    final top = MediaQuery.of(context).padding.top;
    final menu = app.menuOf(r.id).where((f) => f.available).toList();
    final shown = full ? menu : menu.take(3).toList();
    Widget stat(IconData i, String v, String l) => Expanded(
          child: Column(children: [
            Icon(i, color: C.orange, size: 22),
            const SizedBox(height: 6),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            Text(l, style: const TextStyle(color: C.muted, fontSize: 11.5)),
          ]),
        );
    return Scaffold(
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final fav = app.favs.contains(r.id);
          return ListView(padding: EdgeInsets.zero, children: [
            Stack(children: [
              Hero(
                tag: 'rest_${r.id}',
                child: ClipRRect(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)), child: SizedBox(height: 270, width: double.infinity, child: FoodArt(r.art, radius: 0, bg: C.tint2, scale: 0.95))),
              ),
              Positioned(top: top + 12, left: 20, child: IconCircle(Icons.arrow_back_ios_new_rounded, color: C.ink, onTap: () => Navigator.of(context).maybePop())),
              Positioned(
                top: top + 12,
                right: 20,
                child: IconCircle(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: fav ? C.red : C.ink, onTap: () {
                  if (fav) {
                    app.favs.remove(r.id);
                  } else {
                    app.favs.add(r.id);
                  }
                  app.ping();
                }),
              ),
            ]),
            Reveal(
              child: Transform.translate(
                offset: const Offset(0, -34),
                child: SoftCard(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  radius: 26,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
                    const SizedBox(height: 4),
                    Text('${r.rating} ★  •  ${r.km} km  •  ${r.time}', style: const TextStyle(color: C.muted, fontWeight: FontWeight.w600, fontSize: 12.5)),
                    const SizedBox(height: 8),
                    Text(r.tagline, style: const TextStyle(height: 1.4)),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1, color: C.line)),
                    Row(children: [
                      stat(Icons.star_rounded, '${r.rating}', 'rating'),
                      stat(Icons.schedule_rounded, r.time, 'delivery'),
                      stat(Icons.delivery_dining_rounded, r.free ? 'Free' : 'Rs. 100', 'delivery fee'),
                    ]),
                  ]),
                ),
              ),
            ),
            Transform.translate(offset: const Offset(0, -34), child: SectionTitle('Popular menu', action: full ? 'Show less' : 'Full menu', onAction: () => setState(() => full = !full))),
            Transform.translate(
              offset: const Offset(0, -34),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: Column(children: [
                  for (var i = 0; i < shown.length; i++)
                    Reveal(
                      i: i,
                      child: SoftCard(
                        margin: const EdgeInsets.fromLTRB(24, 0, 24, 14),
                        padding: const EdgeInsets.all(12),
                        onTap: () => go(context, FoodPage(shown[i])),
                        child: Row(children: [
                          Hero(tag: 'food_${shown[i].id}', child: SizedBox(width: 78, height: 78, child: FoodArt(shown[i].art, radius: 18, scale: 1.15))),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(shown[i].name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                              const SizedBox(height: 3),
                              Text(shown[i].desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.muted, fontSize: 12, height: 1.3)),
                              const SizedBox(height: 6),
                              Text(rs(shown[i].price), style: const TextStyle(color: C.orange, fontWeight: FontWeight.w900)),
                            ]),
                          ),
                          const SizedBox(width: 8),
                          Tap(
                            onTap: () async {
                              final ok = await addFood(context, shown[i], 1, []);
                              if (ok && context.mounted) toast(context, '${shown[i].name} added to cart');
                            },
                            child: Container(width: 38, height: 38, decoration: BoxDecoration(gradient: C.hero, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.add_rounded, color: Colors.white)),
                          ),
                        ]),
                      ),
                    ),
                ]),
              ),
            ),
            const SizedBox(height: 10),
          ]);
        },
      ),
    );
  }
}

class FoodPage extends StatefulWidget {
  final Food f;
  const FoodPage(this.f, {super.key});
  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  int qty = 1;
  final Set<String> extras = {};
  int get unit => widget.f.price + extras.fold<int>(0, (a, e) => a + (kExtras[e] ?? 0));

  @override
  Widget build(BuildContext context) {
    final f = widget.f;
    final top = MediaQuery.of(context).padding.top;
    final opts = extrasFor(f.cat);
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: ListView(padding: EdgeInsets.zero, children: [
            Stack(children: [
              Hero(
                tag: 'food_${f.id}',
                child: ClipRRect(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)), child: SizedBox(height: 310, width: double.infinity, child: FoodArt(f.art, radius: 0, bg: C.tint, scale: 1.0))),
              ),
              Positioned(top: top + 12, left: 20, child: IconCircle(Icons.arrow_back_ios_new_rounded, color: C.ink, onTap: () => Navigator.of(context).maybePop())),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: Reveal(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Text(f.name, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: -0.4, height: 1.15))),
                    const SizedBox(width: 12),
                    Text(rs(f.price), style: const TextStyle(color: C.orange, fontSize: 20, fontWeight: FontWeight.w900)),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.storefront_rounded, size: 16, color: C.muted),
                    const SizedBox(width: 6),
                    Text(app.rest(f.rid).name, style: const TextStyle(color: C.muted, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    const Rating(4.8),
                  ]),
                  const SizedBox(height: 12),
                  Text(f.desc, style: const TextStyle(height: 1.5, color: Color(0xFF5E5855), fontSize: 14.5)),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Reveal(
                i: 2,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Make it yours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  for (final o in opts)
                    Tap(
                      onTap: () => setState(() => extras.contains(o) ? extras.remove(o) : extras.add(o)),
                      scale: 0.98,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: extras.contains(o) ? C.tint : Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: extras.contains(o) ? C.orange : C.line, width: 1.4)),
                        child: Row(children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(color: extras.contains(o) ? C.orange : Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: extras.contains(o) ? C.orange : C.faint, width: 1.6)),
                            child: extras.contains(o) ? const Icon(Icons.check_rounded, size: 17, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(o, style: const TextStyle(fontWeight: FontWeight.w700))),
                          Text('+ ${rs(kExtras[o] ?? 0)}', style: const TextStyle(color: C.muted, fontWeight: FontWeight.w700, fontSize: 13)),
                        ]),
                      ),
                    ),
                ]),
              ),
            ),
          ]),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(24, 14, 24, MediaQuery.of(context).padding.bottom + 14),
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.line))),
          child: Row(children: [
            QtyStepper(qty: qty, onChanged: (v) => setState(() => qty = v)),
            const SizedBox(width: 16),
            Expanded(
              child: GradBtn('Add to cart  •  ${rs(unit * qty)}', onTap: () async {
                final ok = await addFood(context, f, qty, extras.toList());
                if (ok && context.mounted) {
                  toast(context, '${f.name} added to cart');
                  Navigator.of(context).pop();
                }
              }),
            ),
          ]),
        ),
      ]),
    );
  }
}
