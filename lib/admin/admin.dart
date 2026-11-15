import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/art.dart';
import '../core/data.dart';
import '../core/theme.dart';
import '../core/ui.dart';
import '../role_page.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
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
    goRoot(context, const AdminShell());
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    final hero = Container(
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(gradient: C.hero),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('foodie', style: TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.w900, letterSpacing: -1.2)),
        const SizedBox(height: 8),
        const Text('Good food. Great operations.', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 28),
        Floaty(child: SizedBox(width: 150, height: 150, child: FoodArt(Art.burger, radius: 40, bg: Colors.white.withOpacity(0.18), scale: 1.1))),
      ]),
    );
    final form = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _f,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!wide) IconCircle(Icons.arrow_back_ios_new_rounded, color: C.ink, size: 42, onTap: _back),
              if (!wide) const SizedBox(height: 20),
              const Reveal(child: Text('Admin sign in', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.6))),
              const SizedBox(height: 6),
              const Reveal(i: 1, child: Text('Control center for the whole platform.', style: TextStyle(color: C.muted))),
              const SizedBox(height: 26),
              Reveal(i: 2, child: AppField(email, 'Admin email', Icons.email_outlined, keyboard: TextInputType.emailAddress, action: TextInputAction.next, validator: vEmail)),
              const SizedBox(height: 14),
              Reveal(i: 3, child: AppField(pass, 'Password', Icons.lock_outline_rounded, obscure: true, action: TextInputAction.done, onSubmit: (_) => _go(), validator: vPass)),
              const SizedBox(height: 22),
              Reveal(i: 4, child: GradBtn('Sign in', loading: busy, onTap: _go)),
              if (wide) TextButton(onPressed: _back, child: const Text('← Back to role selection', style: TextStyle(color: C.muted, fontWeight: FontWeight.w700))),
            ]),
          ),
        ),
      ),
    );
    return Scaffold(body: wide ? Row(children: [Expanded(child: hero), Expanded(child: form)]) : form);
  }

  void _back() {
    app.fullWidth = false;
    app.ping();
    Navigator.of(context).maybePop();
  }
}

// ---------------------------------------------------------------------------
const _nav = [
  ('Overview', Icons.space_dashboard_rounded),
  ('Restaurants', Icons.storefront_rounded),
  ('Delivery partners', Icons.two_wheeler_rounded),
  ('Customers', Icons.groups_rounded),
  ('Orders', Icons.receipt_long_rounded),
  ('Approvals', Icons.verified_rounded),
  ('Finance', Icons.account_balance_wallet_rounded),
  ('Analytics', Icons.insights_rounded),
  ('Reports', Icons.description_rounded),
  ('Settings', Icons.settings_rounded),
];

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int i = 0;
  final key = GlobalKey<ScaffoldState>();

  Widget _sidebar(bool drawer) => Container(
        width: 264,
        color: Colors.white,
        child: SafeArea(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(padding: EdgeInsets.fromLTRB(24, 24, 24, 4), child: Text('foodie', style: TextStyle(color: C.orange, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1))),
            const Padding(padding: EdgeInsets.fromLTRB(24, 0, 24, 18), child: Text('ADMIN CONSOLE', style: TextStyle(color: C.muted, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.2))),
            Expanded(
              child: ListView(padding: const EdgeInsets.symmetric(horizontal: 14), children: [
                for (var n = 0; n < _nav.length; n++)
                  Tap(
                    onTap: () {
                      setState(() => i = n);
                      if (drawer) Navigator.of(context).pop();
                    },
                    scale: 0.98,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(color: i == n ? C.tint : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        Icon(_nav[n].$2, size: 21, color: i == n ? C.orange : C.muted),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_nav[n].$1, style: TextStyle(fontWeight: FontWeight.w800, color: i == n ? C.orange : C.ink))),
                        if (n == 5 && app.approvals.any((a) => a.status == 'Pending')) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: C.orange, borderRadius: BorderRadius.circular(10)), child: Text('${app.approvals.where((a) => a.status == 'Pending').length}', style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900))),
                      ]),
                    ),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Tap(
                onTap: () {
                  app.fullWidth = false;
                  goRoot(context, const RolePage());
                },
                child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: C.cream, borderRadius: BorderRadius.circular(14)), child: const Row(children: [Icon(Icons.logout_rounded, size: 20, color: C.muted), SizedBox(width: 12), Text('Log out', style: TextStyle(fontWeight: FontWeight.w800))])),
              ),
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final wide = MediaQuery.of(context).size.width >= 900;
          final pages = <Widget>[
            AdminOverview(onApprovals: () => setState(() => i = 5)),
            AdminRestaurants(),
            AdminRiders(),
            AdminCustomers(),
            AdminOrders(),
            AdminApprovals(),
            AdminFinance(),
            AdminAnalytics(),
            AdminReports(),
            AdminSettings(),
          ];
          return Scaffold(
            key: key,
            drawer: wide ? null : Drawer(backgroundColor: Colors.white, child: _sidebar(true)),
            body: Row(children: [
              if (wide) _sidebar(false),
              Expanded(
                child: Column(children: [
                  if (!wide)
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 0),
                      child: Row(children: [IconCircle(Icons.menu_rounded, color: C.ink, onTap: () => key.currentState?.openDrawer()), const SizedBox(width: 12), Text(_nav[i].$1, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))]),
                    ),
                  Expanded(child: TabFade(index: i, pages: pages)),
                ]),
              ),
            ]),
          );
        },
      );
}

