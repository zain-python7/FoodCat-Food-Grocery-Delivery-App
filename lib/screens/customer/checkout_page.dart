import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class CheckoutPage extends StatelessWidget {
 const CheckoutPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Checkout', subtitle:'Confirm delivery details and payment method.', items:['Delivery address • Home, Lahore', 'Cash on delivery', 'Card payment', 'Order summary • Rs. 2,260'],
  action:'Place order', icon:Icons.restaurant_menu,
 );
}
