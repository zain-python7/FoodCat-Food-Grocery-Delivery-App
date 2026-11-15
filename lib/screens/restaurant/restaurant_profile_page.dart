import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RestaurantProfilePage extends StatelessWidget {
 const RestaurantProfilePage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Restaurant profile', subtitle:'Update public information for your restaurant.', items:['Restaurant name', 'Address and location', 'Opening hours', 'Contact details'],
  action:'Save profile', icon:Icons.storefront_outlined,
 );
}
