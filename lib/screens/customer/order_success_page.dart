import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class OrderSuccessPage extends StatelessWidget {
 const OrderSuccessPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Order placed', subtitle:'Your order has been received by the restaurant.', items:['Order number FD-1042', 'Estimated delivery 30–40 minutes', 'Restaurant confirmed'],
  action:'Track order', icon:Icons.restaurant_menu,
 );
}
