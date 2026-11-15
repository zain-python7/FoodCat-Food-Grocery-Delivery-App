import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/art.dart';
import '../core/data.dart';
import '../core/theme.dart';
import '../core/ui.dart';
import 'common.dart';
import 'customer_shell.dart';

String timeRange(DateTime from) {
  String f(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '$h:${d.minute.toString().padLeft(2, '0')}';
  }

  final a = from.add(const Duration(minutes: 30));
  final b = from.add(const Duration(minutes: 50));
  return '${f(a)} – ${f(b)} ${b.hour >= 12 ? 'PM' : 'AM'}';
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final TextEditingController note = TextEditingController(text: app.note);
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  Widget _row(String l, String v, {Color? c, bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Expanded(child: Text(l, style: TextStyle(color: bold ? C.ink : C.muted, fontWeight: bold ? FontWeight.w900 : FontWeight.w600, fontSize: bold ? 16 : 14))),
          Text(v, style: TextStyle(color: c ?? C.ink, fontWeight: bold ? FontWeight.w900 : FontWeight.w700, fontSize: bold ? 17 : 14)),
        ]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            if (app.cart.isEmpty) {
              return Column(children: [
                const Head('Your cart'),
                const Expanded(child: Empty(Icons.shopping_bag_outlined, 'Your cart is empty', 'Add something you love and it will show up here.')),
                Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 28), child: GradBtn('Browse restaurants', onTap: () => Navigator.of(context).maybePop())),
              ]);
            }
            final left = 1500 - app.sub;
            return Column(children: [
              Head('Your cart', sub: app.rest(app.cartRid ?? 'r1').name),
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20), children: [
                  for (var i = 0; i < app.cart.length; i++)
                    Dismissible(
                      key: ObjectKey(app.cart[i]),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => app.setQty(app.cart[i], 0),
                      background: Container(margin: const EdgeInsets.only(bottom: 14), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24), decoration: BoxDecoration(color: C.red, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.delete_outline_rounded, color: Colors.white)),
                      child: Reveal(
                        i: i,
                        child: SoftCard(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          child: Row(children: [
                            SizedBox(width: 70, height: 70, child: FoodArt(app.cart[i].food.art, radius: 18, scale: 1.15)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(app.cart[i].food.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                                if (app.cart[i].extras.isNotEmpty) Text(app.cart[i].extras.join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.muted, fontSize: 11.5)),
                                const SizedBox(height: 6),
                                Text(rs(app.cart[i].total), style: const TextStyle(color: C.orange, fontWeight: FontWeight.w900)),
                              ]),
                            ),
                            QtyStepper(qty: app.cart[i].qty, onChanged: (v) => app.setQty(app.cart[i], v), min: 0),
                          ]),
                        ),
                      ),
                    ),
                  if (left > 0)
                    Reveal(
                      i: 3,
                      child: SoftCard(
                        margin: const EdgeInsets.only(bottom: 14),
                        color: C.tint,
                        shadow: false,
                        padding: const EdgeInsets.all(14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Add ${rs(left)} more for free delivery', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          const SizedBox(height: 10),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: clamp01(app.sub / 1500)),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, __) => ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: v, minHeight: 8, backgroundColor: Colors.white, color: C.orange)),
                          ),
                        ]),
                      ),
                    ),
                  const Label('NOTE FOR THE RESTAURANT'),
                  AppField(note, 'Add a note for the restaurant', Icons.edit_note_rounded, hint: 'No onions, please...', onChanged: (v) => app.note = v),
                  const Label('BILL DETAILS'),
                  SoftCard(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                    child: Column(children: [
                      _row('Subtotal', rs(app.sub)),
                      _row('Delivery fee', app.fee == 0 ? 'Free' : rs(app.fee), c: app.fee == 0 ? C.green : null),
                      _row('Tax', rs(app.tax)),
                      if (app.disc > 0) _row('Discount (${app.promo})', '- ${rs(app.disc)}', c: C.green),
                      const Divider(height: 22, color: C.line),
                      _row('Total', rs(app.total), bold: true),
                    ]),
                  ),
                ]),
              ),
              Padding(padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.of(context).padding.bottom + 16), child: GradBtn('Continue to checkout', onTap: () => go(context, const CheckoutPage()))),
            ]);
          },
        ),
      );
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final promo = TextEditingController();
  String? promoErr;
  bool busy = false, addrErr = false;
  @override
  void dispose() {
    promo.dispose();
    super.dispose();
  }

  Future<void> _place() async {
    if (app.addresses.isEmpty) {
      setState(() => addrErr = true);
      return;
    }
    setState(() => busy = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final o = app.placeOrder();
    goReplace(context, SuccessPage(o));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            final a = app.addresses.isEmpty ? null : app.addresses[app.addrIdx];
            if (app.cart.isEmpty && !busy) return const Column(children: [Head('Checkout'), Expanded(child: Empty(Icons.shopping_bag_outlined, 'Nothing to check out', 'Your cart is empty.'))]);
            return Column(children: [
              const Head('Checkout', sub: 'One last step before the good stuff'),
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 20), children: [
                  const Label('DELIVERY ADDRESS'),
                  Reveal(
                    child: SoftCard(
                      onTap: () => addressSheet(context),
                      child: Row(children: [
                        Container(width: 44, height: 44, decoration: BoxDecoration(color: C.tint, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.my_location_rounded, color: C.orange)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a?.label ?? 'No address yet', style: const TextStyle(fontWeight: FontWeight.w900)), Text(a?.line ?? 'Tap to add one', style: const TextStyle(color: C.muted, fontSize: 12.5))])),
                        const Text('Change  ›', style: TextStyle(color: C.orange, fontWeight: FontWeight.w800, fontSize: 12)),
                      ]),
                    ),
                  ),
                  if (addrErr && a == null) const Padding(padding: EdgeInsets.only(top: 6, left: 6), child: Text('Please add a delivery address', style: TextStyle(color: C.red, fontWeight: FontWeight.w600, fontSize: 12.5))),
                  const Label('PAYMENT METHOD'),
                  Reveal(
                    i: 1,
                    child: SoftCard(
                      onTap: () => paymentSheet(context),
                      child: Row(children: [
                        Container(width: 44, height: 44, decoration: BoxDecoration(color: C.tint, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.payments_rounded, color: C.orange)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(app.payment, style: const TextStyle(fontWeight: FontWeight.w900))),
                        const Text('Change  ›', style: TextStyle(color: C.orange, fontWeight: FontWeight.w800, fontSize: 12)),
                      ]),
                    ),
                  ),
                  const Label('ORDER SUMMARY'),
                  Reveal(
                    i: 2,
                    child: SoftCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${app.cartCount} item${app.cartCount == 1 ? '' : 's'} from ${app.rest(app.cartRid ?? 'r1').name}', style: const TextStyle(color: C.muted, fontWeight: FontWeight.w700, fontSize: 12.5)),
                        const SizedBox(height: 10),
                        for (final l in app.cart)
                          Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Expanded(child: Text('${l.food.name} × ${l.qty}', style: const TextStyle(fontWeight: FontWeight.w700))), Text(rs(l.total), style: const TextStyle(fontWeight: FontWeight.w800))])),
                        const Divider(height: 24, color: C.line),
                        if (app.promo.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(color: const Color(0xFFE8F7F0), borderRadius: BorderRadius.circular(14)),
                            child: Row(children: [
                              const Icon(Icons.local_offer_rounded, color: C.green, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text('${app.promo} applied  •  ${kPromos[app.promo]}% off', style: const TextStyle(color: C.green, fontWeight: FontWeight.w800, fontSize: 13))),
                              Tap(onTap: app.clearPromo, child: const Icon(Icons.close_rounded, size: 18, color: C.green)),
                            ]),
                          )
                        else
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: AppField(promo, 'Add promo code', Icons.percent_rounded, onChanged: (_) {
                              if (promoErr != null) setState(() => promoErr = null);
                            })),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Tap(
                                onTap: () {
                                  if (promo.text.trim().isEmpty) return setState(() => promoErr = 'Enter a promo code');
                                  if (!app.applyPromo(promo.text)) return setState(() => promoErr = 'That code is not valid');
                                  promo.clear();
                                },
                                child: Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), decoration: BoxDecoration(color: C.tint, borderRadius: BorderRadius.circular(14)), child: const Text('Apply', style: TextStyle(color: C.orange, fontWeight: FontWeight.w900))),
                              ),
                            ),
                          ]),
                        if (promoErr != null) Padding(padding: const EdgeInsets.only(top: 6, left: 4), child: Text(promoErr!, style: const TextStyle(color: C.red, fontWeight: FontWeight.w600, fontSize: 12.5))),
                        const Divider(height: 24, color: C.line),
                        Row(children: [
                          const Expanded(child: Text('Total payable', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                          AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: Text(rs(app.total), key: ValueKey(app.total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: C.orange))),
                        ]),
                      ]),
                    ),
                  ),
                ]),
              ),
              Padding(padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.of(context).padding.bottom + 16), child: GradBtn('Place order', loading: busy, onTap: _place)),
            ]);
          },
        ),
      );
}