class _Page extends StatelessWidget {
  final String title, sub;
  final List<Widget> children;
  const _Page(this.title, this.sub, this.children);
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    return ListView(padding: EdgeInsets.fromLTRB(wide ? 36 : 20, wide ? 32 : 16, wide ? 36 : 20, 32), children: [
      if (wide) Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.6)),
      Text(sub, style: const TextStyle(color: C.muted, fontSize: 14)),
      const SizedBox(height: 22),
      ...children,
    ]);
  }
}

Widget _statGrid(BuildContext context, List<(String, String, IconData, Color)> s) {
  final w = MediaQuery.of(context).size.width;
  final cols = w >= 1200 ? 4 : (w >= 600 ? 2 : 2);
  return GridView.count(
    crossAxisCount: cols,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 14,
    crossAxisSpacing: 14,
    childAspectRatio: w >= 1200 ? 2.2 : 1.55,
    children: [
      for (var i = 0; i < s.length; i++)
        Reveal(
          i: i,
          child: SoftCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: s[i].$4.withOpacity(0.13), borderRadius: BorderRadius.circular(12)), child: Icon(s[i].$3, color: s[i].$4, size: 20)),
              const Spacer(),
              FittedBox(child: Text(s[i].$1, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22))),
              Text(s[i].$2, style: const TextStyle(color: C.muted, fontSize: 12.5)),
            ]),
          ),
        ),
    ],
  );
}

/// Table on wide screens, stacked cards on narrow ones.
class _Records extends StatelessWidget {
  final List<String> heads;
  final List<List<Widget>> rows;
  const _Records(this.heads, this.rows);
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    if (rows.isEmpty) return const SizedBox(height: 220, child: Empty(Icons.inbox_rounded, 'Nothing here yet', 'Records will appear here.'));
    if (!wide) {
      return Column(children: [
        for (var r = 0; r < rows.length; r++)
          Reveal(
            i: r,
            child: SoftCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(children: [
                for (var c = 0; c < heads.length; c++)
                  Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [SizedBox(width: 110, child: Text(heads[c], style: const TextStyle(color: C.muted, fontSize: 12, fontWeight: FontWeight.w700))), Expanded(child: Align(alignment: Alignment.centerLeft, child: rows[r][c]))])),
              ]),
            ),
          ),
      ]);
    }
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), child: Row(children: [for (final h in heads) Expanded(child: Text(h.toUpperCase(), style: const TextStyle(color: C.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8)))])),
        const Divider(height: 1, color: C.line),
        for (var r = 0; r < rows.length; r++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(border: r == rows.length - 1 ? null : const Border(bottom: BorderSide(color: C.line))),
            child: Row(children: [for (final c in rows[r]) Expanded(child: Align(alignment: Alignment.centerLeft, child: c))]),
          ),
      ]),
    );
  }
}

