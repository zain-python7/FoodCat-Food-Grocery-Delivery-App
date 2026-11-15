import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/role.dart';
class WelcomePage extends StatelessWidget {
 const WelcomePage({super.key});
 @override Widget build(BuildContext c)=>Scaffold(body:Container(width:double.infinity,padding:const EdgeInsets.all(28),decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[FoodieColors.dark,FoodieColors.green])),child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[
 const Icon(Icons.restaurant,size:64,color:Colors.white),const SizedBox(height:24),const Text('Foodie',style:TextStyle(fontSize:38,fontWeight:FontWeight.w900,color:Colors.white)),const SizedBox(height:8),const Text('Good food, delivered to your door.',style:TextStyle(color:Colors.white70,fontSize:16)),const SizedBox(height:36),const Text('Choose your experience',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),const SizedBox(height:12),
 ...AppRole.values.map((r)=>Padding(padding:const EdgeInsets.only(bottom:10),child: SizedBox(width:double.infinity,child:FilledButton(style:FilledButton.styleFrom(backgroundColor:Colors.white,foregroundColor:FoodieColors.green),onPressed:()=>Navigator.pushReplacementNamed(c,r.home),child:Text(r.label)))))
 ])));
}
