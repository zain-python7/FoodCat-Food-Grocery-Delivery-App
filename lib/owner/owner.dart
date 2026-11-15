import 'package:flutter/material.dart';
import '../core/art.dart';
import '../core/data.dart';
import '../core/sheet.dart';
import '../core/theme.dart';
import '../core/ui.dart';
import '../role_page.dart';

const _purple = Color(0xFF7A5AF8);
final Map<String, String> ownerInfo = {'name': 'The Burger Lab', 'address': 'Gulberg III, Lahore', 'hours': '11:00 AM – 1:00 AM', 'phone': '042 3555 0188'};

class OwnerLogin extends StatefulWidget {
  const OwnerLogin({super.key});
  @override
  State<OwnerLogin> createState() => _OwnerLoginState();
}

class _OwnerLoginState extends State<OwnerLogin> {
  final _f = GlobalKey<FormState>();
  final email = TextEditingController(), pass = TextEditingController();
  bool busy = false;
  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    FocusScope.of(context).unfocus();
    if (!_f.currentState!.validate()) return;
    setState(() => busy = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    goRoot(context, const OwnerShell());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListView(padding: EdgeInsets.zero, children: [
          Container(
            height: 250,
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 12, 24, 24),
            decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF9B83FA), Color(0xFF5B3FD6)]), borderRadius: BorderRadius.vertical(bottom: Radius.circular(36))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconCircle(Icons.arrow_back_ios_new_rounded, color: C.ink, size: 42, onTap: () => Navigator.of(context).maybePop()),
              const Spacer(),
              const Reveal(child: Text('Restaurant portal', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.6))),
              const SizedBox(height: 4),
              Reveal(i: 1, child: Text('Manage orders, menu and growth.', style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600))),
            ]),
          ),
          Form(
            key: _f,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const SizedBox(height: 8),
                Reveal(i: 2, child: AppField(email, 'Business email', Icons.email_outlined, keyboard: TextInputType.emailAddress, action: TextInputAction.next, validator: vEmail)),
                const SizedBox(height: 14),
                Reveal(i: 3, child: AppField(pass, 'Password', Icons.lock_outline_rounded, obscure: true, action: TextInputAction.done, onSubmit: (_) => _go(), validator: vPass)),
                const SizedBox(height: 22),
                Reveal(i: 4, child: GradBtn('Sign in', loading: busy, gradient: const LinearGradient(colors: [Color(0xFF9B83FA), Color(0xFF5B3FD6)]), onTap: _go)),
              ]),
            ),
          ),
        ]),
      );
}

class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});
  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  int i = 0;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => Scaffold(
          body: Column(children: [
            Expanded(child: TabFade(index: i, pages: [OwnerDashboard(onOrders: () => setState(() => i = 1)), OwnerOrders(), OwnerMenu(), OwnerMore()])),
            AppNav(
              index: i,
              onTap: (x) => setState(() => i = x),
              items: const [
                NavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
                NavItem(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Orders'),
                NavItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu_rounded, 'Menu'),
                NavItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'More'),
              ],
            ),
          ]),
        ),
      );
}

List<Order> ownerOrders() => app.orders.where((o) => o.rid == app.ownerRid).toList();

Widget orderTile(BuildContext context, Order o, int i) => Reveal(
      i: i,
      child: SoftCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        onTap: () => go(context, OwnerOrderPage(o)),
        child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: statusColor(o.status).withOpacity(0.13), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.receipt_long_rounded, color: statusColor(o.status))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${o.id}  •  ${o.customer}', style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text('${o.items} items  •  ${rs(o.total)}', style: const TextStyle(color: C.muted, fontSize: 12.5))])),
          Pill(o.status.label.toUpperCase(), fg: statusColor(o.status)),
        ]),
      ),
    );

