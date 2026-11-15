import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/art.dart';
import '../core/data.dart';
import '../core/sheet.dart';
import '../core/theme.dart';
import '../core/ui.dart';
import '../customer/account.dart' show HelpPage, dateStr;
import '../role_page.dart';

final Map<String, String> riderInfo = {'vehicle': 'Honda CD 70', 'plate': 'LEA-1234', 'color': 'Red'};

String greeting() {
  final h = DateTime.now().hour;
  return h < 12 ? 'Good morning' : (h < 17 ? 'Good afternoon' : 'Good evening');
}

// ---------------------------------------------------------------------------
class RiderLogin extends StatefulWidget {
  const RiderLogin({super.key});
  @override
  State<RiderLogin> createState() => _RiderLoginState();
}

class _RiderLoginState extends State<RiderLogin> {
  final _f = GlobalKey<FormState>();
  final phone = TextEditingController(), pass = TextEditingController();
  bool busy = false;
  @override
  void dispose() {
    phone.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    FocusScope.of(context).unfocus();
    if (!_f.currentState!.validate()) return;
    setState(() => busy = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    goRoot(context, const RiderShell());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListView(padding: EdgeInsets.zero, children: [
          Container(
            height: 250,
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 12, 24, 24),
            decoration: const BoxDecoration(gradient: C.green2, borderRadius: BorderRadius.vertical(bottom: Radius.circular(36))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconCircle(Icons.arrow_back_ios_new_rounded, color: C.ink, size: 42, onTap: () => Navigator.of(context).maybePop()),
              const Spacer(),
              const Reveal(child: Text('Ride with foodie', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.6))),
              const SizedBox(height: 4),
              Reveal(i: 1, child: Text('Deliver smiles. Earn on your schedule.', style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600))),
            ]),
          ),
          Form(
            key: _f,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const SizedBox(height: 8),
                Reveal(i: 2, child: AppField(phone, 'Phone number', Icons.phone_outlined, keyboard: TextInputType.phone, action: TextInputAction.next, validator: vPhone)),
                const SizedBox(height: 14),
                Reveal(i: 3, child: AppField(pass, 'Password', Icons.lock_outline_rounded, obscure: true, action: TextInputAction.done, onSubmit: (_) => _go(), validator: vPass)),
                const SizedBox(height: 22),
                Reveal(i: 4, child: GradBtn('Sign in', loading: busy, gradient: C.green2, onTap: _go)),
                const SizedBox(height: 8),
                Reveal(i: 5, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('New rider?', style: TextStyle(color: C.muted)), TextButton(onPressed: () => go(context, const RiderRegister()), child: const Text('Apply to ride', style: TextStyle(color: C.green, fontWeight: FontWeight.w900)))])),
              ]),
            ),
          ),
        ]),
      );
}

class RiderRegister extends StatefulWidget {
  const RiderRegister({super.key});
  @override
  State<RiderRegister> createState() => _RiderRegisterState();
}

class _RiderRegisterState extends State<RiderRegister> {
  final _f = GlobalKey<FormState>();
  final name = TextEditingController(), phone = TextEditingController(), email = TextEditingController(), city = TextEditingController(), plate = TextEditingController();
  String vehicle = 'Bike';
  bool busy = false;
  @override
  void dispose() {
    for (final c in [name, phone, email, city, plate]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_f.currentState!.validate()) return;
    setState(() => busy = true);
    await Future.delayed(const Duration(milliseconds: 900));
    app.approvals.insert(0, Approval('Rider', name.text.trim(), city.text.trim(), 'Pending'));
    app.ping();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        content: Column(mainAxisSize: MainAxisSize.min, children: const [
          SizedBox(height: 8),
          DrawCheck(size: 84),
          SizedBox(height: 18),
          Text('Application received', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text('We will review your details and get back to you within 24 hours.', textAlign: TextAlign.center, style: TextStyle(color: C.muted, height: 1.4)),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done', style: TextStyle(color: C.green, fontWeight: FontWeight.w900)))],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          const Head('Become a rider', sub: 'It takes about two minutes'),
          Expanded(
            child: Form(
              key: _f,
              child: ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 24), children: [
                AppField(name, 'Full name', Icons.person_outline_rounded, action: TextInputAction.next, validator: (v) => vReq(v, 'Enter your full name')),
                const SizedBox(height: 14),
                AppField(phone, 'Phone number', Icons.phone_outlined, keyboard: TextInputType.phone, action: TextInputAction.next, validator: vPhone),
                const SizedBox(height: 14),
                AppField(email, 'Email', Icons.email_outlined, keyboard: TextInputType.emailAddress, action: TextInputAction.next, validator: vEmail),
                const SizedBox(height: 14),
                AppField(city, 'City', Icons.location_city_rounded, action: TextInputAction.next, validator: (v) => vReq(v, 'Enter your city')),
                const Label('VEHICLE TYPE'),
                Chips(const ['Bike', 'Car', 'Bicycle'], selected: vehicle, onTap: (v) => setState(() => vehicle = v), padding: EdgeInsets.zero),
                const SizedBox(height: 14),
                AppField(plate, 'Registration number', Icons.pin_outlined, action: TextInputAction.done, validator: (v) => vehicle == 'Bicycle' ? null : vReq(v, 'Enter your registration number')),
                const SizedBox(height: 22),
                GradBtn('Submit application', loading: busy, gradient: C.green2, onTap: _submit),
              ]),
            ),
          ),
        ]),
      );
}

