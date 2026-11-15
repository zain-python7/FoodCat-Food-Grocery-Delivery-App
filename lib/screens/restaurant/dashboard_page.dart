import 'package:flutter/material.dart';
import '../../widgets/dashboard_page.dart';
import '../../models/role.dart';
class RestaurantDashboardPage extends StatelessWidget {
 const RestaurantDashboardPage({super.key});
 @override Widget build(BuildContext c)=>const DashboardPage(title:'Restaurant dashboard',subtitle:'Manage your restaurant at a glance.',role:AppRole.restaurant,stats:[('Today revenue','Rs. 84k',Icons.payments_outlined),('New orders','18',Icons.receipt_long),('Menu items','42',Icons.restaurant_menu),('Rating','4.8',Icons.star_outline)],actions:['Manage orders','Manage menu','Restaurant profile','Analytics','Reviews','Settings']);
}