class OwnerDashboard extends StatelessWidget {
  final VoidCallback onOrders;
  const OwnerDashboard({super.key, required this.onOrders});
  @override
  Widget build(BuildContext context) {
    final os = ownerOrders();
    final fresh = os.where((o) => o.status == OStatus.placed).length;
    Widget stat(IconData ic, Color c, String v, String l) => Expanded(child: SoftCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: c.withOpacity(0.13), borderRadius: BorderRadius.circular(12)), child: Icon(ic, color: c, size: 20)), const SizedBox(height: 10), Text(v, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 21)), Text(l, style: const TextStyle(color: C.muted, fontSize: 12))])));
    return ListView(padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 20), children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${ownerInfo['name']!.toUpperCase()}  •  RESTAURANT PORTAL', style: const TextStyle(color: _purple, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8)), const SizedBox(height: 4), const Text('Dashboard', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.4))])),
        Tap(
          onTap: () { app.ownerOpen = !app.ownerOpen; app.ping(); },
          child: AnimatedContainer(duration: const Duration(milliseconds: 300), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), decoration: BoxDecoration(color: app.ownerOpen ? const Color(0xFFE8F7F0) : C.line, borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 9, color: app.ownerOpen ? C.green : C.faint), const SizedBox(width: 6), Text(app.ownerOpen ? 'Open' : 'Closed', style: TextStyle(fontWeight: FontWeight.w800, color: app.ownerOpen ? C.green : C.muted, fontSize: 12.5))])),
        ),
      ]),
      const SizedBox(height: 18),
      Reveal(
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
          decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF9B83FA), Color(0xFF5B3FD6)]), borderRadius: BorderRadius.circular(26), boxShadow: [BoxShadow(color: _purple.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TODAY\'S REVENUE', style: TextStyle(color: Color(0xFFE2DAFF), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
            const SizedBox(height: 4),
            CountUp(app.ownerRevenue, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.6)),
            const Text('↑ 14.2% vs yesterday', style: TextStyle(color: Color(0xFFE2DAFF), fontWeight: FontWeight.w700, fontSize: 12.5)),
            const SizedBox(height: 8),
            const LineChart([8, 12, 10, 16, 14, 20, 18, 24], color: Colors.white, light: true, height: 80),
          ]),
        ),
      ),
      const SizedBox(height: 14),
      Reveal(i: 1, child: Row(children: [stat(Icons.shopping_bag_rounded, C.orange, '${app.ownerOrdersToday}', 'Orders today'), const SizedBox(width: 14), stat(Icons.notifications_active_rounded, C.amber, '$fresh', 'New orders')])),
      const SizedBox(height: 14),
      Reveal(i: 2, child: Row(children: [stat(Icons.star_rounded, C.green, '4.9', 'Avg rating'), const SizedBox(width: 14), stat(Icons.restaurant_menu_rounded, _purple, '${app.menuOf(app.ownerRid).length}', 'Menu items')])),
      SectionTitleRow('Recent orders', 'View all', onOrders),
      if (os.isEmpty) const Empty(Icons.receipt_long_rounded, 'No orders yet', 'New orders will appear here.'),
      for (var i = 0; i < os.take(4).length; i++) orderTile(context, os[i], i),
    ]);
  }
}

class SectionTitleRow extends StatelessWidget {
  final String title, action;
  final VoidCallback onTap;
  const SectionTitleRow(this.title, this.action, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(0, 22, 0, 12), child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), Tap(onTap: onTap, child: Text('$action  ›', style: const TextStyle(color: _purple, fontWeight: FontWeight.w800, fontSize: 12)))]));
}

class OwnerOrders extends StatefulWidget {
  const OwnerOrders({super.key});
  @override
  State<OwnerOrders> createState() => _OwnerOrdersState();
}

class _OwnerOrdersState extends State<OwnerOrders> {
  String tab = 'New';
  bool _in(Order o) {
    switch (tab) {
      case 'New':
        return o.status == OStatus.placed;
      case 'Active':
        return o.status == OStatus.accepted || o.status == OStatus.preparing;
      case 'Ready':
        return o.status == OStatus.ready || o.status == OStatus.pickedUp;
      default:
        return o.status == OStatus.delivered || o.status == OStatus.rejected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = ownerOrders();
    final list = all.where(_in).toList();
    return Column(children: [
      const Head('Orders', sub: 'Manage incoming orders', back: false),
      Chips(const ['New', 'Active', 'Ready', 'Done'], selected: tab, onTap: (v) => setState(() => tab = v)),
      const SizedBox(height: 14),
      Expanded(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: list.isEmpty
              ? Empty(Icons.inbox_rounded, 'Nothing in "$tab"', 'Orders will show up here as they move along.')
              : ListView(key: ValueKey(tab), padding: const EdgeInsets.fromLTRB(24, 0, 24, 20), children: [for (var i = 0; i < list.length; i++) orderTile(context, list[i], i)]),
        ),
      ),
    ]);
  }
}

