import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RestaurantMenuPage extends StatelessWidget {
 const RestaurantMenuPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Menu management', subtitle:'Manage the meals visible to customers.', items:['Classic Burger • Rs. 890 • Available', 'Italian Pizza • Rs. 1,250 • Available', 'Chocolate Cake • Rs. 540 • Paused'],
  action:'Add menu item', icon:Icons.storefront_outlined,
 );
}