Widget _t(String s, {bool bold = false}) => Text(s, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w600, fontSize: 13.5));

class AdminOverview extends StatelessWidget {
  final VoidCallback onApprovals;
  const AdminOverview({super.key, required this.onApprovals});
  @override
  Widget build(BuildContext context) {
    final delivered = app.orders.where((o) => o.status == OStatus.delivered).fold<int>(0, (a, o) => a + o.total);
    final live = app.orders.where((o) => o.open).toList();
    final pending = app.approvals.where((a) => a.status == 'Pending').length;
    return _Page('Overview', 'Platform health at a glance', [
      _statGrid(context, [
        (rs(1248500 + delivered), 'Gross sales', Icons.payments_rounded, C.orange),
        ('${3420 + app.orders.length}', 'Total orders', Icons.shopping_bag_rounded, const Color(0xFF3F86CF)),
        ('${app.rests.length + app.approvals.where((a) => a.type == 'Restaurant' && a.status == 'Approved').length}', 'Restaurants', Icons.storefront_rounded, const Color(0xFF7A5AF8)),
        ('${84 + (app.riderOnline ? 1 : 0)}', 'Active riders', Icons.two_wheeler_rounded, C.green),
      ]),
      const SizedBox(height: 18),
      LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 800;
        final chart = Reveal(i: 2, child: SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Revenue this week', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), SizedBox(height: 14), LineChart([180, 220, 200, 260, 310, 380, 340], height: 190)])));
        final ops = Reveal(
          i: 3,
          child: SoftCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Live operations', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 14),
              for (final s in [OStatus.placed, OStatus.preparing, OStatus.ready, OStatus.pickedUp])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: statusColor(s), shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(s.label, style: const TextStyle(fontWeight: FontWeight.w700))),
                    AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: Text('${live.where((o) => o.status == s).length}', key: ValueKey(live.where((o) => o.status == s).length), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                  ]),
                ),
              const Divider(height: 24, color: C.line),
              Tap(onTap: onApprovals, child: Row(children: [const Icon(Icons.verified_rounded, color: C.orange, size: 20), const SizedBox(width: 10), Expanded(child: Text('$pending pending approval${pending == 1 ? '' : 's'}', style: const TextStyle(fontWeight: FontWeight.w800))), const Icon(Icons.chevron_right_rounded, color: C.faint)])),
            ]),
          ),
        );
        return wide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: chart), const SizedBox(width: 16), Expanded(flex: 2, child: ops)]) : Column(children: [chart, const SizedBox(height: 16), ops]);
      }),
      const SizedBox(height: 22),
      const Text('Recent orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      _Records(const ['Order', 'Restaurant', 'Customer', 'Total', 'Status'], [
        for (final o in app.orders.take(5)) [_t(o.id, bold: true), _t(app.rest(o.rid).name), _t(o.customer), _t(rs(o.total)), Pill(o.status.label.toUpperCase(), fg: statusColor(o.status))],
      ]),
    ]);
  }
}

