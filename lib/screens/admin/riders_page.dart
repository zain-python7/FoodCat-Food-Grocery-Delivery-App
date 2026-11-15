import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class AdminRidersPage extends StatelessWidget {
 const AdminRidersPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Rider management', subtitle:'Review rider accounts and availability.', items:['42 riders online', '8 applications pending', '3 accounts under review'],
  action:'Manage riders', icon:Icons.admin_panel_settings_outlined,
 );
}
