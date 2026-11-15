import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class AdminLoginPage extends StatelessWidget {
 const AdminLoginPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Admin login', subtitle:'Sign in to manage the Foodie platform.', items:['Email address', 'Password', 'Two-factor verification'],
  action:'Sign in', icon:Icons.admin_panel_settings_outlined,
 );
}
