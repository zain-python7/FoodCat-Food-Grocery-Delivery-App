import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class FavoritesPage extends StatelessWidget {
 const FavoritesPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Favorites', subtitle:'Your saved meals and restaurants.', items:['Classic Burger', 'Green Garden', 'Chocolate Cake'],
  action:'Browse favorites', icon:Icons.restaurant_menu,
 );
}
