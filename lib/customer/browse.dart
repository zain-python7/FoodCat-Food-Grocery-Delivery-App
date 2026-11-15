import 'package:flutter/material.dart';
import '../core/data.dart';
import '../core/theme.dart';
import '../core/ui.dart';
import 'common.dart';
import 'restaurant.dart';
import '../core/art.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final c = TextEditingController();
  String q = '';
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  void _submit(String v) {
    final t = v.trim();
    if (t.isEmpty) return;
    app.recent.remove(t);
    app.recent.insert(0, t);
    if (app.recent.length > 6) app.recent.removeLast();
  }

  void _use(String v) {
    c.text = v;
    c.selection = TextSelection.collapsed(offset: v.length);
    setState(() => q = v);
  }

  @override
  Widget build(BuildContext context) {
    final ql = q.trim().toLowerCase();
    final foods = ql.isEmpty ? <Food>[] : app.foods.where((f) => f.available && (f.name.toLowerCase().contains(ql) || f.cat.toLowerCase().contains(ql) || f.desc.toLowerCase().contains(ql))).toList();
    final rests = ql.isEmpty ? <Rest>[] : app.rests.where((r) => r.status == 'Approved' && r.name.toLowerCase().contains(ql)).toList();
    return Scaffold(
      body: Column(children: [
        const Head('Search', sub: 'Find your next favorite'),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: TextField(
            controller: c,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (v) => setState(() => q = v),
            onSubmitted: _submit,
            style: const TextStyle(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Search food or restaurant',
              hintStyle: const TextStyle(color: C.muted, fontWeight: FontWeight.w500),
              prefixIcon: const Icon(Icons.search_rounded, color: C.muted),
              suffixIcon: q.isEmpty ? null : IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(() { c.clear(); q = ''; })),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.line)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.line)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.orange, width: 1.6)),
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: ql.isEmpty
                ? ListView(key: const ValueKey('idle'), padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), children: [
                    const Label('TRENDING SEARCHES'),
                    Wrap(spacing: 10, runSpacing: 10, children: [
                      for (final t in const ['Chicken burger', 'Pepperoni pizza', 'Biryani', 'Iced latte', 'Donuts'])
                        Tap(onTap: () => _use(t), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: C.line)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.trending_up_rounded, size: 16, color: C.orange), const SizedBox(width: 6), Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))]))),
                    ]),
                    if (app.recent.isNotEmpty) ...[
                      const Label('RECENT SEARCHES'),
                      for (final t in app.recent)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history_rounded, color: C.muted),
                          title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.north_west_rounded, size: 16, color: C.faint),
                          onTap: () => _use(t),
                        ),
                    ],
                  ])
                : (foods.isEmpty && rests.isEmpty)
                    ? const Empty(Icons.search_off_rounded, 'No matches found', 'Try a different dish or restaurant name.')
                    : ListView(key: const ValueKey('res'), padding: const EdgeInsets.fromLTRB(24, 4, 24, 24), children: [
                        if (rests.isNotEmpty) const Label('RESTAURANTS'),
                        for (var i = 0; i < rests.length; i++)
                          Reveal(
                            i: i,
                            child: SoftCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              onTap: () { _submit(q); go(context, RestaurantPage(rests[i])); },
                              child: Row(children: [
                                SizedBox(width: 62, height: 62, child: FoodArt(rests[i].art, radius: 16)),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(rests[i].name, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text('${rests[i].rating} ★  •  ${rests[i].time}', style: const TextStyle(color: C.muted, fontSize: 12.5))])),
                                const Icon(Icons.chevron_right_rounded, color: C.faint),
                              ]),
                            ),
                          ),
                        if (foods.isNotEmpty) const Label('DISHES'),
                        for (var i = 0; i < foods.length; i++)
                          Reveal(
                            i: i,
                            child: SoftCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              onTap: () { _submit(q); go(context, FoodPage(foods[i])); },
                              child: Row(children: [
                                Hero(tag: 'food_${foods[i].id}', child: SizedBox(width: 62, height: 62, child: FoodArt(foods[i].art, radius: 16))),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(foods[i].name, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(app.rest(foods[i].rid).name, style: const TextStyle(color: C.muted, fontSize: 12.5))])),
                                Text(rs(foods[i].price), style: const TextStyle(color: C.orange, fontWeight: FontWeight.w900)),
                              ]),
                            ),
                          ),
                      ]),
          ),
        ),
      ]),
    );
  }
}

class ListingPage extends StatefulWidget {
  final String? category;
  const ListingPage({super.key, this.category});
  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  bool byRating = false, fast = false, offers = false;
  @override
  Widget build(BuildContext context) {
    var list = app.rests.where((r) => r.status == 'Approved').toList();
    if (widget.category != null) {
      final ids = app.foods.where((f) => f.cat == widget.category).map((f) => f.rid).toSet();
      list = list.where((r) => ids.contains(r.id)).toList();
    }
    if (offers) list = list.where((r) => r.offer).toList();
    if (fast) list = list.where((r) => int.parse(r.time.substring(0, 2)) <= 25).toList();
    if (byRating) {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    Widget chip(String t, IconData i, bool on, VoidCallback f) => Tap(
          onTap: f,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: on ? C.orange : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: on ? C.orange : C.line)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, size: 16, color: on ? Colors.white : C.orange), const SizedBox(width: 6), Text(t, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: on ? Colors.white : C.ink))]),
          ),
        );
    return Scaffold(
      body: Column(children: [
        Head(widget.category ?? 'Restaurants', sub: widget.category == null ? 'Top picks near your location' : 'Restaurants serving ${widget.category!.toLowerCase()}'),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
          child: Row(children: [
            chip('Rating', Icons.star_rounded, byRating, () => setState(() => byRating = !byRating)),
            const SizedBox(width: 8),
            chip('Fast delivery', Icons.bolt_rounded, fast, () => setState(() => fast = !fast)),
            const SizedBox(width: 8),
            chip('Offers', Icons.local_offer_rounded, offers, () => setState(() => offers = !offers)),
          ]),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: list.isEmpty
                ? const Empty(Icons.storefront_rounded, 'No restaurants found', 'Try turning off a filter.')
                : ListView(key: ValueKey('$byRating$fast$offers'), padding: const EdgeInsets.only(bottom: 20), children: [for (var i = 0; i < list.length; i++) RestCard(list[i], i: i, top: i < 3 && widget.category == null)]),
          ),
        ),
      ]),
    );
  }
}