// ---------------------------------------------------------------------------
class RiderShell extends StatefulWidget {
  const RiderShell({super.key});
  @override
  State<RiderShell> createState() => _RiderShellState();
}

class _RiderShellState extends State<RiderShell> {
  int i = 0;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => Scaffold(
          body: Column(children: [
            Expanded(child: TabFade(index: i, pages: [RiderHome(), RiderJobs(), RiderEarnings(), RiderProfile()])),
            AppNav(
              index: i,
              onTap: (x) => setState(() => i = x),
              items: const [
                NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
                NavItem(Icons.two_wheeler_outlined, Icons.two_wheeler_rounded, 'Jobs'),
                NavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Earnings'),
                NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
              ],
            ),
          ]),
        ),
      );
}

Widget jobPage(Order o) => o.status.index >= OStatus.pickedUp.index ? NavPage(o) : PickupPage(o);

Widget requestCard(BuildContext context, Order o, {int i = 0}) {
  final r = app.rest(o.rid);
  return Reveal(
    i: i,
    child: SoftCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Pill('NEW DELIVERY REQUEST', fg: C.green),
          const Spacer(),
          Text('Rs. 180', style: const TextStyle(color: C.green, fontWeight: FontWeight.w900, fontSize: 18)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          SizedBox(width: 52, height: 52, child: FoodArt(r.art, radius: 15)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), Text('Pickup at ${r.area}  •  ${o.id}', style: const TextStyle(color: C.muted, fontSize: 12.5))])),
        ]),
        const SizedBox(height: 10),
        Row(children: [const Icon(Icons.flag_rounded, size: 16, color: C.muted), const SizedBox(width: 6), Expanded(child: Text('Deliver to ${o.address}  •  2.4 km', style: const TextStyle(color: C.muted, fontSize: 12.5)))]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: OutBtn('View', color: C.green, h: 46, onTap: () => go(context, RequestPage(o)))),
          const SizedBox(width: 10),
          Expanded(child: GradBtn('Accept', h: 46, gradient: C.green2, onTap: () {
            app.acceptJob(o);
            go(context, PickupPage(o));
          })),
        ]),
      ]),
    ),
  );
}

