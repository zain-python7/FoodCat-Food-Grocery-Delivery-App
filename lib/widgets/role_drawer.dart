flutterfire --versionimport 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/role.dart';
class RoleDrawer extends StatelessWidget {
 final AppRole role; const RoleDrawer({super.key,required this.role});
 @override Widget build(BuildContext c)=>Drawer(child:SafeArea(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Container(width:double.infinity,padding:const EdgeInsets.all(22),color:FoodieColors.green,child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[CircleAvatar(backgroundColor:Colors.white,child:Icon(Icons.restaurant,color:FoodieColors.green)),SizedBox(height:12),Text('Foodie',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900)),Text('Good food, delivered.',style:TextStyle(color:Colors.white70))])),
  const Padding(padding:EdgeInsets.fromLTRB(20,20,20,8),child:Text('SWITCH EXPERIENCE',style:TextStyle(color:FoodieColors.muted,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1))),
  ...AppRole.values.map((r)=>ListTile(leading:Icon(_icon(r),color:r==role?FoodieColors.green:FoodieColors.muted),title:Text(r.label),trailing:r==role?const Icon(Icons.check_circle,color:FoodieColors.green):null,onTap:()=>Navigator.pushNamedAndRemoveUntil(c,r.home,(route)=>route.isFirst))),
  const Divider(),const ListTile(leading:Icon(Icons.help_outline),title:Text('Help & support')),const ListTile(leading:Icon(Icons.settings_outlined),title:Text('Settings'))
 ])));
 IconData _icon(AppRole r)=>switch(r){AppRole.customer=>Icons.person_outline,AppRole.restaurant=>Icons.storefront_outlined,AppRole.rider=>Icons.delivery_dining,AppRole.admin=>Icons.admin_panel_settings_outlined};
}
