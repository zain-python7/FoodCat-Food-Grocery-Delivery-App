import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RestaurantAnalyticsPage extends StatelessWidget {
 const RestaurantAnalyticsPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Analytics', subtitle:'Understand sales, orders and popular dishes.', items:['Weekly sales', 'Order trends', 'Top selling dishes', 'Customer ratings'],
  action:'View report', icon:Icons.storefront_outlined,
 );
}