Widget activeCard(BuildContext context, Order o) => Reveal(
      child: SoftCard(
        margin: const EdgeInsets.only(bottom: 14),
        color: C.navy,
        onTap: () => go(context, jobPage(o)),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.two_wheeler_rounded, color: Colors.white)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('ACTIVE DELIVERY', style: TextStyle(color: Color(0xFF8FE3BE), fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 3), Text('${app.rest(o.rid).name}  •  ${o.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)), Text(o.status.label, style: const TextStyle(color: Colors.white70, fontSize: 12.5))])),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        ]),
      ),
    );

class RiderHome extends StatelessWidget {
  const RiderHome({super.key});
  @override
  Widget build(BuildContext context) {
    final req = app.requests;
    final active = app.activeJob;
    return ListView(padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 20), children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${greeting()}, ${app.riderName.split(' ').first}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.3)), const Text('Ready to make someone\'s day?', style: TextStyle(color: C.muted, fontSize: 13))])),
        Container(width: 46, height: 46, alignment: Alignment.center, decoration: const BoxDecoration(gradient: C.green2, shape: BoxShape.circle), child: Text(app.riderName[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
      ]),
      const SizedBox(height: 18),
      Reveal(
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(gradient: C.dark, borderRadius: BorderRadius.circular(26), boxShadow: [BoxShadow(color: C.navy.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TODAY\'S EARNINGS', style: TextStyle(color: Color(0xFFA9B3C2), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
            const SizedBox(height: 6),
            CountUp(app.riderToday, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.6)),
            const SizedBox(height: 8),
            const Pill('↑ 12% from yesterday', fg: Color(0xFF8FE3BE)),
          ]),
        ),
      ),
      const SizedBox(height: 14),
      Reveal(
        i: 1,
        child: SoftCard(
          child: Row(children: [
            AnimatedContainer(duration: const Duration(milliseconds: 300), width: 12, height: 12, decoration: BoxDecoration(color: app.riderOnline ? C.green : C.faint, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(app.riderOnline ? 'You are online' : 'You are offline', style: const TextStyle(fontWeight: FontWeight.w900)), Text(app.riderOnline ? 'You can receive delivery requests' : 'Go online to start earning', style: const TextStyle(color: C.muted, fontSize: 12))])),
            Switch(value: app.riderOnline, onChanged: (v) { app.riderOnline = v; app.ping(); }),
          ]),
        ),
      ),
      const SizedBox(height: 14),
      Reveal(
        i: 2,
        child: Row(children: [
          Expanded(child: SoftCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.timer_outlined, color: C.green), const SizedBox(height: 8), const Text('5h 20m', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), const Text('Online time', style: TextStyle(color: C.muted, fontSize: 12))]))),
          const SizedBox(width: 14),
          Expanded(child: SoftCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.inventory_2_outlined, color: C.orange), const SizedBox(height: 8), Text('${app.riderJobs} orders', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), const Text('Completed', style: TextStyle(color: C.muted, fontSize: 12))]))),
        ]),
      ),
      const SizedBox(height: 20),
      if (active != null) activeCard(context, active),
      if (app.riderOnline && req.isNotEmpty && active == null) requestCard(context, req.first, i: 3),
      if (app.riderOnline && req.isEmpty && active == null)
        Reveal(
          i: 3,
          child: const SoftCard(
            child: Row(children: [
              Icon(Icons.radar_rounded, color: C.green, size: 30),
              SizedBox(width: 14),
              Expanded(child: Text('Looking for deliveries near you…\nNew requests will pop up here.', style: TextStyle(color: C.muted, height: 1.4, fontWeight: FontWeight.w600))),
            ]),
          ),
        ),
      if (!app.riderOnline) const Reveal(i: 3, child: SoftCard(child: Row(children: [Icon(Icons.bedtime_rounded, color: C.faint, size: 30), SizedBox(width: 14), Expanded(child: Text('You are offline. Turn on availability to receive requests.', style: TextStyle(color: C.muted, height: 1.4, fontWeight: FontWeight.w600)))]))),
    ]);
  }
}