class AdminRestaurants extends StatelessWidget {
  const AdminRestaurants({super.key});
  @override
  Widget build(BuildContext context) => _Page('Restaurants', 'Manage partner restaurants', [
        _Records(const ['Restaurant', 'Area', 'Rating', 'Status', 'Action'], [
          for (final r in app.rests)
            [
              _t(r.name, bold: true),
              _t(r.area),
              _t('${r.rating} ★'),
              Pill(r.status.toUpperCase(), fg: r.status == 'Approved' ? C.green : C.red),
              Tap(
                onTap: () {
                  r.status = r.status == 'Approved' ? 'Suspended' : 'Approved';
                  app.ping();
                },
                child: Text(r.status == 'Approved' ? 'Suspend' : 'Reinstate', style: TextStyle(color: r.status == 'Approved' ? C.red : C.green, fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ],
          for (final a in app.approvals.where((a) => a.type == 'Restaurant' && a.status == 'Approved')) [_t(a.name, bold: true), _t(a.city), _t('New'), const Pill('APPROVED', fg: C.green), _t('—')],
        ]),
      ]);
}

class AdminRiders extends StatelessWidget {
  const AdminRiders({super.key});
  @override
  Widget build(BuildContext context) => _Page('Delivery partners', 'Riders on the platform', [
        _Records(const ['Rider', 'City', 'Deliveries', 'Rating', 'Status'], [
          [_t(app.riderName, bold: true), _t('Lahore'), _t('${248 + app.riderJobs - 8}'), _t('4.9 ★'), Pill(app.riderOnline ? 'ONLINE' : 'OFFLINE', fg: app.riderOnline ? C.green : C.muted)],
          [_t('Usman Tariq', bold: true), _t('Lahore'), _t('412'), _t('4.8 ★'), const Pill('ONLINE', fg: C.green)],
          [_t('Zain Ahmed', bold: true), _t('Lahore'), _t('187'), _t('4.7 ★'), const Pill('OFFLINE', fg: C.muted)],
          [_t('Bilal Sheikh', bold: true), _t('Karachi'), _t('96'), _t('4.6 ★'), const Pill('ONLINE', fg: C.green)],
          for (final a in app.approvals.where((a) => a.type == 'Rider' && a.status == 'Approved')) [_t(a.name, bold: true), _t(a.city), _t('0'), _t('New'), const Pill('APPROVED', fg: C.green)],
        ]),
      ]);
}

class AdminCustomers extends StatelessWidget {
  const AdminCustomers({super.key});
  @override
  Widget build(BuildContext context) => _Page('Customers', 'People ordering on Foodie', [
        _Records(const ['Customer', 'City', 'Orders', 'Spent'], [
          [_t(app.name, bold: true), _t('Lahore'), _t('${app.myOrders.length}'), _t(rs(app.myOrders.where((o) => o.status == OStatus.delivered).fold<int>(0, (a, o) => a + o.total)))],
          [_t('Sara K.', bold: true), _t('Lahore'), _t('18'), _t('Rs. 21,480')],
          [_t('Bilal H.', bold: true), _t('Lahore'), _t('11'), _t('Rs. 12,950')],
          [_t('Hina R.', bold: true), _t('Islamabad'), _t('7'), _t('Rs. 8,120')],
        ]),
      ]);
}

class AdminOrders extends StatelessWidget {
  const AdminOrders({super.key});
  @override
  Widget build(BuildContext context) => _Page('Orders', 'Every order, live', [
        _Records(const ['Order', 'Restaurant', 'Customer', 'Total', 'Status'], [
          for (final o in app.orders) [_t(o.id, bold: true), _t(app.rest(o.rid).name), _t(o.customer), _t(rs(o.total)), Pill(o.status.label.toUpperCase(), fg: statusColor(o.status))],
        ]),
      ]);
}

class AdminApprovals extends StatelessWidget {
  const AdminApprovals({super.key});
  @override
  Widget build(BuildContext context) {
    Widget act(Approval a) => a.status == 'Pending'
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            Tap(onTap: () { a.status = 'Approved'; app.ping(); }, child: const Text('Approve', style: TextStyle(color: C.green, fontWeight: FontWeight.w900, fontSize: 13))),
            const SizedBox(width: 14),
            Tap(onTap: () { a.status = 'Rejected'; app.ping(); }, child: const Text('Reject', style: TextStyle(color: C.red, fontWeight: FontWeight.w900, fontSize: 13))),
          ])
        : Pill(a.status.toUpperCase(), fg: a.status == 'Approved' ? C.green : C.red);
    return _Page('Approvals', 'Review new restaurants and riders', [
      _Records(const ['Applicant', 'Type', 'City', 'Decision'], [
        for (final a in app.approvals) [_t(a.name, bold: true), _t(a.type), _t(a.city), act(a)],
      ]),
    ]);
  }
}

class AdminFinance extends StatelessWidget {
  const AdminFinance({super.key});
  @override
  Widget build(BuildContext context) {
    final gross = 1248500 + app.orders.where((o) => o.status == OStatus.delivered).fold<int>(0, (a, o) => a + o.total);
    final fee = (gross * app.commission / 100).round();
    return _Page('Finance', 'Sales, commission and payouts', [
      _statGrid(context, [
        (rs(gross), 'Gross sales', Icons.payments_rounded, C.orange),
        (rs(fee), 'Commission (${app.commission}%)', Icons.percent_rounded, const Color(0xFF7A5AF8)),
        (rs(gross - fee), 'Restaurant payouts', Icons.account_balance_rounded, C.green),
        (rs(18400), 'Refunds', Icons.undo_rounded, C.red),
      ]),
      const SizedBox(height: 18),
      const Reveal(i: 2, child: SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Monthly sales (Rs. thousands)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), SizedBox(height: 16), BarChart([620, 710, 680, 820, 900, 1010], ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'], height: 180)]))),
    ]);
  }
}

class AdminAnalytics extends StatelessWidget {
  const AdminAnalytics({super.key});
  @override
  Widget build(BuildContext context) => _Page('Analytics', 'What is working on the platform', [
        const Reveal(child: SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Orders by hour', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), SizedBox(height: 16), BarChart([12, 18, 40, 72, 55, 38, 64, 88], ['10a', '12p', '2p', '4p', '6p', '8p', '10p', '12a'], color: C.green, height: 180)]))),
        const SizedBox(height: 18),
        const Text('Top restaurants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        _Records(const ['Restaurant', 'Orders', 'Rating'], [
          for (final r in app.rests) [_t(r.name, bold: true), _t('${(r.rating * 210).round()}'), _t('${r.rating} ★')],
        ]),
      ]);
}

class AdminReports extends StatelessWidget {
  const AdminReports({super.key});
  @override
  Widget build(BuildContext context) {
    String orders() => ['id,restaurant,customer,total,status', for (final o in app.orders) '${o.id},"${app.rest(o.rid).name}","${o.customer}",${o.total},${o.status.label}'].join('\n');
    String rests() => ['name,area,rating,status', for (final r in app.rests) '"${r.name}","${r.area}",${r.rating},${r.status}'].join('\n');
    String appr() => ['name,type,city,status', for (final a in app.approvals) '"${a.name}",${a.type},"${a.city}",${a.status}'].join('\n');
    Widget tile(int i, String t, String s, String Function() csv) => Reveal(
          i: i,
          child: SoftCard(
            margin: const EdgeInsets.only(bottom: 12),
            onTap: () {
              Clipboard.setData(ClipboardData(text: csv()));
              toast(context, '$t copied as CSV. Paste it into a spreadsheet');
            },
            child: Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: C.tint, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.description_rounded, color: C.orange)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.w900)), Text(s, style: const TextStyle(color: C.muted, fontSize: 12.5))])), const Icon(Icons.copy_rounded, color: C.faint, size: 19)]),
          ),
        );
    return _Page('Reports', 'Copy live data as CSV', [tile(0, 'Orders report', 'Every order with status and totals', orders), tile(1, 'Restaurants report', 'Partner list with ratings and status', rests), tile(2, 'Approvals report', 'Applicants and decisions', appr)]);
  }
}

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});
  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  final _f = GlobalKey<FormState>();
  late final c = TextEditingController(text: '${app.commission}');
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Page('Settings', 'Platform configuration', [
        Reveal(
          child: SoftCard(
            child: Form(
              key: _f,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Commission', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('Percentage charged on every delivered order.', style: TextStyle(color: C.muted)),
                const SizedBox(height: 14),
                ConstrainedBox(constraints: const BoxConstraints(maxWidth: 360), child: AppField(c, 'Commission (%)', Icons.percent_rounded, keyboard: TextInputType.number, validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null) return 'Enter a whole number';
                  if (n < 0 || n > 40) return 'Choose a value between 0 and 40';
                  return null;
                })),
                const SizedBox(height: 14),
                ConstrainedBox(constraints: const BoxConstraints(maxWidth: 220), child: GradBtn('Save', h: 48, onTap: () {
                  if (!_f.currentState!.validate()) return;
                  app.commission = int.parse(c.text.trim());
                  app.ping();
                  toast(context, 'Commission updated to ${app.commission}%');
                })),
              ]),
            ),
          ),
        ),
      ]);
}
