import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class AddEditFoodPage extends StatelessWidget {
 const AddEditFoodPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Add or edit food', subtitle:'Create a menu item with its price and description.', items:['Food name', 'Description', 'Price', 'Category', 'Availability'],
  action:'Save food item', icon:Icons.storefront_outlined,
 );
}
