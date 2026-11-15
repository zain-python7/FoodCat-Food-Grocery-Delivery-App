import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RestaurantListingPage extends StatelessWidget {
 const RestaurantListingPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Restaurants', subtitle:'Discover restaurants around your delivery location.', items:['Green Garden • Healthy food • 4.8 ★', 'Burger House • Burgers • 4.7 ★', 'Pizza Corner • Italian • 4.6 ★'],
  action:'View restaurants', icon:Icons.restaurant_menu,
 );
}