class RiderJobs extends StatelessWidget {
  const RiderJobs({super.key});
  @override
  Widget build(BuildContext context) {
    final req = app.requests;
    final active = app.activeJob;
    return Column(children: [
      const Head('Jobs', sub: 'Available and active deliveries', back: false),
      Expanded(
        child: (req.isEmpty && active == null) || !app.riderOnline
            ? Empty(Icons.two_wheeler_rounded, app.riderOnline ? 'No jobs right now' : 'You are offline', app.riderOnline ? 'We will notify you when a delivery is nearby.' : 'Go online from Home to see requests.')
            : ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20), children: [
                if (active != null) activeCard(context, active),
                if (active == null) for (var i = 0; i < req.length; i++) requestCard(context, req[i], i: i),
              ]),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------
class RequestPage extends StatefulWidget {
  final Order o;
  const RequestPage(this.o, {super.key});
  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(seconds: 30))
    ..forward()
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        toast(context, 'Request expired');
        Navigator.of(context).maybePop();
      }
    });
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.o;
    final r = app.rest(o.rid);
    Widget row(IconData i, String t, String s) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFE8F7F0), borderRadius: BorderRadius.circular(14)), child: Icon(i, color: C.green)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(color: C.muted, fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.6)), Text(s, style: const TextStyle(fontWeight: FontWeight.w800))])),
          ]),
        );
    return Scaffold(
      body: Column(children: [
        const Head('Delivery request', sub: 'Respond before the timer ends'),
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 20), children: [
            Reveal(
              child: SoftCard(
                child: Row(children: [
                  AnimatedBuilder(
                    animation: c,
                    builder: (_, __) => SizedBox(
                      width: 74,
                      height: 74,
                      child: Stack(alignment: Alignment.center, children: [
                        SizedBox(width: 74, height: 74, child: CircularProgressIndicator(value: 1 - c.value, strokeWidth: 6, backgroundColor: const Color(0xFFE8F7F0), color: C.green)),
                        Text('${(30 * (1 - c.value)).ceil()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 18),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Earn Rs. 180', style: TextStyle(color: C.green, fontWeight: FontWeight.w900, fontSize: 24)), Text('2.4 km  •  about 18 min', style: TextStyle(color: C.muted, fontWeight: FontWeight.w600))])),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            Reveal(i: 1, child: Column(children: [row(Icons.storefront_rounded, 'PICKUP', '${r.name}, ${r.area}'), row(Icons.flag_rounded, 'DROP-OFF', o.address), row(Icons.inventory_2_rounded, 'ORDER', '${o.id}  •  ${o.items} items'), row(Icons.payments_rounded, 'PAYMENT', o.payment)])),
          ]),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.of(context).padding.bottom + 16),
          child: Column(children: [
            GradBtn('Accept delivery', gradient: C.green2, onTap: () {
              app.acceptJob(o);
              goReplace(context, PickupPage(o));
            }),
            const SizedBox(height: 10),
            OutBtn('Decline', color: C.muted, onTap: () => Navigator.of(context).maybePop()),
          ]),
        ),
      ]),
    );
  }
}

class PickupPage extends StatefulWidget {
  final Order o;
  const PickupPage(this.o, {super.key});
  @override
  State<PickupPage> createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  bool arrived = false;
  @override
  Widget build(BuildContext context) {
    final o = widget.o;
    final r = app.rest(o.rid);
    return Scaffold(
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final ready = o.status.index >= OStatus.ready.index;
          final cancelled = o.status == OStatus.rejected;
          Widget step(int n, String t, String s, bool done, bool now) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  AnimatedContainer(duration: const Duration(milliseconds: 300), width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(color: done ? C.green : (now ? C.tint : Colors.white), shape: BoxShape.circle, border: Border.all(color: done ? C.green : (now ? C.orange : C.line), width: 1.6)), child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : Text('$n', style: TextStyle(fontWeight: FontWeight.w900, color: now ? C.orange : C.faint))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: TextStyle(fontWeight: FontWeight.w900, color: done || now ? C.ink : C.faint)), Text(s, style: const TextStyle(color: C.muted, fontSize: 12.5, height: 1.3))])),
                ]),
              );
          return Column(children: [
            Head('Pickup', sub: 'Step ${arrived ? (ready ? 3 : 2) : 1} of 3'),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 20), children: [
                Reveal(
                  child: SoftCard(
                    child: Row(children: [
                      SizedBox(width: 60, height: 60, child: FoodArt(r.art, radius: 17)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), Text('${r.area}  •  ${o.id}', style: const TextStyle(color: C.muted, fontSize: 12.5)), const SizedBox(height: 6), Pill(o.status.label.toUpperCase(), fg: ready ? C.green : C.amber)])),
                    ]),
                  ),
                ),
                const SizedBox(height: 22),
                Reveal(
                  i: 1,
                  child: Column(children: [
                    step(1, 'Head to the restaurant', 'Pickup at ${r.area}', arrived, !arrived),
                    step(2, 'Collect the order', ready ? 'Check the order number and the sealed bag' : 'The kitchen is still preparing the order', ready && o.status.index >= OStatus.pickedUp.index, arrived),
                    step(3, 'Start the delivery', 'Drop-off at ${o.address}', false, arrived && ready),
                  ]),
                ),
                if (arrived) Tap(onTap: () { Clipboard.setData(ClipboardData(text: '${r.name}, ${r.area}')); toast(context, 'Restaurant address copied'); }, child: const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Copy restaurant address  ↗', style: TextStyle(color: C.green, fontWeight: FontWeight.w800)))),
              ]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.of(context).padding.bottom + 16),
              child: cancelled
                  ? OutBtn('Order cancelled. Go back', color: C.red, onTap: () => Navigator.of(context).maybePop())
                  : !arrived
                      ? GradBtn('I\'ve arrived at the restaurant', gradient: C.green2, onTap: () => setState(() => arrived = true))
                      : !ready
                          ? const GradBtn('Waiting for the kitchen…')
                          : GradBtn('I\'ve picked up the order', gradient: C.green2, onTap: () {
                              app.advance(o);
                              goReplace(context, NavPage(o));
                            }),
            ),
          ]);
        },
      ),
    );
  }
}

