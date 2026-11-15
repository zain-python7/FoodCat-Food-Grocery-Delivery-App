import 'package:flutter/material.dart';
import '../../widgets/components.dart';
import '../../models/food_item.dart';
class SearchPage extends StatefulWidget {
 final String initialQuery;
 const SearchPage({super.key,this.initialQuery=''});
 @override State<SearchPage> createState()=>_SearchPageState();
}
class _SearchPageState extends State<SearchPage> {
 String query='';
 @override void initState(){super.initState();query=widget.initialQuery;}
 @override Widget build(BuildContext c){final found=demoFoods.where((f)=>f.name.toLowerCase().contains(query.toLowerCase())||f.category.toLowerCase().contains(query.toLowerCase())).toList();return Scaffold(appBar:AppBar(title:const Text('Search')),body:ListView(padding:const EdgeInsets.all(20),children:[TextField(autofocus:true,onChanged:(v)=>setState(()=>query=v),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search food or restaurants')),const SizedBox(height:18),const SectionHeading('Popular searches'),Wrap(spacing:8,children:['Burger','Pizza','Healthy','Desserts'].map((v)=>ActionChip(label:Text(v),onPressed:()=>setState(()=>query=v))).toList()),const SizedBox(height:18),...found.map((f)=>FoodCard(item:f))]));}
}
