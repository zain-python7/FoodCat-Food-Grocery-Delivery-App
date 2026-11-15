import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class DeliveryRequestPage extends StatelessWidget {
 const DeliveryRequestPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'New delivery request', subtitle:'A new delivery is available near your location.', items:['Pickup: Green Garden', 'Drop-off: 24 Main Street', 'Estimated distance: 3.2 km', 'Estimated earning: Rs. 350'],
  action:'Accept delivery', icon:Icons.delivery_dining,
 );
}
