import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class ProfilePage extends StatelessWidget {
 const ProfilePage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'My profile', subtitle:'Manage your personal information and preferences.', items:['Personal information', 'Saved addresses', 'Payment methods', 'Favorites', 'Settings'],
  action:'Edit profile', icon:Icons.restaurant_menu,
 );
}
