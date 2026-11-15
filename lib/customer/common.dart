import 'package:flutter/material.dart';
import '../core/art.dart';
import '../core/data.dart';
import '../core/sheet.dart';
import '../core/theme.dart';
import '../core/ui.dart';
import 'restaurant.dart';

/// Adds an item, asking first if the cart holds another restaurant's food.
Future<bool> addFood(BuildContext c, Food f, int qty, List<String> extras) async {
  if (f.rid == app.ownerRid && !app.ownerOpen) {
    toast(c, '${app.rest(f.rid).name} is closed right now');
    return false;
  }
  var ok = app.addToCart(f, qty, extras);
  if (!ok) {
    final yes = await confirm(c, title: 'Start a new cart?', body: 'Your cart has items from ${app.rest(app.cartRid!).name}. Adding this will clear it.', yes: 'Start new cart');
    if (!yes) return false;
    ok = app.addToCart(f, qty, extras, replace: true);
  }
  return ok;
}

class RestCard extends StatelessWidget {
  final Rest r;
  final int i;
  final bool top;
  const RestCard(this.r, {super.key, this.i = 0, this.top = false});
  @override
  Widget build(BuildContext context) => Reveal(
        i: i,
        child: ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            final fav = app.favs.contains(r.id);
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
              child: Tap(
                onTap: () => go(context, RestaurantPage(r)),
                scale: 0.98,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), boxShadow: softShadow),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Stack(children: [
                      Hero(
                        tag: 'rest_${r.id}',
                        child: SizedBox(height: 160, width: double.infinity, child: FoodArt(r.art, radius: 26, bg: i.isEven ? C.tint : C.tint2, scale: 1.15)),
                      ),
                      Positioned(
                        left: 14,
                        top: 14,
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Rating(r.rating)),
                      ),
                      if (top)
                        Positioned(left: 14, bottom: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: C.orange, borderRadius: BorderRadius.circular(12)), child: const Text('TOP 10', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.6)))),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Tap(
                          onTap: () {
                            if (fav) {
                              app.favs.remove(r.id);
                            } else {
                              app.favs.add(r.id);
                            }
                            app.ping();
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              transitionBuilder: (ch, a) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.elasticOut), child: ch),
                              child: Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded, key: ValueKey(fav), color: fav ? C.red : C.muted, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ]),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text('${r.time}  •  ${r.free ? 'Free delivery' : 'Rs. 100 delivery'}', style: const TextStyle(color: C.muted, fontSize: 12.5, fontWeight: FontWeight.w500)),
                          ]),
                        ),
                        Text('From ${rs(r.from)}', style: const TextStyle(color: C.orange, fontWeight: FontWeight.w800, fontSize: 12.5)),
                      ]),
                    ),
                  ]),
                ),
              ),
            );
          },
        ),
      );
}

class FoodCard extends StatelessWidget {
  final Food f;
  final int i;
  const FoodCard(this.f, {super.key, this.i = 0});
  @override
  Widget build(BuildContext context) => Reveal(
        i: i,
        child: Tap(
          onTap: () => go(context, FoodPage(f)),
          scale: 0.97,
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: softShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Hero(tag: 'food_${f.id}', child: SizedBox(width: double.infinity, child: FoodArt(f.art, radius: 22, scale: 1.2)))),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                      Text(app.rest(f.rid).name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.muted, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(rs(f.price), style: const TextStyle(color: C.orange, fontWeight: FontWeight.w900, fontSize: 13)),
                    ]),
                  ),
                  Tap(
                    onTap: () async {
                      final ok = await addFood(context, f, 1, []);
                      if (ok && context.mounted) toast(context, '${f.name} added to cart');
                    },
                    child: Container(width: 34, height: 34, decoration: BoxDecoration(gradient: C.hero, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.add_rounded, color: Colors.white, size: 20)),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      );
}

int unreadNotes() => app.notes.where((n) => n.unread).length;

void addressSheet(BuildContext c) => sheet<void>(c, const _AddressSheet());

class _AddressSheet extends StatefulWidget {
  const _AddressSheet();
  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  final _f = GlobalKey<FormState>();
  final label = TextEditingController(), line = TextEditingController();
  bool adding = false;
  @override
  void dispose() {
    label.dispose();
    line.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Delivery address', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        for (var i = 0; i < app.addresses.length; i++)
          SoftCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            onTap: () {
              app.addrIdx = i;
              app.ping();
              Navigator.pop(context);
            },
            child: Row(children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: C.tint, borderRadius: BorderRadius.circular(14)), child: Icon(app.addresses[i].label == 'Work' ? Icons.work_rounded : Icons.home_rounded, color: C.orange, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(app.addresses[i].label, style: const TextStyle(fontWeight: FontWeight.w800)), Text(app.addresses[i].line, style: const TextStyle(color: C.muted, fontSize: 12.5))])),
              AnimatedOpacity(duration: const Duration(milliseconds: 200), opacity: app.addrIdx == i ? 1 : 0, child: const Icon(Icons.check_circle_rounded, color: C.green)),
            ]),
          ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: adding ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: OutBtn('Add a new address', icon: Icons.add_location_alt_outlined, onTap: () => setState(() => adding = true)),
          secondChild: Form(
            key: _f,
            child: Column(children: [
              AppField(label, 'Label (Home, Work...)', Icons.label_outline_rounded, validator: (v) => vReq(v, 'Give this address a name')),
              const SizedBox(height: 12),
              AppField(line, 'Full address', Icons.location_on_outlined, validator: (v) => (v ?? '').trim().length < 6 ? 'Enter your full address' : null),
              const SizedBox(height: 14),
              GradBtn('Save address', onTap: () {
                if (!_f.currentState!.validate()) return;
                app.addresses.add(Addr(label.text.trim(), line.text.trim()));
                app.addrIdx = app.addresses.length - 1;
                app.ping();
                Navigator.pop(context);
              }),
            ]),
          ),
        ),
      ]);
}

void paymentSheet(BuildContext c) => sheet<void>(
      c,
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Payment method', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        for (final p in app.payments)
          SoftCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            onTap: () {
              app.payment = p;
              app.ping();
              Navigator.pop(c);
            },
            child: Row(children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: C.tint, borderRadius: BorderRadius.circular(14)), child: Icon(p.startsWith('Card') ? Icons.credit_card_rounded : (p.contains('wallet') ? Icons.account_balance_wallet_rounded : Icons.payments_rounded), color: C.orange, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Text(p, style: const TextStyle(fontWeight: FontWeight.w800))),
              if (app.payment == p) const Icon(Icons.check_circle_rounded, color: C.green),
            ]),
          ),
      ]),
    );