class NavPage extends StatelessWidget {
  final Order o;
  const NavPage(this.o, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(children: [
          const Positioned.fill(bottom: 250, child: MapView(height: double.infinity)),
          Positioned(top: MediaQuery.of(context).padding.top + 12, left: 20, child: IconCircle(Icons.arrow_back_ios_new_rounded, color: C.ink, onTap: () => Navigator.of(context).maybePop())),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 22, 24, MediaQuery.of(context).padding.bottom + 18),
              decoration: const BoxDecoration(color: C.cream, borderRadius: BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 30)]),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('CUSTOMER DESTINATION', style: TextStyle(color: C.green, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                const SizedBox(height: 6),
                Text(o.customer, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                Text(o.address, style: const TextStyle(color: C.muted)),
                const SizedBox(height: 14),
                SoftCard(padding: const EdgeInsets.all(14), child: Row(children: [const Icon(Icons.schedule_rounded, color: C.green), const SizedBox(width: 10), const Expanded(child: Text('Estimated arrival', style: TextStyle(color: C.muted, fontWeight: FontWeight.w600))), const Text('12 minutes', style: TextStyle(fontWeight: FontWeight.w900))])),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: OutBtn('Copy address', color: C.green, icon: Icons.copy_rounded, onTap: () { Clipboard.setData(ClipboardData(text: o.address)); toast(context, 'Address copied. Paste it in your maps app'); })),
                  const SizedBox(width: 10),
                  Expanded(child: GradBtn('I\'ve arrived', gradient: C.green2, onTap: () => goReplace(context, ConfirmPage(o)))),
                ]),
              ]),
            ),
          ),
        ]),
      );
}

class ConfirmPage extends StatefulWidget {
  final Order o;
  const ConfirmPage(this.o, {super.key});
  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> with SingleTickerProviderStateMixin {
  String code = '';
  String? err;
  late final AnimationController shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  @override
  void dispose() {
    shake.dispose();
    super.dispose();
  }

  void _key(String k) {
    HapticFeedback.selectionClick();
    setState(() {
      err = null;
      if (k == '<') {
        if (code.isNotEmpty) code = code.substring(0, code.length - 1);
      } else if (code.length < 4) {
        code += k;
      }
    });
  }

  void _confirm() {
    final o = widget.o;
    if (code != o.code) {
      setState(() {
        err = 'Incorrect code. Ask the customer to check their app.';
        code = '';
      });
      shake.forward(from: 0);
      return;
    }
    app.advance(o);
    goReplace(context, DeliveredPage(o));
  }

  @override
  Widget build(BuildContext context) {
    Widget key(String k) => Expanded(
          child: k.isEmpty
              ? const SizedBox(height: 64)
              : Tap(
                  onTap: () => _key(k),
                  child: Container(height: 64, margin: const EdgeInsets.all(6), alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: C.line)), child: k == '<' ? const Icon(Icons.backspace_outlined, color: C.muted) : Text(k, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
                ),
        );
    return Scaffold(
      body: Column(children: [
        const Head('Confirm delivery', sub: 'Ask the customer for their 4-digit code'),
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(24, 10, 24, 10), children: [
            AnimatedBuilder(
              animation: shake,
              builder: (_, ch) => Transform.translate(offset: Offset(math.sin(shake.value * math.pi * 6) * 12 * (1 - shake.value), 0), child: ch),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < 4; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 62,
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: err != null ? C.red : (i == code.length ? C.green : C.line), width: 1.8)),
                    child: Text(i < code.length ? code[i] : '', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  ),
              ]),
            ),
            if (err != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(err!, textAlign: TextAlign.center, style: const TextStyle(color: C.red, fontWeight: FontWeight.w700, fontSize: 13))),
            const SizedBox(height: 22),
            Row(children: [key('1'), key('2'), key('3')]),
            Row(children: [key('4'), key('5'), key('6')]),
            Row(children: [key('7'), key('8'), key('9')]),
            Row(children: [key(''), key('0'), key('<')]),
          ]),
        ),
        Padding(padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.of(context).padding.bottom + 16), child: GradBtn('Confirm delivered', gradient: C.green2, onTap: code.length == 4 ? _confirm : null)),
      ]),
    );
  }
}

