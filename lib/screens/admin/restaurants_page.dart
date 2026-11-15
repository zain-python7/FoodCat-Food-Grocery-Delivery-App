import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class AdminRestaurantsPage extends StatelessWidget {
 const AdminRestaurantsPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Restaurant management', subtitle:'Review and manage registered restaurants.', items:['Green Garden • Approved', 'Burger House • Approved', 'Pizza Corner • Pending review'],
  action:'Manage restaurants', icon:Icons.admin_panel_settings_outlined,
 );
}
