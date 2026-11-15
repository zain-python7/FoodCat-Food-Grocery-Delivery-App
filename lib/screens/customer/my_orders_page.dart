import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class MyOrdersPage extends StatelessWidget {
 const MyOrdersPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'My orders', subtitle:'View current and previous orders.', items:['FD-1042 • Preparing • Rs. 2,260', 'FD-1038 • Delivered • Rs. 1,450', 'FD-1029 • Delivered • Rs. 890'],
  action:'View order', icon:Icons.restaurant_menu,
 );
}
