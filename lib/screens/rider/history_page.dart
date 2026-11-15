import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RiderHistoryPage extends StatelessWidget {
 const RiderHistoryPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Delivery history', subtitle:'Your recently completed delivery jobs.', items:['FD-1042 • Delivered • Rs. 350', 'FD-1038 • Delivered • Rs. 420', 'FD-1029 • Delivered • Rs. 300'],
  action:'View history', icon:Icons.delivery_dining,
 );
}
