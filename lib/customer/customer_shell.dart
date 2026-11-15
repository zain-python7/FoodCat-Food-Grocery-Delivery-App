import 'package:flutter/material.dart';
import '../core/art.dart';
import '../core/data.dart';
import '../core/theme.dart';
import '../core/ui.dart';
import 'account.dart';
import 'browse.dart';
import 'checkout.dart';
import 'common.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});
  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int i = 0;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final pages = <Widget>[
            HomeTab(onExplore: () => setState(() => i = 1)),
            ExploreTab(),
            FavoritesTab(),
            OrdersTab(),
            ProfileTab(),
          ];
          return Scaffold(
            body: Column(children: [
              Expanded(child: TabFade(index: i, pages: pages)),
              AnimatedSize(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                child: app.cartCount == 0 ? const SizedBox(width: double.infinity) : _CartBar(),
              ),
              AppNav(
                index: i,
                onTap: (x) => setState(() => i = x),
                items: const [
                  NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
                  NavItem(Icons.search_rounded, Icons.search_rounded, 'Explore'),
                  NavItem(Icons.favorite_border_rounded, Icons.favorite_rounded, 'Saved'),
                  NavItem(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Orders'),
                  NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
                ],
              ),
            ]),
          );
        },
      );
}

class _CartBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Tap(
          onTap: () => go(context, const CartPage()),
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(gradient: C.hero, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: C.orange.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))]),
            child: Row(children: [
              Container(width: 34, height: 34, decoration: BoxDecoration(color: Colors.white.withOpacity(0.22), shape: BoxShape.circle), child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${app.cartCount} item${app.cartCount == 1 ? '' : 's'}  •  ${app.rest(app.cartRid ?? 'r1').name}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  Text(rs(app.sub), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                ]),
              ),
              const Text('View cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ]),
          ),
        ),
      );
}

class HomeTab extends StatelessWidget {
  final VoidCallback onExplore;
  const HomeTab({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final r = app.rests.where((x) => x.status == 'Approved').toList();
    return ListView(padding: const EdgeInsets.only(bottom: 16), children: [
      Padding(
        padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 14, 24, 0),
        child: Row(children: [
          Expanded(
            child: Tap(
              onTap: () => addressSheet(context),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Delivering to', style: TextStyle(color: C.muted, fontSize: 11.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(children: [
                  Flexible(child: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: Text(app.addresses.isEmpty ? 'Add address' : app.addresses[app.addrIdx].line, key: ValueKey(app.addrIdx), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)))),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: C.orange),
                ]),
              ]),
            ),
          ),
          IconCircle(Icons.notifications_none_rounded, size: 46, badge: unreadNotes(), onTap: () => go(context, const NotificationsPage())),
        ]),
      ),
      Reveal(
        i: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          child: Tap(
            onTap: () => go(context, const SearchPage()),
            scale: 0.98,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.line)),
              child: const Row(children: [Icon(Icons.search_rounded, color: C.muted), SizedBox(width: 10), Text('Search dishes, restaurants...', style: TextStyle(color: C.muted, fontWeight: FontWeight.w500))]),
            ),
          ),
        ),
      ),
      Reveal(
        i: 1,
        child: Container(
          height: 176,
          margin: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          padding: const EdgeInsets.fromLTRB(22, 22, 14, 20),
          decoration: BoxDecoration(gradient: C.hero, borderRadius: BorderRadius.circular(26), boxShadow: [BoxShadow(color: C.orange.withOpacity(0.32), blurRadius: 24, offset: const Offset(0, 12))]),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('THE WEEKEND CRAVING', style: TextStyle(color: Color(0xFFFFF2EC), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                const SizedBox(height: 8),
                const Text('A little treat,', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900, height: 1.1)),
                const Text('a lot of happiness.', style: TextStyle(color: Colors.white, fontSize: 19.5, fontWeight: FontWeight.w800, height: 1.25)),
                const SizedBox(height: 14),
                Tap(
                  onTap: () => go(context, const ListingPage()),
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const Text('Order now', style: TextStyle(color: C.orange, fontWeight: FontWeight.w800, fontSize: 12))),
                ),
              ]),
            ),
            const Floaty(child: SizedBox(width: 104, height: 126, child: FoodArt(Art.burger, radius: 20, bg: C.tint2, scale: 1.15))),
          ]),
        ),
      ),
      SectionTitle('What are you craving?', action: 'See all', onAction: onExplore),
      SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: kCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, i) => Reveal(
            i: i,
            dy: 14,
            child: Tap(
              onTap: () => go(context, ListingPage(category: kCategories[i])),
              child: Column(children: [
                SizedBox(width: 72, height: 70, child: FoodArt(kCatArt[kCategories[i]]!, radius: 20, scale: 1.1)),
                const SizedBox(height: 7),
                Text(kCategories[i], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
      ),
      SectionTitle('Popular around you', action: 'View all', onAction: () => go(context, const ListingPage())),
      for (var i = 0; i < r.length; i++) RestCard(r[i], i: i),
    ]);
  }
}

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});
  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  String cat = 'All';
  @override
  Widget build(BuildContext context) {
    final list = app.foods.where((f) => f.available && (cat == 'All' || f.cat == cat || (cat == 'Desi' && f.cat == 'Desi')) && app.rest(f.rid).status == 'Approved').toList();
    return Column(children: [
      const Head('Explore food', sub: 'Find something delicious', back: false),
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
        child: Tap(
          onTap: () => go(context, const SearchPage()),
          scale: 0.98,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.line)),
            child: const Row(children: [Icon(Icons.search_rounded, color: C.muted), SizedBox(width: 10), Text('Search food or restaurant', style: TextStyle(color: C.muted, fontWeight: FontWeight.w500))]),
          ),
        ),
      ),
      Chips(const ['All', ...kCategories], selected: cat, onTap: (v) => setState(() => cat = v)),
      const SizedBox(height: 14),
      Expanded(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: list.isEmpty
              ? const Empty(Icons.no_food_rounded, 'Nothing here yet', 'Try another category.')
              : GridView.builder(
                  key: ValueKey(cat),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.8),
                  itemCount: list.length,
                  itemBuilder: (_, i) => FoodCard(list[i], i: i),
                ),
        ),
      ),
    ]);
  }
}
