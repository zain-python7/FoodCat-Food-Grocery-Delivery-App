import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RiderRegistrationPage extends StatelessWidget {
 const RiderRegistrationPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Rider registration', subtitle:'Register to deliver orders with Foodie.', items:['Full name', 'Phone number', 'Email address', 'Home address'],
  action:'Submit registration', icon:Icons.delivery_dining,
 );
}
