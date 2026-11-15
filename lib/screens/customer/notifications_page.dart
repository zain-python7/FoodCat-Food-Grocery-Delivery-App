import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class NotificationsPage extends StatelessWidget {
 const NotificationsPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Notifications', subtitle:'Updates about orders and your account.', items:['Your order is confirmed', 'A rider has been assigned', 'Special offer available'],
  action:'View updates', icon:Icons.restaurant_menu,
 );
}