class OwnerOrderPage extends StatelessWidget {
  final Order o;
  const OwnerOrderPage(this.o, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            final s = o.status;
            Widget? action;
            if (s == OStatus.placed) {
              action = Row(children: [
                Expanded(child: OutBtn('Reject', color: C.red, onTap: () async {
                  final ok = await confirm(context, title: 'Reject this order?', body: 'The customer will be notified right away.', yes: 'Reject', danger: true);
                  if (ok) app.reject(o);
                })),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: GradBtn('Accept order', onTap: () => app.advance(o))),
              ]);
            } else if (s == OStatus.accepted) {
              action = GradBtn('Start preparing', icon: Icons.soup_kitchen_rounded, onTap: () => app.advance(o));
            } else if (s == OStatus.preparing) {
              action = GradBtn('Mark as ready', icon: Icons.check_circle_rounded, onTap: () => app.advance(o));
            }
            return Column(children: [
              Head(o.id, sub: '${o.customer}  •  ${o.address}', trailing: Pill(s.label.toUpperCase(), fg: statusColor(s))),
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 20), children: [
                  const Label('ITEMS'),
                  Reveal(
                    child: SoftCard(
                      child: Column(children: [
                        for (final l in o.lines)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(children: [
                              SizedBox(width: 48, height: 48, child: FoodArt(l.food.art, radius: 14, scale: 1.1)),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${l.food.name} × ${l.qty}', style: const TextStyle(fontWeight: FontWeight.w900)), if (l.extras.isNotEmpty) Text(l.extras.join(', '), style: const TextStyle(color: C.muted, fontSize: 12))])),
                              Text(rs(l.total), style: const TextStyle(fontWeight: FontWeight.w800)),
                            ]),
                          ),
                      ]),
                    ),
                  ),
                  if (o.note.isNotEmpty) ...[
                    const Label('CUSTOMER NOTE'),
                    SoftCard(color: C.tint, shadow: false, child: Row(children: [const Icon(Icons.sticky_note_2_rounded, color: C.orange), const SizedBox(width: 12), Expanded(child: Text(o.note, style: const TextStyle(fontWeight: FontWeight.w700)))])),
                  ],
                  const Label('PAYMENT'),
                  Reveal(
                    i: 1,
                    child: SoftCard(
                      child: Column(children: [
                        _r('Subtotal', rs(o.sub)),
                        _r('Delivery fee', o.fee == 0 ? 'Free' : rs(o.fee)),
                        _r('Tax', rs(o.tax)),
                        if (o.disc > 0) _r('Discount', '- ${rs(o.disc)}'),
                        const Divider(height: 20, color: C.line),
                        _r('Total', rs(o.total), bold: true),
                        const SizedBox(height: 4),
                        _r('Method', o.payment),
                      ]),
                    ),
                  ),
                  if (o.rider != null) ...[const Label('RIDER'), SoftCard(child: Row(children: [const Icon(Icons.two_wheeler_rounded, color: C.green), const SizedBox(width: 12), Expanded(child: Text(o.rider!, style: const TextStyle(fontWeight: FontWeight.w900))), Text(s.index >= OStatus.pickedUp.index ? 'Picked up' : 'Assigned', style: const TextStyle(color: C.muted, fontWeight: FontWeight.w700))]))],
                ]),
              ),
              if (action != null) Padding(padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.of(context).padding.bottom + 16), child: action),
            ]);
          },
        ),
      );

  Widget _r(String l, String v, {bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Expanded(child: Text(l, style: TextStyle(color: bold ? C.ink : C.muted, fontWeight: bold ? FontWeight.w900 : FontWeight.w600))), Text(v, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w700, fontSize: bold ? 16 : 14))]));
}

class OwnerMenu extends StatefulWidget {
  const OwnerMenu({super.key});
  @override
  State<OwnerMenu> createState() => _OwnerMenuState();
}

