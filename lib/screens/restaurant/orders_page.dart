import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RestaurantOrdersPage extends StatelessWidget {
 const RestaurantOrdersPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Orders', subtitle:'Review incoming, preparing and completed orders.', items:['FD-1042 • New • Rs. 2,260', 'FD-1041 • Preparing • Rs. 1,450', 'FD-1038 • Completed • Rs. 890'],
  action:'Manage orders', icon:Icons.storefront_outlined,
 );
}
