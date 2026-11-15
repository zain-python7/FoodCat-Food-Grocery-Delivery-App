import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RestaurantDetailsPage extends StatelessWidget {
 const RestaurantDetailsPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Restaurant details', subtitle:'Green Garden • Fresh and healthy meals.', items:['Rating 4.8 • 1.2k reviews', 'Delivery 20–30 minutes', 'Minimum order Rs. 500', 'Opening hours 10 AM – 11 PM'],
  action:'View menu', icon:Icons.restaurant_menu,
 );
}
