import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RiderJobDetailsPage extends StatelessWidget {
 const RiderJobDetailsPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Delivery details', subtitle:'Review pickup and drop-off information.', items:['Restaurant: Green Garden', 'Customer: Foodie User', 'Pickup code: 4821', 'Drop-off instructions'],
  action:'Start delivery', icon:Icons.delivery_dining,
 );
}
