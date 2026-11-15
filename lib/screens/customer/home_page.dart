import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/role.dart';
import '../../models/food_item.dart';
import '../../widgets/components.dart';
import '../../widgets/role_drawer.dart';
import 'search_page.dart'; import 'cart_page.dart'; import 'explore_page.dart'; import 'profile_page.dart';
class CustomerHomePage extends StatefulWidget { const CustomerHomePage({super.key}); @override State<CustomerHomePage> createState()=>_CustomerHomePageState(); }
class _CustomerHomePageState extends State<CustomerHomePage>{
 String category='All'; final categories=['All','Burgers','Pizza','Healthy','Desserts','Chicken']; final cart=<FoodItem>[];
 @override Widget build(BuildContext c){final foods=demoFoods.where((f)=>category=='All'||f.category==category).toList();return Scaffold(
 appBar:AppBar(leading:Builder(builder:(x)=>IconButton(icon:const Icon(Icons.menu_rounded),onPressed:()=>Scaffold.of(x).openDrawer())),title:const Text('foodie'),actions:[IconButton(onPressed:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>const SearchPage())),icon:const Icon(Icons.search)),IconButton(onPressed:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>const CartPage())),icon:Badge(label:Text('${cart.length}'),child:const Icon(Icons.shopping_bag_outlined)))]),
 drawer:const RoleDrawer(role:AppRole.customer),
 body:ListView(padding:const EdgeInsets.fromLTRB(20,8,20,28),children:[
  Row(children:[const Icon(Icons.location_on_outlined,color:FoodieColors.green),const SizedBox(width:6),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('DELIVER TO',style:TextStyle(fontSize:10,color:FoodieColors.muted,fontWeight:FontWeight.bold)),Text('Home • 24 Main Street',style:TextStyle(fontWeight:FontWeight.w800,color:FoodieColors.dark))])),TextButton(onPressed:(){},child:const Text('Change'))]),
  const SizedBox(height:18),
  Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(gradient:const LinearGradient(colors:[FoodieColors.dark,FoodieColors.green]),borderRadius:BorderRadius.circular(22)),child:Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('WEEKEND SPECIAL',style:TextStyle(color:Colors.white70,fontSize:10,fontWeight:FontWeight.bold)),SizedBox(height:10),Text('Delicious food at your doorstep',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900)),SizedBox(height:8),Text('Enjoy your favourites today.',style:TextStyle(color:Colors.white70,fontSize:12))])),const Text('🍔',style:TextStyle(fontSize:65))])),
  const SizedBox(height:22),TextField(decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search food or restaurants',suffixIcon:Icon(Icons.tune)),onSubmitted:(v)=>Navigator.push(c,MaterialPageRoute(builder:(_)=>SearchPage(initialQuery:v)))),
  const SizedBox(height:22),const SectionHeading('Categories'),const SizedBox(height:10),
  SizedBox(height:42,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:categories.length,separatorBuilder:(_,__)=>const SizedBox(width:8),itemBuilder:(x,i)=>ChoiceChip(label:Text(categories[i]),selected:category==categories[i],onSelected:(_)=>setState(()=>category=categories[i]),selectedColor:FoodieColors.light))),
  const SizedBox(height:20),const SectionHeading('Popular near you'),const SizedBox(height:8),
  ...foods.map((f)=>FoodCard(item:f,onAdd:(){setState(()=>cart.add(f));ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('${f.name} added to cart')));})),
  const SizedBox(height:12),const SectionHeading('Featured restaurants'),
  ...['Green Garden • Healthy food • 4.8 ★','Burger House • Burgers • 4.7 ★','Pizza Corner • Italian • 4.6 ★'].map((r)=>Card(child:ListTile(leading:const CircleAvatar(backgroundColor:FoodieColors.light,child:Text('🍽️')),title:Text(r),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.pushNamed(c,'/customer/restaurant-details'))))
 ]),
 bottomNavigationBar:NavigationBar(selectedIndex:0,onDestinationSelected:(i){if(i==1)Navigator.push(c,MaterialPageRoute(builder:(_)=>const ExplorePage()));if(i==2)Navigator.push(c,MaterialPageRoute(builder:(_)=>const CartPage()));if(i==3)Navigator.push(c,MaterialPageRoute(builder:(_)=>const ProfilePage()));},destinations:const[NavigationDestination(icon:Icon(Icons.home_outlined),label:'Home'),NavigationDestination(icon:Icon(Icons.explore_outlined),label:'Explore'),NavigationDestination(icon:Icon(Icons.shopping_bag_outlined),label:'Cart'),NavigationDestination(icon:Icon(Icons.person_outline),label:'Profile')])
 );}
}