class _OwnerMenuState extends State<OwnerMenu> {
  String cat = 'All';
  @override
  Widget build(BuildContext context) {
    final items = app.menuOf(app.ownerRid).where((f) => cat == 'All' || f.cat == cat).toList();
    return Column(children: [
      Head('Menu', sub: '${app.menuOf(app.ownerRid).length} items', back: false, trailing: IconCircle(Icons.add_rounded, color: Colors.white, bg: _purple, onTap: () => go(context, const FoodEditPage()))),
      Chips(['All', ...app.menuCats], selected: cat, onTap: (v) => setState(() => cat = v)),
      const SizedBox(height: 14),
      Expanded(
        child: items.isEmpty
            ? const Empty(Icons.restaurant_menu_rounded, 'No items here', 'Tap + to add your first dish.')
            : ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 20), children: [
                for (var i = 0; i < items.length; i++)
                  Reveal(
                    i: i,
                    child: SoftCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      onTap: () => go(context, FoodEditPage(food: items[i])),
                      child: Row(children: [
                        Opacity(opacity: items[i].available ? 1 : 0.45, child: SizedBox(width: 62, height: 62, child: FoodArt(items[i].art, radius: 16, scale: 1.1))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(items[i].name, style: const TextStyle(fontWeight: FontWeight.w900)), Text(items[i].cat, style: const TextStyle(color: C.muted, fontSize: 12)), const SizedBox(height: 4), Text(rs(items[i].price), style: const TextStyle(color: C.orange, fontWeight: FontWeight.w900))])),
                        Switch(value: items[i].available, onChanged: (v) { items[i].available = v; app.ping(); setState(() {}); }),
                      ]),
                    ),
                  ),
              ]),
      ),
    ]);
  }
}

class FoodEditPage extends StatefulWidget {
  final Food? food;
  const FoodEditPage({super.key, this.food});
  @override
  State<FoodEditPage> createState() => _FoodEditPageState();
}

class _FoodEditPageState extends State<FoodEditPage> {
  final _f = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.food?.name ?? '');
  late final desc = TextEditingController(text: widget.food?.desc ?? '');
  late final price = TextEditingController(text: widget.food == null ? '' : '${widget.food!.price}');
  late String cat = widget.food?.cat ?? app.menuCats.first;
  late Art art = widget.food?.art ?? (kCatArt[cat] ?? Art.burger);
  late bool avail = widget.food?.available ?? true;
  bool busy = false;
  @override
  void dispose() {
    name.dispose();
    desc.dispose();
    price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_f.currentState!.validate()) return;
    setState(() => busy = true);
    await Future.delayed(const Duration(milliseconds: 600));
    final p = int.parse(price.text.trim());
    final f = widget.food;
    if (f == null) {
      app.foods.add(Food('f${DateTime.now().millisecondsSinceEpoch}', app.ownerRid, name.text.trim(), desc.text.trim(), cat, p, art, available: avail));
    } else {
      f.name = name.text.trim();
      f.desc = desc.text.trim();
      f.cat = cat;
      f.price = p;
      f.art = art;
      f.available = avail;
    }
    app.ping();
    if (!mounted) return;
    toast(context, f == null ? 'Dish added to your menu' : 'Dish updated');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          Head(widget.food == null ? 'Add new dish' : 'Edit dish', sub: 'What are you serving?', trailing: widget.food == null ? null : IconCircle(Icons.delete_outline_rounded, color: C.red, onTap: () async {
                final ok = await confirm(context, title: 'Delete this dish?', body: 'It will disappear from your menu.', yes: 'Delete', danger: true);
                if (ok) {
                  app.foods.remove(widget.food);
                  app.ping();
                  if (context.mounted) Navigator.of(context).pop();
                }
              })),
          Expanded(
            child: Form(
              key: _f,
              child: ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 24), children: [
                Center(child: SizedBox(width: 120, height: 120, child: FoodArt(art, radius: 30, scale: 1.15))),
                const SizedBox(height: 12),
                SizedBox(
                  height: 62,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: Art.values.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => Tap(onTap: () => setState(() => art = Art.values[i]), child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 62, height: 62, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: art == Art.values[i] ? _purple : Colors.transparent, width: 2.2)), child: FoodArt(Art.values[i], radius: 16, scale: 1.1))),
                  ),
                ),
                const SizedBox(height: 18),
                AppField(name, 'Dish name', Icons.restaurant_rounded, action: TextInputAction.next, validator: (v) => vReq(v, 'Enter the dish name')),
                const SizedBox(height: 14),
                AppField(desc, 'Short description', Icons.notes_rounded, maxLines: 2, validator: (v) => (v ?? '').trim().length < 8 ? 'Describe the dish in a few words' : null),
                const SizedBox(height: 14),
                AppField(price, 'Price (Rs.)', Icons.payments_outlined, keyboard: TextInputType.number, validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null) return 'Enter a valid price';
                  if (n < 50 || n > 20000) return 'Price should be between 50 and 20,000';
                  return null;
                }),
                const Label('CATEGORY'),
                Chips(app.menuCats, selected: cat, onTap: (v) => setState(() => cat = v), padding: EdgeInsets.zero),
                const SizedBox(height: 14),
                SoftCard(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [const Expanded(child: Text('Available to order', style: TextStyle(fontWeight: FontWeight.w800))), Switch(value: avail, onChanged: (v) => setState(() => avail = v))])),
                const SizedBox(height: 22),
                GradBtn(widget.food == null ? 'Add to menu' : 'Save changes', loading: busy, onTap: _save),
              ]),
            ),
          ),
        ]),
      );
}

