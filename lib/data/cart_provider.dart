import 'package:flutter/foundation.dart';
import 'app_database.dart';
class CartProvider extends ChangeNotifier {
  List<Map<String,Object?>> items=[];
  int get count=>items.fold(0,(s,e)=>s+(e['quantity'] as int));
  double get total=>items.fold(0.0,(s,e)=>s+(e['price'] as num).toDouble()*(e['quantity'] as int));
  Future<void> refresh() async {items=await AppDatabase.instance.cart();notifyListeners();}
  Future<void> add(Map<String,Object?> p) async {await AppDatabase.instance.addToCart(p);await refresh();}
  Future<void> change(int id,int delta) async {await AppDatabase.instance.changeQuantity(id,delta);await refresh();}
  Future<void> clear() async {await AppDatabase.instance.clearCart();await refresh();}
}
