import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/app_database.dart';
import 'data/cart_provider.dart';
import 'screens/brand_splash_screen.dart';
import 'core/foodcat_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;
  runApp(ChangeNotifierProvider(create: (_) => CartProvider()..refresh(), child: const FoodCatApp()));
}

class FoodCatApp extends StatelessWidget {
  const FoodCatApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title:'FoodCat — Food & Grocery Delivery', debugShowCheckedModeBanner:false,
    theme:ThemeData(useMaterial3:true,pageTransitionsTheme:const PageTransitionsTheme(builders:{TargetPlatform.android:FadeUpwardsPageTransitionsBuilder(),TargetPlatform.iOS:CupertinoPageTransitionsBuilder(),TargetPlatform.macOS:CupertinoPageTransitionsBuilder(),TargetPlatform.windows:FadeUpwardsPageTransitionsBuilder(),TargetPlatform.linux:FadeUpwardsPageTransitionsBuilder()}),colorScheme:ColorScheme.fromSeed(seedColor:FoodCatColors.primary,primary:FoodCatColors.primary),scaffoldBackgroundColor:FoodCatColors.background,fontFamily:'Roboto',appBarTheme:const AppBarTheme(backgroundColor:FoodCatColors.background,foregroundColor:FoodCatColors.dark,elevation:0),inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(15),borderSide:BorderSide.none),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(15),borderSide:BorderSide(color:Color(0xFFF0E5EB))),contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:15))),
    home:const BrandSplashScreen());
}