class SuccessPage extends StatelessWidget {
  final Order o;
  const SuccessPage(this.o, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Spacer(),
              const DrawCheck(),
              const SizedBox(height: 26),
              const Reveal(i: 3, child: Text('Order placed!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5))),
              const SizedBox(height: 6),
              const Reveal(i: 4, child: Text('The restaurant has received your order.', style: TextStyle(color: C.muted))),
              const SizedBox(height: 26),
              Reveal(
                i: 5,
                child: SoftCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(children: [
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('ORDER NUMBER', style: TextStyle(color: C.muted, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1)), const SizedBox(height: 4), Text(o.id, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))])),
                      const Pill('CONFIRMED', fg: C.green),
                    ]),
                    const Divider(height: 26, color: C.line),
                    Row(children: [
                      const Icon(Icons.schedule_rounded, color: C.orange),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('Estimated arrival', style: TextStyle(color: C.muted, fontWeight: FontWeight.w600))),
                      Text(timeRange(o.at), style: const TextStyle(fontWeight: FontWeight.w900)),
                    ]),
                  ]),
                ),
              ),
              const Spacer(),
              Reveal(i: 6, child: GradBtn('Track your order', icon: Icons.location_on_rounded, onTap: () => goReplace(context, TrackingPage(o)))),
              const SizedBox(height: 8),
              TextButton(onPressed: () => goRoot(context, const CustomerShell()), child: const Text('Back to home', style: TextStyle(color: C.muted, fontWeight: FontWeight.w800))),
            ]),
          ),
        ),
      );
}

