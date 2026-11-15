import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RestaurantOrderDetailsPage extends StatelessWidget {
 const RestaurantOrderDetailsPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Order details', subtitle:'Review items and update order progress.', items:['Customer: Foodie User', 'Classic Burger × 1', 'Italian Pizza × 1', 'Delivery note and address'],
  action:'Accept order', icon:Icons.storefront_outlined,
 );
}
