import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/food_item.dart';

class SectionHeading extends StatelessWidget {
 final String title; final String? action; final VoidCallback? onAction;
 const SectionHeading(this.title,{super.key,this.action,this.onAction});
 @override Widget build(BuildContext c)=>Row(children:[Expanded(child:Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900,color:FoodieColors.dark))),if(action!=null)TextButton(onPressed:onAction,child:Text(action!,style:const TextStyle(color:FoodieColors.green)))]);
}
class FoodCard extends StatelessWidget {
 final FoodItem item; final VoidCallback? onAdd; final VoidCallback? onTap;
 const FoodCard({super.key,required this.item,this.onAdd,this.onTap});
 @override Widget build(BuildContext c)=>Card(child:InkWell(borderRadius:BorderRadius.circular(18),onTap:onTap,child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[
  Container(width:82,height:82,alignment:Alignment.center,decoration:BoxDecoration(color:const Color(0xFFFFF1E5),borderRadius:BorderRadius.circular(15)),child:Text(item.emoji,style:const TextStyle(fontSize:42))),
  const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(item.name,style:const TextStyle(fontWeight:FontWeight.w900,color:FoodieColors.dark)),const SizedBox(height:5),Text(item.description,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:11,color:FoodieColors.muted)),const SizedBox(height:8),Text(item.price,style:const TextStyle(color:FoodieColors.green,fontWeight:FontWeight.w900))])),
  IconButton.filled(onPressed:onAdd,style:IconButton.styleFrom(backgroundColor:FoodieColors.green,foregroundColor:Colors.white),icon:const Icon(Icons.add))
 ]))));
}
class StatusPill extends StatelessWidget {
 final String label; final Color color;
 const StatusPill(this.label,{super.key,this.color=FoodieColors.green});
 @override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:color.withOpacity(.1),borderRadius:BorderRadius.circular(30)),child:Text(label,style:TextStyle(color:color,fontSize:10,fontWeight:FontWeight.w800)));
}
class MetricCard extends StatelessWidget {
 final String title,value; final IconData icon; final String? caption;
 const MetricCard({super.key,required this.title,required this.value,required this.icon,this.caption});
 @override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(17),border:Border.all(color:FoodieColors.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Icon(icon,color:FoodieColors.green),Text(value,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:FoodieColors.dark)),Text(title,style:const TextStyle(fontSize:11,color:FoodieColors.muted)),if(caption!=null)Text(caption!,style:const TextStyle(fontSize:10,color:FoodieColors.green))]));
}
class FeaturePage extends StatelessWidget {
 final String title,subtitle,action; final List<String> items; final IconData icon;
 const FeaturePage({super.key,required this.title,required this.subtitle,required this.items,this.action='Continue',this.icon=Icons.dashboard_outlined});
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:Text(title)),body:ListView(padding:const EdgeInsets.all(20),children:[
  Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(gradient:const LinearGradient(colors:[FoodieColors.dark,FoodieColors.green]),borderRadius:BorderRadius.circular(22)),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:21)),const SizedBox(height:7),Text(subtitle,style:const TextStyle(color:Colors.white70,fontSize:12))])),Icon(icon,size:48,color:Colors.white)])),
  const SizedBox(height:22),const SectionHeading('Details'),const SizedBox(height:8),
  ...items.map((v)=>Card(child:ListTile(leading:const CircleAvatar(backgroundColor:FoodieColors.light,child:Icon(Icons.check,color:FoodieColors.green,size:18)),title:Text(v,style:const TextStyle(fontWeight:FontWeight.w600)),trailing:const Icon(Icons.chevron_right),onTap:()=>ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text(v)))))),
  const SizedBox(height:14),SizedBox(height:50,child:FilledButton(onPressed:()=>ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('$action selected'))),child:Text(action)))
 ]));
}
