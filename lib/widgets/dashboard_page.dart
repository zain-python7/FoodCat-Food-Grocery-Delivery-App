
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/role.dart';
import 'components.dart';
import 'role_drawer.dart';

class DashboardPage extends StatelessWidget {
 final String title;
 final String subtitle;
 final AppRole role;
 final List<(String, String, IconData)> stats;
 final List<String> actions;

 const DashboardPage({
  super.key,
  required this.title,
  required this.subtitle,
  required this.role,
  required this.stats,
  required this.actions,
 });

 @override
 Widget build(BuildContext context) {
  return Scaffold(
   appBar: AppBar(
    title: Text(title),
    leading: Builder(
     builder: (context) => IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
       Scaffold.of(context).openDrawer();
      },
     ),
    ),
    actions: [
     IconButton(
      onPressed: () {},
      icon: const Icon(Icons.notifications_none),
     ),
    ],
   ),

   drawer: RoleDrawer(role: role),

   body: ListView(
    padding: const EdgeInsets.all(20),
    children: [
     Text(
      subtitle,
      style: const TextStyle(
       color: FoodieColors.muted,
      ),
     ),

     const SizedBox(height: 18),

     GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: stats.map((s) {
       return MetricCard(
        title: s.$1,
        value: s.$2,
        icon: s.$3,
       );
      }).toList(),
     ),

     const SizedBox(height: 24),

     const SectionHeading('Quick actions'),

     const SizedBox(height: 10),

     ...actions.map((a) {
      return Card(
       child: ListTile(
        leading: const CircleAvatar(
         backgroundColor: FoodieColors.light,
         child: Icon(
          Icons.arrow_forward,
          color: FoodieColors.green,
          size: 18,
         ),
        ),
        title: Text(
         a,
         style: const TextStyle(
          fontWeight: FontWeight.w700,
         ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
           content: Text('$a page'),
          ),
         );
        },
       ),
      );
     }),
    ],
   ),
  );
 }
}
