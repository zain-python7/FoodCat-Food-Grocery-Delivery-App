import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RiderNavigationPage extends StatelessWidget {
 const RiderNavigationPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Navigation', subtitle:'Follow the route to the customer.', items:['Pickup location', 'Current location', 'Customer drop-off', 'Estimated arrival: 12 minutes'],
  action:'Arrived at destination', icon:Icons.delivery_dining,
 );
}
