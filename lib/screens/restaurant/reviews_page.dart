import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RestaurantReviewsPage extends StatelessWidget {
 const RestaurantReviewsPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Reviews', subtitle:'Read customer feedback and ratings.', items:['4.8 average rating', 'Fresh and delicious', 'Fast delivery', 'Great service'],
  action:'Reply to review', icon:Icons.storefront_outlined,
 );
}