class TrackingPage extends StatelessWidget {
  final Order o;
  const TrackingPage(this.o, {super.key});

  static const _title = {
    OStatus.placed: 'Waiting for confirmation',
    OStatus.accepted: 'Order confirmed',
    OStatus.preparing: 'Preparing your food',
    OStatus.ready: 'Waiting for a rider',
    OStatus.pickedUp: 'Arriving in about 12 min',
    OStatus.delivered: 'Delivered. Enjoy!',
    OStatus.rejected: 'Order was declined',
  };
  static const _tag = {
    OStatus.placed: 'ORDER SENT',
    OStatus.accepted: 'CONFIRMED',
    OStatus.preparing: 'IN THE KITCHEN',
    OStatus.ready: 'READY FOR PICKUP',
    OStatus.pickedUp: 'RIDER IS ON THE WAY',
    OStatus.delivered: 'COMPLETED',
    OStatus.rejected: 'DECLINED',
  };
  static const _sub = {
    OStatus.placed: 'The restaurant will confirm your order shortly.',
    OStatus.accepted: 'The restaurant accepted your order.',
    OStatus.preparing: 'Your meal is being freshly prepared.',
    OStatus.ready: 'Your order is packed. A rider will pick it up soon.',
    OStatus.pickedUp: 'Your order is picked up and heading to you.',
    OStatus.delivered: 'Thanks for ordering with Foodie.',
    OStatus.rejected: 'The restaurant could not take this order. You have not been charged.',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            final s = o.status;
            final lit = [s.index >= OStatus.accepted.index && s != OStatus.rejected, s.index >= OStatus.preparing.index && s != OStatus.rejected, s.index >= OStatus.pickedUp.index && s != OStatus.rejected, s == OStatus.delivered];
            const names = ['Confirmed', 'Preparing', 'On the way', 'Delivered'];
            final frac = s == OStatus.rejected ? 0.0 : const {OStatus.placed: 0.06, OStatus.accepted: 0.22, OStatus.preparing: 0.44, OStatus.ready: 0.62, OStatus.pickedUp: 0.82, OStatus.delivered: 1.0}[s]!;
            return Stack(children: [
              Positioned.fill(bottom: 260, child: MapView(height: double.infinity, progress: s == OStatus.pickedUp ? null : (s == OStatus.delivered ? 1.0 : 0.0))),
              Positioned(top: MediaQuery.of(context).padding.top + 12, left: 20, child: IconCircle(Icons.arrow_back_ios_new_rounded, color: C.ink, onTap: () => Navigator.of(context).maybePop())),
              Positioned(
                top: MediaQuery.of(context).padding.top + 14,
                right: 20,
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: softShadow), child: Text(o.id, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5))),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: MediaQuery.of(context).size.height * 0.36,
                child: Container(
                  decoration: const BoxDecoration(color: C.cream, borderRadius: BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 30)]),
                  child: ListView(padding: EdgeInsets.fromLTRB(22, 22, 22, MediaQuery.of(context).padding.bottom + 20), children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Column(key: ValueKey(s), crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_tag[s]!, style: TextStyle(color: s == OStatus.rejected ? C.red : C.orange, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                        const SizedBox(height: 4),
                        Text(_title[s]!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
                        const SizedBox(height: 4),
                        Text(_sub[s]!, style: const TextStyle(color: C.muted, height: 1.4)),
                      ]),
                    ),
                    const SizedBox(height: 18),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: frac),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: v, minHeight: 8, backgroundColor: C.tint, color: C.orange)),
                    ),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      for (var i = 0; i < 4; i++)
                        Column(children: [
                          AnimatedContainer(duration: const Duration(milliseconds: 350), width: 22, height: 22, decoration: BoxDecoration(color: lit[i] ? C.orange : Colors.white, shape: BoxShape.circle, border: Border.all(color: lit[i] ? C.orange : C.line, width: 1.6)), child: lit[i] ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null),
                          const SizedBox(height: 4),
                          Text(names[i], style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: lit[i] ? C.ink : C.faint)),
                        ]),
                    ]),
                    const SizedBox(height: 18),
                    if (s.index >= OStatus.pickedUp.index && s != OStatus.rejected) ...[
                      Reveal(
                        child: SoftCard(
                          child: Column(children: [
                            Row(children: [
                              Container(width: 48, height: 48, alignment: Alignment.center, decoration: const BoxDecoration(gradient: C.hero, shape: BoxShape.circle), child: const Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${(o.rider ?? app.riderName).split(' ').first}  •  Your delivery partner', style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), const Row(children: [Icon(Icons.star_rounded, color: C.amber, size: 16), SizedBox(width: 3), Text('4.9  •  248 deliveries', style: TextStyle(color: C.muted, fontSize: 12.5))])])),
                            ]),
                            const SizedBox(height: 14),
                            OutBtn('Call rider', icon: Icons.call_rounded, h: 46, onTap: () {
                              Clipboard.setData(ClipboardData(text: app.riderPhone));
                              toast(context, 'Rider number ${app.riderPhone} copied');
                            }),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (o.open && s.index >= OStatus.pickedUp.index)
                      Reveal(
                        i: 1,
                        child: SoftCard(
                          color: C.tint,
                          shadow: false,
                          child: Row(children: [
                            const Icon(Icons.lock_rounded, color: C.orange),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('Delivery code\nShare it with your rider on arrival', style: TextStyle(fontWeight: FontWeight.w700, height: 1.35, fontSize: 12.5))),
                            Text(o.code.split('').join(' '), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1, color: C.orange)),
                          ]),
                        ),
                      ),
                    const Label('ORDER DETAILS'),
                    SoftCard(
                      child: Column(children: [
                        for (final l in o.lines) Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Expanded(child: Text('${l.food.name} × ${l.qty}', style: const TextStyle(fontWeight: FontWeight.w700))), Text(rs(l.total), style: const TextStyle(fontWeight: FontWeight.w800))])),
                        const Divider(height: 20, color: C.line),
                        Row(children: [const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w900))), Text(rs(o.total), style: const TextStyle(fontWeight: FontWeight.w900, color: C.orange))]),
                      ]),
                    ),
                  ]),
                ),
              ),
            ]);
          },
        ),
      );
}
