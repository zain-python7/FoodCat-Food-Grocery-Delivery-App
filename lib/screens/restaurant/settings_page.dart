import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RestaurantSettingsPage extends StatelessWidget {
 const RestaurantSettingsPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Settings', subtitle:'Manage restaurant preferences and account settings.', items:['Notifications', 'Operating hours', 'Delivery settings', 'Account security'],
  action:'Save settings', icon:Icons.storefront_outlined,
 );
}
