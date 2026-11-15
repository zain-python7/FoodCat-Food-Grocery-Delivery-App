import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RiderProfilePage extends StatelessWidget {
 const RiderProfilePage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Rider profile', subtitle:'Manage your rider account and contact details.', items:['Personal details', 'Phone number', 'Emergency contact', 'Profile photo'],
  action:'Edit profile', icon:Icons.delivery_dining,
 );
}
