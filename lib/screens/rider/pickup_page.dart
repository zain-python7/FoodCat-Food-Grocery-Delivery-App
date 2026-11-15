import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RiderPickupPage extends StatelessWidget {
 const RiderPickupPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Pickup checklist', subtitle:'Confirm the order before leaving the restaurant.', items:['Check order number FD-1042', 'Confirm all food packages', 'Collect order from restaurant'],
  action:'Confirm pickup', icon:Icons.delivery_dining,
 );
}
