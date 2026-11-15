import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class ExplorePage extends StatelessWidget {
 const ExplorePage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Explore', subtitle:'Browse restaurants, cuisines and popular meals.', items:['Popular restaurants', 'Nearby restaurants', 'Top rated places', 'Recently viewed'],
  action:'Browse now', icon:Icons.restaurant_menu,
 );
}