class OwnerMore extends StatelessWidget {
  const OwnerMore({super.key});
  @override
  Widget build(BuildContext context) {
    Widget tile(int i, IconData ic, String t, String s, VoidCallback f, {Color color = _purple}) => Reveal(
          i: i,
          child: SoftCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            onTap: f,
            child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: Icon(ic, color: color, size: 22)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.w900)), Text(s, style: const TextStyle(color: C.muted, fontSize: 12))])), const Icon(Icons.chevron_right_rounded, color: C.faint)]),
          ),
        );
    return ListView(padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 20), children: [
      const Text('More', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
      const SizedBox(height: 16),
      tile(0, Icons.storefront_rounded, 'Restaurant profile', ownerInfo['name']!, () => go(context, FormPage('Restaurant profile', [('Restaurant name', ownerInfo['name']!, Icons.storefront_rounded), ('Address', ownerInfo['address']!, Icons.location_on_outlined), ('Opening hours', ownerInfo['hours']!, Icons.schedule_rounded), ('Phone', ownerInfo['phone']!, Icons.phone_outlined)], (v) {
            ownerInfo['name'] = v[0];
            ownerInfo['address'] = v[1];
            ownerInfo['hours'] = v[2];
            ownerInfo['phone'] = v[3];
            app.ping();
          }))),
      tile(1, Icons.category_rounded, 'Categories', '${app.menuCats.length} menu categories', () => go(context, const CategoriesPage())),
      tile(2, Icons.insights_rounded, 'Analytics', 'Sales and top dishes', () => go(context, const OwnerAnalytics())),
      tile(3, Icons.reviews_rounded, 'Reviews', '4.9 average rating', () => go(context, const ReviewsPage())),
      tile(4, Icons.settings_rounded, 'Settings', 'Alerts and ordering', () => go(context, const OwnerSettings())),
      tile(5, Icons.swap_horiz_rounded, 'Switch role / Log out', 'Back to role selection', () => goRoot(context, const RolePage()), color: C.navy),
    ]);
  }
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  void _add() {
    final c = TextEditingController();
    final f = GlobalKey<FormState>();
    sheet<void>(
      context,
      Form(
        key: f,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('New category', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          AppField(c, 'Category name', Icons.category_rounded, validator: (v) {
            final t = (v ?? '').trim();
            if (t.isEmpty) return 'Enter a category name';
            if (app.menuCats.any((x) => x.toLowerCase() == t.toLowerCase())) return 'This category already exists';
            return null;
          }),
          const SizedBox(height: 14),
          GradBtn('Add category', onTap: () {
            if (!f.currentState!.validate()) return;
            app.menuCats.add(c.text.trim());
            app.ping();
            Navigator.pop(context);
            setState(() {});
          }),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          Head('Categories', sub: 'Organise your menu', trailing: IconCircle(Icons.add_rounded, color: Colors.white, bg: _purple, onTap: _add)),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20), children: [
              for (var i = 0; i < app.menuCats.length; i++)
                Reveal(
                  i: i,
                  child: SoftCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(color: _purple.withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.category_rounded, color: _purple)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(app.menuCats[i], style: const TextStyle(fontWeight: FontWeight.w900)), Text('${app.menuOf(app.ownerRid).where((f) => f.cat == app.menuCats[i]).length} dishes', style: const TextStyle(color: C.muted, fontSize: 12))])),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: C.red),
                        onPressed: () {
                          final n = app.menuOf(app.ownerRid).where((f) => f.cat == app.menuCats[i]).length;
                          if (n > 0) {
                            toast(context, 'Move or delete its $n dishes first');
                            return;
                          }
                          app.menuCats.removeAt(i);
                          app.ping();
                          setState(() {});
                        },
                      ),
                    ]),
                  ),
                ),
            ]),
          ),
        ]),
      );
}

