import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class AdminCustomersSettingsPage extends StatelessWidget {
 const AdminCustomersSettingsPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Customers & settings', subtitle:'Manage customer accounts and platform settings.', items:['Customer directory', 'Reported accounts', 'Platform preferences', 'Admin permissions'],
  action:'Manage customers', icon:Icons.admin_panel_settings_outlined,
 );
}
