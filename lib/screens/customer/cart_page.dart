import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class CartPage extends StatelessWidget {
 const CartPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Your cart', subtitle:'Review your selected food before checkout.', items:['Classic Burger × 1 • Rs. 890', 'Italian Pizza × 1 • Rs. 1,250', 'Delivery fee • Rs. 120', 'Promo code'],
  action:'Proceed to checkout', icon:Icons.restaurant_menu,
 );
}
