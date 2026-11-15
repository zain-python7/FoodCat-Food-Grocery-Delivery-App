import 'package:flutter/material.dart';
import '../../widgets/dashboard_page.dart';
import '../../models/role.dart';
class RiderDashboardPage extends StatelessWidget {
 const RiderDashboardPage({super.key});
 @override Widget build(BuildContext c)=>const DashboardPage(title:'Rider dashboard',subtitle:'Your delivery work at a glance.',role:AppRole.rider,stats:[('Today earnings','Rs. 9.6k',Icons.wallet_outlined),('Deliveries','12',Icons.delivery_dining),('Rating','4.9',Icons.star_outline),('Availability','Online',Icons.toggle_on)],actions:['Incoming requests','Active delivery','Earnings','Delivery history','Vehicle & documents','Profile']);
}
