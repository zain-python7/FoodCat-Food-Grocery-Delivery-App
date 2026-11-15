import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class RiderEarningsPage extends StatelessWidget {
 const RiderEarningsPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Earnings', subtitle:'Review your daily and weekly delivery earnings.', items:['Today • Rs. 9,600', 'This week • Rs. 42,500', 'Completed deliveries • 54', 'Bonuses • Rs. 1,200'],
  action:'View earnings', icon:Icons.delivery_dining,
 );
}
