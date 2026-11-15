import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class AdminFinanceAnalyticsPage extends StatelessWidget {
 const AdminFinanceAnalyticsPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Finance & analytics', subtitle:'Review revenue, commissions and platform metrics.', items:['Gross order value • Rs. 842,000', 'Platform commission • Rs. 84,200', 'Refunds • Rs. 4,500', 'Weekly growth • 12%'],
  action:'Export report', icon:Icons.admin_panel_settings_outlined,
 );
}
