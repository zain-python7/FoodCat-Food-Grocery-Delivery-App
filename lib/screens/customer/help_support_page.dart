import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class HelpSupportPage extends StatelessWidget {
 const HelpSupportPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Help & support', subtitle:'We are here to help with your Foodie experience.', items:['Frequently asked questions', 'Contact support', 'Report an issue', 'Refund and cancellation policy'],
  action:'Contact support', icon:Icons.restaurant_menu,
 );
}
