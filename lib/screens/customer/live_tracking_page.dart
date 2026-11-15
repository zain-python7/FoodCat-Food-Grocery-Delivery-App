import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class LiveTrackingPage extends StatelessWidget {
 const LiveTrackingPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Live tracking', subtitle:'Your rider is on the way to your location.', items:['Restaurant confirmed your order', 'Food is being prepared', 'Rider is on the way', 'Delivery address'],
  action:'Contact rider', icon:Icons.restaurant_menu,
 );
}
