import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class FoodDetailsPage extends StatelessWidget {
 const FoodDetailsPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Food details', subtitle:'Classic Burger • Juicy beef with cheddar and lettuce.', items:['Freshly prepared', 'Customise ingredients', 'Special instructions'],
  action:'Add to cart', icon:Icons.restaurant_menu,
 );
}
