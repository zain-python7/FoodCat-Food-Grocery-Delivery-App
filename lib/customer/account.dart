import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/art.dart';
import '../core/data.dart';
import '../core/theme.dart';
import '../core/ui.dart';
import '../role_page.dart';
import 'checkout.dart';
import 'common.dart';
import 'restaurant.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String dateStr(DateTime d) => '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
String ago(DateTime d) {
  final m = DateTime.now().difference(d).inMinutes;
  if (m < 1) return 'Just now';
  if (m < 60) return '${m}m ago';
  if (m < 1440) return '${m ~/ 60}h ago';
  return '${m ~/ 1440}d ago';
}

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});
  @override
  Widget build(BuildContext context) {
    final list = app.rests.where((r) => app.favs.contains(r.id)).toList();
    return Column(children: [
      Head('Saved', sub: '${list.length} favorite place${list.length == 1 ? '' : 's'}', back: false),
      Expanded(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: list.isEmpty
              ? const Empty(Icons.favorite_border_rounded, 'No favorites yet', 'Tap the heart on a restaurant to save it here.')
              : ListView(padding: const EdgeInsets.only(bottom: 20), children: [for (var i = 0; i < list.length; i++) RestCard(list[i], i: i)]),
        ),
      ),
    ]);
  }
}

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});
  @override
  Widget build(BuildContext context) {
    final mine = app.myOrders;
    final active = mine.where((o) => o.open).toList();
    final past = mine.where((o) => !o.open).toList();
    return Column(children: [
      const Head('My orders', sub: 'Track and reorder your favorites', back: false),
      Expanded(
        child: mine.isEmpty
            ? const Empty(Icons.receipt_long_rounded, 'No orders yet', 'When you order, it will show up here.')
            : ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 20), children: [
                if (active.isNotEmpty) const Label('ACTIVE'),
                for (var i = 0; i < active.length; i++)
                  Reveal(
                    i: i,
                    child: Tap(
                      onTap: () => go(context, TrackingPage(active[i])),
                      scale: 0.98,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(gradient: C.hero, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: C.orange.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(active[i].id, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 12))),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.22), borderRadius: BorderRadius.circular(20)), child: Text(active[i].status.label.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5))),
                          ]),
                          const SizedBox(height: 8),
                          Text(app.rest(active[i].rid).name, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
                          Text('${active[i].items} items  •  ${rs(active[i].total)}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 14),
                          Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Text('Track order', style: TextStyle(color: C.orange, fontWeight: FontWeight.w900))),
                        ]),
                      ),
                    ),
                  ),
                if (past.isNotEmpty) const Label('PAST ORDERS'),
                for (var i = 0; i < past.length; i++)
                  Reveal(
                    i: i + 1,
                    child: SoftCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        SizedBox(width: 62, height: 62, child: FoodArt(app.rest(past[i].rid).art, radius: 16)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(app.rest(past[i].rid).name, style: const TextStyle(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 2),
                            Text('${dateStr(past[i].at)}  •  ${rs(past[i].total)}', style: const TextStyle(color: C.muted, fontSize: 12)),
                            const SizedBox(height: 6),
                            Pill(past[i].status.label.toUpperCase(), fg: past[i].status == OStatus.delivered ? C.green : C.red),
                          ]),
                        ),
                        Tap(
                          onTap: () {
                            app.reorder(past[i]);
                            go(context, const CartPage());
                          },
                          child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: C.tint, borderRadius: BorderRadius.circular(14)), child: const Text('Reorder', style: TextStyle(color: C.orange, fontWeight: FontWeight.w900, fontSize: 12))),
                        ),
                      ]),
                    ),
                  ),
              ]),
      ),
    ]);
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) => Column(children: [
            Head('Notifications', sub: unreadNotes() == 0 ? 'You are all caught up' : '${unreadNotes()} new', trailing: unreadNotes() == 0 ? null : Tap(onTap: () { for (final n in app.notes) { n.unread = false; } app.ping(); }, child: const Text('Mark all read', style: TextStyle(color: C.orange, fontWeight: FontWeight.w800, fontSize: 12)))),
            Expanded(
              child: app.notes.isEmpty
                  ? const Empty(Icons.notifications_none_rounded, 'Nothing yet', 'Order updates and offers will appear here.')
                  : ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20), children: [
                      for (var i = 0; i < app.notes.length; i++)
                        Reveal(
                          i: i,
                          child: SoftCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            onTap: () {
                              app.notes[i].unread = false;
                              app.ping();
                            },
                            child: Row(children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(color: app.notes[i].kind == 'done' ? const Color(0xFFE8F7F0) : C.tint, borderRadius: BorderRadius.circular(15)),
                                child: Icon(app.notes[i].kind == 'offer' ? Icons.local_offer_rounded : (app.notes[i].kind == 'done' ? Icons.check_circle_rounded : Icons.delivery_dining_rounded), color: app.notes[i].kind == 'done' ? C.green : C.orange),
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(app.notes[i].title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(app.notes[i].body, style: const TextStyle(color: C.muted, fontSize: 12.5, height: 1.3))])),
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text(ago(app.notes[i].at), style: const TextStyle(color: C.faint, fontSize: 11, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                AnimatedContainer(duration: const Duration(milliseconds: 250), width: 9, height: 9, decoration: BoxDecoration(color: app.notes[i].unread ? C.orange : Colors.transparent, shape: BoxShape.circle)),
                              ]),
                            ]),
                          ),
                        ),
                    ]),
            ),
          ]),
        ),
      );
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    Widget tile(int i, IconData icon, String t, VoidCallback f, {Color color = C.orange}) => Reveal(
          i: i,
          child: SoftCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            onTap: f,
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color, size: 21)),
              const SizedBox(width: 14),
              Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800))),
              const Icon(Icons.chevron_right_rounded, color: C.faint),
            ]),
          ),
        );
    Widget stat(String v, String l) => Expanded(child: Column(children: [Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)), Text(l, style: const TextStyle(color: Colors.white70, fontSize: 11.5))]));
    final initials = app.name.trim().isEmpty ? 'F' : app.name.trim().split(' ').map((w) => w.isEmpty ? '' : w[0]).take(2).join().toUpperCase();
    return ListView(padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 20), children: [
      const Text('Profile', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
      const SizedBox(height: 16),
      Reveal(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: C.hero, borderRadius: BorderRadius.circular(26), boxShadow: [BoxShadow(color: C.orange.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12))]),
          child: Column(children: [
            Row(children: [
              Container(width: 62, height: 62, alignment: Alignment.center, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Text(initials, style: const TextStyle(color: C.orange, fontWeight: FontWeight.w900, fontSize: 22))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(app.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 19)), Text(app.email, style: const TextStyle(color: Colors.white70, fontSize: 13))])),
            ]),
            const SizedBox(height: 18),
            Row(children: [stat('${app.myOrders.length}', 'Orders'), stat('${app.favs.length}', 'Favorites'), stat('${app.addresses.length}', 'Addresses')]),
          ]),
        ),
      ),
      const SizedBox(height: 18),
      tile(1, Icons.person_outline_rounded, 'Edit profile', () => go(context, FormPage('Edit profile', [('Full name', app.name, Icons.person_outline_rounded), ('Email', app.email, Icons.email_outlined), ('Phone', app.phone, Icons.phone_outlined)], (v) {
            app.name = v[0];
            app.email = v[1];
            app.phone = v[2];
            app.ping();
          }))),
      tile(2, Icons.location_on_outlined, 'My addresses', () => go(context, const AddressesPage())),
      tile(3, Icons.credit_card_rounded, 'Payment methods', () => go(context, const PaymentsPage())),
      tile(4, Icons.settings_outlined, 'Settings', () => go(context, const SettingsPage())),
      tile(5, Icons.help_outline_rounded, 'Help & support', () => go(context, const HelpPage())),
      tile(6, Icons.swap_horiz_rounded, 'Switch role', () {
        app.fullWidth = false;
        goRoot(context, const RolePage());
      }, color: C.navy),
    ]);
  }
}

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) => Column(children: [
            const Head('My addresses', sub: 'Where should we deliver?'),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20), children: [
                for (var i = 0; i < app.addresses.length; i++)
                  Reveal(
                    i: i,
                    child: SoftCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(children: [
                        Container(width: 44, height: 44, decoration: BoxDecoration(color: C.tint, borderRadius: BorderRadius.circular(14)), child: Icon(app.addresses[i].label == 'Work' ? Icons.work_rounded : Icons.home_rounded, color: C.orange)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(app.addresses[i].label, style: const TextStyle(fontWeight: FontWeight.w900)), Text(app.addresses[i].line, style: const TextStyle(color: C.muted, fontSize: 12.5))])),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: C.red),
                          onPressed: () {
                            app.addresses.removeAt(i);
                            if (app.addrIdx >= app.addresses.length) app.addrIdx = 0;
                            app.ping();
                          },
                        ),
                      ]),
                    ),
                  ),
                if (app.addresses.isEmpty) const Padding(padding: EdgeInsets.only(top: 60), child: Empty(Icons.location_off_rounded, 'No saved addresses', 'Add one to speed up checkout.')),
                const SizedBox(height: 8),
                GradBtn('Add new address', icon: Icons.add_rounded, onTap: () => addressSheet(context)),
              ]),
            ),
          ]),
        ),
      );
}

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) => Column(children: [
            const Head('Payment methods', sub: 'Choose how you like to pay'),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20), children: [
                for (var i = 0; i < app.payments.length; i++)
                  Reveal(
                    i: i,
                    child: SoftCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      onTap: () {
                        app.payment = app.payments[i];
                        app.ping();
                      },
                      child: Row(children: [
                        Container(width: 44, height: 44, decoration: BoxDecoration(color: C.tint, borderRadius: BorderRadius.circular(14)), child: Icon(app.payments[i].startsWith('Card') ? Icons.credit_card_rounded : (app.payments[i].contains('wallet') ? Icons.account_balance_wallet_rounded : Icons.payments_rounded), color: C.orange)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(app.payments[i], style: const TextStyle(fontWeight: FontWeight.w900))),
                        if (app.payment == app.payments[i]) const Pill('DEFAULT', fg: C.green),
                      ]),
                    ),
                  ),
              ]),
            ),
          ]),
        ),
      );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            Widget sw(int i, IconData ic, String t, String s, bool v, ValueChanged<bool> f) => Reveal(
                  i: i,
                  child: SoftCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      Container(width: 42, height: 42, decoration: BoxDecoration(color: C.tint, borderRadius: BorderRadius.circular(14)), child: Icon(ic, color: C.orange)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.w900)), Text(s, style: const TextStyle(color: C.muted, fontSize: 12))])),
                      Switch(value: v, onChanged: f),
                    ]),
                  ),
                );
            return Column(children: [
              const Head('Settings', sub: 'Make Foodie yours'),
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20), children: [
                  sw(0, Icons.notifications_active_rounded, 'Push notifications', 'Order updates and rider alerts', app.pushOn, (v) { app.pushOn = v; app.ping(); }),
                  sw(1, Icons.local_offer_rounded, 'Offers & promotions', 'Deals picked for you', app.offersOn, (v) { app.offersOn = v; app.ping(); }),
                  Reveal(
                    i: 2,
                    child: SoftCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      onTap: () {
                        app.recent.clear();
                        toast(context, 'Search history cleared');
                      },
                      child: const Row(children: [Icon(Icons.history_rounded, color: C.orange), SizedBox(width: 14), Expanded(child: Text('Clear search history', style: TextStyle(fontWeight: FontWeight.w900))), Icon(Icons.chevron_right_rounded, color: C.faint)]),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(child: Text('Foodie 1.0.0', style: TextStyle(color: C.faint, fontWeight: FontWeight.w600))),
                ]),
              ),
            ]);
          },
        ),
      );
}

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});
  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int open = -1;
  static const faq = [
    ('How long does delivery take?', 'Most orders arrive within 30 to 50 minutes depending on the restaurant and distance.'),
    ('Can I change my order after placing it?', 'Once the restaurant accepts your order it can no longer be changed. Contact support if you need help.'),
    ('How do I use a promo code?', 'Open checkout, type your code in the promo field and tap Apply.'),
    ('What is the delivery code?', 'Share the 4-digit code shown in order tracking with your rider so they can hand over your food.'),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          const Head('Help & support', sub: 'We are here for you'),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20), children: [
              for (var i = 0; i < faq.length; i++)
                Reveal(
                  i: i,
                  child: SoftCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    onTap: () => setState(() => open = open == i ? -1 : i),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(faq[i].$1, style: const TextStyle(fontWeight: FontWeight.w900))),
                        AnimatedRotation(turns: open == i ? 0.5 : 0, duration: const Duration(milliseconds: 250), child: const Icon(Icons.keyboard_arrow_down_rounded, color: C.orange)),
                      ]),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        child: open == i ? Padding(padding: const EdgeInsets.only(top: 10), child: Text(faq[i].$2, style: const TextStyle(color: C.muted, height: 1.45))) : const SizedBox(width: double.infinity),
                      ),
                    ]),
                  ),
                ),
              const Label('STILL NEED HELP?'),
              SoftCard(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: 'support@foodie.app'));
                  toast(context, 'Email address copied');
                },
                child: const Row(children: [Icon(Icons.email_outlined, color: C.orange), SizedBox(width: 14), Expanded(child: Text('support@foodie.app', style: TextStyle(fontWeight: FontWeight.w900))), Icon(Icons.copy_rounded, size: 18, color: C.faint)]),
              ),
            ]),
          ),
        ]),
      );
}