class DeliveredPage extends StatelessWidget {
  final Order o;
  const DeliveredPage(this.o, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Spacer(),
              const DrawCheck(),
              const SizedBox(height: 24),
              const Reveal(i: 3, child: Text('Delivery completed!', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900))),
              const SizedBox(height: 8),
              const Reveal(i: 4, child: Text('You earned', style: TextStyle(color: C.muted))),
              const Reveal(i: 4, child: Text('Rs. 180', style: TextStyle(color: C.green, fontSize: 38, fontWeight: FontWeight.w900))),
              const Spacer(),
              GradBtn('Back to home', gradient: C.green2, onTap: () => goRoot(context, const RiderShell())),
            ]),
          ),
        ),
      );
}

class RiderEarnings extends StatelessWidget {
  const RiderEarnings({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 20), children: [
        const Text('Earnings', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
        const SizedBox(height: 16),
        Reveal(
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
            decoration: BoxDecoration(gradient: C.green2, borderRadius: BorderRadius.circular(26), boxShadow: [BoxShadow(color: C.green.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('THIS WEEK', style: TextStyle(color: Color(0xFFD6F5E8), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
              const SizedBox(height: 4),
              CountUp(app.riderWeek, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.6)),
              const SizedBox(height: 4),
              const Text('↑ 8.4% from last week', style: TextStyle(color: Color(0xFFD6F5E8), fontWeight: FontWeight.w700, fontSize: 12.5)),
              const SizedBox(height: 10),
              const LineChart([1200, 1800, 1500, 2400, 2100, 2900, 2450], color: Colors.white, light: true, height: 90),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Reveal(
          i: 1,
          child: Row(children: [
            for (final s in [('${app.riderJobs}', 'Deliveries', Icons.inventory_2_rounded), (rs(app.riderTips), 'Tips', Icons.volunteer_activism_rounded), ('31h 20m', 'Online', Icons.timer_rounded)])
              Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: SoftCard(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10), child: Column(children: [Icon(s.$3, color: C.green, size: 22), const SizedBox(height: 6), FittedBox(child: Text(s.$1, style: const TextStyle(fontWeight: FontWeight.w900))), Text(s.$2, style: const TextStyle(color: C.muted, fontSize: 11))])))),
          ]),
        ),
        const SizedBox(height: 8),
        const Label('DAILY EARNINGS'),
        const Reveal(i: 2, child: SoftCard(child: BarChart([1200, 1800, 1500, 2400, 2100, 2900, 2450], ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'], color: C.green))),
        SectionTitleInline('Recent payouts', action: 'History', onAction: () => go(context, const HistoryPage())),
        for (var i = 0; i < app.payouts.length; i++)
          Reveal(i: i, child: SoftCard(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFE8F7F0), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.account_balance_rounded, color: C.green, size: 21)), const SizedBox(width: 12), Expanded(child: Text(app.payouts[i].date, style: const TextStyle(fontWeight: FontWeight.w800))), Text(rs(app.payouts[i].amount), style: const TextStyle(fontWeight: FontWeight.w900, color: C.green))]))),
      ]);
}

class SectionTitleInline extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;
  const SectionTitleInline(this.title, {super.key, required this.action, required this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 22, 0, 12),
        child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), Tap(onTap: onAction, child: Text('$action  ›', style: const TextStyle(color: C.green, fontWeight: FontWeight.w800, fontSize: 12)))]),
      );
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) => Column(children: [
            const Head('Delivery history', sub: 'Your completed deliveries'),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20), children: [
                for (var i = 0; i < app.history.length; i++)
                  Reveal(
                    i: i,
                    child: SoftCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(children: [
                        Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFE8F7F0), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.check_rounded, color: C.green)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(app.history[i].rest, style: const TextStyle(fontWeight: FontWeight.w900)), Text('${app.history[i].id}  •  ${app.history[i].dist}', style: const TextStyle(color: C.muted, fontSize: 12.5))])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(rs(app.history[i].pay), style: const TextStyle(fontWeight: FontWeight.w900, color: C.green)), const Pill('COMPLETED', fg: C.green)]),
                      ]),
                    ),
                  ),
              ]),
            ),
          ]),
        ),
      );
}

