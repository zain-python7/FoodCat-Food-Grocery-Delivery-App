import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class DeliveryConfirmationPage extends StatelessWidget {
 const DeliveryConfirmationPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Delivery confirmation', subtitle:'Confirm the order has reached the customer.', items:['Order FD-1042', 'Enter customer delivery PIN', 'Confirm handover'],
  action:'Complete delivery', icon:Icons.delivery_dining,
 );
}
