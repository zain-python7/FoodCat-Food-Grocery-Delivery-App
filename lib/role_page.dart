import 'package:flutter/material.dart';
import 'auth/auth_gate_page.dart';
import 'core/art.dart';
import 'core/data.dart';
import 'core/theme.dart';
import 'core/ui.dart';

class RolePage extends StatelessWidget {
  const RolePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card(int i, IconData icon, Color color, String title, String sub, VoidCallback onTap) => Reveal(
          i: i + 2,
          child: SoftCard(
            margin: const EdgeInsets.only(bottom: 14),
            onTap: onTap,
            child: Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: color, size: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(sub, style: const TextStyle(color: C.muted, fontSize: 12.5, height: 1.3)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: C.faint),
            ]),
          ),
        );

    return Scaffold(
      body: ListView(padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 18, 24, 32), children: [
        Reveal(
          child: Container(
            height: 190,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: C.hero, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: C.orange.withOpacity(0.3), blurRadius: 28, offset: const Offset(0, 14))]),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('foodie', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  const SizedBox(height: 6),
                  Text('Good food. Good mood.\nDelivered.', style: TextStyle(color: Colors.white.withOpacity(0.92), fontSize: 15, height: 1.3, fontWeight: FontWeight.w600)),
                ]),
              ),
              const Floaty(child: SizedBox(width: 104, height: 104, child: FoodArt(Art.burger, radius: 28, bg: Color(0x33FFFFFF)))),
            ]),
          ),
        ),
        const Reveal(i: 1, child: Padding(padding: EdgeInsets.fromLTRB(4, 28, 0, 14), child: Text('How would you like to continue?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)))),
        card(0, Icons.restaurant_rounded, C.orange, 'I\'m hungry', 'Order from the best restaurants around you', () => go(context, const AuthGatePage(accountType: 'customer'))),
        card(1, Icons.storefront_rounded, const Color(0xFF7A5AF8), 'Restaurant owner', 'Manage orders, menu and your business', () => go(context, const AuthGatePage(accountType: 'restaurant'))),
        card(2, Icons.two_wheeler_rounded, C.green, 'Delivery rider', 'Deliver smiles and earn on your schedule', () => go(context, const AuthGatePage(accountType: 'rider'))),
        card(3, Icons.space_dashboard_rounded, C.navy, 'Admin console', 'Control center for the whole platform', () {
          app.fullWidth = true;
          app.ping();
          go(context, const AuthGatePage(accountType: 'admin'));
        }),
      ]),
    );
  }
}