class RiderProfile extends StatelessWidget {
  const RiderProfile({super.key});
  @override
  Widget build(BuildContext context) {
    Widget tile(int i, IconData ic, String t, VoidCallback f, {Color color = C.green}) => Reveal(
          i: i,
          child: SoftCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            onTap: f,
            child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(13)), child: Icon(ic, color: color, size: 21)), const SizedBox(width: 14), Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800))), const Icon(Icons.chevron_right_rounded, color: C.faint)]),
          ),
        );
    return ListView(padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 20), children: [
      const Text('Profile', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
      const SizedBox(height: 16),
      Reveal(
        child: SoftCard(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Container(width: 66, height: 66, alignment: Alignment.center, decoration: const BoxDecoration(gradient: C.green2, shape: BoxShape.circle), child: Text(app.riderName[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(app.riderName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 4), const Row(children: [Icon(Icons.star_rounded, color: C.amber, size: 17), SizedBox(width: 3), Text('4.9  •  248 deliveries', style: TextStyle(color: C.muted, fontSize: 12.5))]), const SizedBox(height: 8), const Pill('TOP RIDER', fg: C.green)])),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      tile(1, Icons.person_outline_rounded, 'Personal information', () => go(context, FormPage('Personal information', [('Full name', app.riderName, Icons.person_outline_rounded), ('Phone', app.riderPhone, Icons.phone_outlined)], (v) {
            app.riderName = v[0];
            app.riderPhone = v[1];
            app.ping();
          }))),
      tile(2, Icons.two_wheeler_rounded, 'Vehicle details', () => go(context, FormPage('Vehicle details', [('Vehicle', riderInfo['vehicle']!, Icons.two_wheeler_rounded), ('Registration number', riderInfo['plate']!, Icons.pin_outlined), ('Colour', riderInfo['color']!, Icons.palette_outlined)], (v) {
            riderInfo['vehicle'] = v[0];
            riderInfo['plate'] = v[1];
            riderInfo['color'] = v[2];
          }))),
      tile(3, Icons.verified_user_outlined, 'Documents & verification', () => go(context, const DocsPage())),
      tile(4, Icons.history_rounded, 'Delivery history', () => go(context, const HistoryPage())),
      tile(5, Icons.help_outline_rounded, 'Help & support', () => go(context, const HelpPage())),
      tile(6, Icons.logout_rounded, 'Switch role / Log out', () => goRoot(context, const RolePage()), color: C.navy),
    ]);
  }
}

class DocsPage extends StatelessWidget {
  const DocsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) => Column(children: [
            const Head('Vehicle & documents', sub: 'Keep your account verified'),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20), children: [
                for (var i = 0; i < app.docs.length; i++)
                  Reveal(
                    i: i,
                    child: SoftCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(children: [
                        Container(width: 44, height: 44, decoration: BoxDecoration(color: C.tint, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.description_rounded, color: C.orange)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(app.docs[i].name, style: const TextStyle(fontWeight: FontWeight.w900))),
                        Pill(app.docs[i].status.toUpperCase(), fg: app.docs[i].status == 'Verified' ? C.green : (app.docs[i].status == 'Pending' ? C.amber : const Color(0xFF3F86CF))),
                      ]),
                    ),
                  ),
                const SizedBox(height: 6),
                OutBtn('Upload a document', icon: Icons.add_rounded, color: C.green, onTap: () => sheet<void>(context, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Add a document', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      for (final n in const ['Insurance certificate', 'Police character certificate', 'Utility bill'])
                        SoftCard(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), onTap: () { app.docs.add(Doc(n, 'Pending')); app.ping(); Navigator.pop(context); }, child: Row(children: [const Icon(Icons.upload_file_rounded, color: C.orange), const SizedBox(width: 12), Expanded(child: Text(n, style: const TextStyle(fontWeight: FontWeight.w800)))])),
                    ]))),
                const SizedBox(height: 12),
                GradBtn('Submit for review', gradient: C.green2, onTap: () => toast(context, 'Documents sent for review')),
              ]),
            ),
          ]),
        ),
      );
}
