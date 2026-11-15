import 'package:flutter/material.dart';
import '../../widgets/dashboard_page.dart';
import '../../models/role.dart';
class AdminOverviewPage extends StatelessWidget {
 const AdminOverviewPage({super.key});
 @override Widget build(BuildContext c)=>const DashboardPage(title:'Admin overview',subtitle:'Monitor platform performance and activity.',role:AppRole.admin,stats:[('Total orders','1,284',Icons.receipt_long),('Restaurants','86',Icons.storefront),('Riders online','42',Icons.delivery_dining),('Revenue','Rs. 842k',Icons.payments_outlined)],actions:['Manage restaurants','Manage riders','All orders','Customers','Finance & analytics','Settings']);
}
