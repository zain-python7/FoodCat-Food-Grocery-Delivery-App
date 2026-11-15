import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class AdminOrdersPage extends StatelessWidget {
 const AdminOrdersPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'All orders', subtitle:'Monitor orders across the platform.', items:['FD-1042 • Preparing', 'FD-1041 • On the way', 'FD-1038 • Completed'],
  action:'View orders', icon:Icons.admin_panel_settings_outlined,
 );
}