class OwnerAnalytics extends StatelessWidget {
  const OwnerAnalytics({super.key});
  @override
  Widget build(BuildContext context) {
    final top = app.menuOf(app.ownerRid).take(4).toList();
    return Scaffold(
      body: Column(children: [
        const Head('Analytics', sub: 'How your restaurant is doing'),
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20), children: [
            Reveal(child: Row(children: [for (final s in [(rs(app.ownerRevenue), 'Revenue'), ('${app.ownerOrdersToday}', 'Orders'), (rs(app.ownerRevenue / (app.ownerOrdersToday == 0 ? 1 : app.ownerOrdersToday)), 'Avg order')]) Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: SoftCard(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8), child: Column(children: [FittedBox(child: Text(s.$1, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))), const SizedBox(height: 2), Text(s.$2, style: const TextStyle(color: C.muted, fontSize: 11))]))))])),
            const Label('ORDERS THIS WEEK'),
            const Reveal(i: 1, child: SoftCard(child: BarChart([62, 80, 71, 96, 110, 142, 128], ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'], color: _purple))),
            const Label('TOP DISHES'),
            for (var i = 0; i < top.length; i++)
              Reveal(
                i: i + 2,
                child: SoftCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    SizedBox(width: 48, height: 48, child: FoodArt(top[i].art, radius: 14, scale: 1.1)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(top[i].name, style: const TextStyle(fontWeight: FontWeight.w900))),
                    Text('${[84, 61, 47, 33][i]} sold', style: const TextStyle(color: C.muted, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          const Head('Reviews', sub: 'What customers are saying'),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20), children: [
              Reveal(child: SoftCard(child: Row(children: [const Text('4.9', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [for (var i = 0; i < 5; i++) const Icon(Icons.star_rounded, color: C.amber, size: 20)]), const Text('Based on 318 reviews', style: TextStyle(color: C.muted, fontSize: 12.5))]))]))),
              const SizedBox(height: 14),
              for (var i = 0; i < app.reviews.length; i++)
                Reveal(
                  i: i + 1,
                  child: SoftCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Expanded(child: Text(app.reviews[i].$1, style: const TextStyle(fontWeight: FontWeight.w900))), for (var s = 0; s < 5; s++) Icon(Icons.star_rounded, size: 17, color: s < app.reviews[i].$2 ? C.amber : C.line)]),
                      const SizedBox(height: 6),
                      Text(app.reviews[i].$3, style: const TextStyle(color: C.muted, height: 1.4)),
                    ]),
                  ),
                ),
            ]),
          ),
        ]),
      );
}

class OwnerSettings extends StatefulWidget {
  const OwnerSettings({super.key});
  @override
  State<OwnerSettings> createState() => _OwnerSettingsState();
}

class _OwnerSettingsState extends State<OwnerSettings> {
  bool auto = app.ownerAuto;
  @override
  Widget build(BuildContext context) {
    Widget sw(int i, IconData ic, String t, String s, bool v, ValueChanged<bool> f) => Reveal(
          i: i,
          child: SoftCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: _purple.withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: Icon(ic, color: _purple)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.w900)), Text(s, style: const TextStyle(color: C.muted, fontSize: 12))])), Switch(value: v, onChanged: f)]),
          ),
        );
    return Scaffold(
      body: Column(children: [
        const Head('Settings', sub: 'Alerts and ordering'),
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(24, 4, 24, 20), children: [
            sw(0, Icons.storefront_rounded, 'Accepting orders', 'Turn off to pause new orders', app.ownerOpen, (v) { app.ownerOpen = v; app.ping(); setState(() {}); }),
            sw(1, Icons.flash_auto_rounded, 'Auto-accept orders', 'Accept new orders without confirming', auto, (v) { app.ownerAuto = v; app.ping(); setState(() => auto = v); }),
          ]),
        ),
      ]),
    );
  }
}
