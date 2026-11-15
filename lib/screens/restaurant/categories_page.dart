import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RestaurantCategoriesPage extends StatelessWidget {
 const RestaurantCategoriesPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Categories', subtitle:'Organise your menu into clear categories.', items:['Burgers', 'Pizza', 'Healthy', 'Desserts', 'Drinks'],
  action:'Add category', icon:Icons.storefront_outlined,
 );
}
