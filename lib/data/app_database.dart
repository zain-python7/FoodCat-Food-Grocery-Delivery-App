import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _db;
  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    return openDatabase(join(root, 'foodcat.db'), version: 3,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT UNIQUE NOT NULL, password TEXT NOT NULL, role TEXT NOT NULL, phone TEXT, created_at TEXT NOT NULL)');
        await db.execute('CREATE TABLE restaurants(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE NOT NULL, cuisine TEXT NOT NULL, rating TEXT NOT NULL, eta TEXT NOT NULL, delivery_fee REAL NOT NULL DEFAULT 99, image TEXT, description TEXT, is_open INTEGER NOT NULL DEFAULT 1)');
        await db.execute('CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, restaurant TEXT NOT NULL, description TEXT, price REAL NOT NULL, category TEXT NOT NULL, image TEXT, is_grocery INTEGER NOT NULL DEFAULT 0, available INTEGER NOT NULL DEFAULT 1, stock INTEGER NOT NULL DEFAULT 100)');
        await db.execute('CREATE TABLE cart_items(id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER NOT NULL, name TEXT NOT NULL, price REAL NOT NULL, quantity INTEGER NOT NULL, image TEXT)');
        await db.execute('CREATE TABLE orders(id INTEGER PRIMARY KEY AUTOINCREMENT, order_code TEXT NOT NULL, user_email TEXT, items_json TEXT NOT NULL, total REAL NOT NULL, status TEXT NOT NULL, address TEXT NOT NULL, created_at TEXT NOT NULL)');
        await db.execute('CREATE TABLE favorites(product_id INTEGER PRIMARY KEY, created_at TEXT NOT NULL)');
        await db.execute('CREATE TABLE addresses(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, address TEXT NOT NULL, is_default INTEGER NOT NULL DEFAULT 0)');
        await db.execute('CREATE TABLE app_settings(key TEXT PRIMARY KEY, value TEXT NOT NULL)');
        await db.execute('CREATE TABLE notifications(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, body TEXT NOT NULL, created_at TEXT NOT NULL, is_read INTEGER NOT NULL DEFAULT 0)');
        await db.execute('CREATE TABLE support_tickets(id INTEGER PRIMARY KEY AUTOINCREMENT, subject TEXT NOT NULL, message TEXT NOT NULL, status TEXT NOT NULL, created_at TEXT NOT NULL)');
        await db.execute('CREATE TABLE vouchers(id INTEGER PRIMARY KEY AUTOINCREMENT, code TEXT UNIQUE NOT NULL, discount REAL NOT NULL, active INTEGER NOT NULL DEFAULT 1)');
        await db.execute('CREATE TABLE deliveries(id INTEGER PRIMARY KEY AUTOINCREMENT, order_code TEXT NOT NULL, rider TEXT, status TEXT NOT NULL, fee REAL NOT NULL DEFAULT 150)');
        await _seed(db);
        await _seedRestaurants(db);
      },
      onUpgrade: (db, old, version) async {
        if (old < 2) {
          await db.execute('ALTER TABLE orders ADD COLUMN user_email TEXT');
          await db.execute('ALTER TABLE products ADD COLUMN stock INTEGER NOT NULL DEFAULT 100');
          await db.execute('CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT UNIQUE NOT NULL, password TEXT NOT NULL, role TEXT NOT NULL, phone TEXT, created_at TEXT NOT NULL)');
          await db.execute('CREATE TABLE IF NOT EXISTS notifications(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, body TEXT NOT NULL, created_at TEXT NOT NULL, is_read INTEGER NOT NULL DEFAULT 0)');
          await db.execute('CREATE TABLE IF NOT EXISTS support_tickets(id INTEGER PRIMARY KEY AUTOINCREMENT, subject TEXT NOT NULL, message TEXT NOT NULL, status TEXT NOT NULL, created_at TEXT NOT NULL)');
          await db.execute('CREATE TABLE IF NOT EXISTS vouchers(id INTEGER PRIMARY KEY AUTOINCREMENT, code TEXT UNIQUE NOT NULL, discount REAL NOT NULL, active INTEGER NOT NULL DEFAULT 1)');
          await db.execute('CREATE TABLE IF NOT EXISTS deliveries(id INTEGER PRIMARY KEY AUTOINCREMENT, order_code TEXT NOT NULL, rider TEXT, status TEXT NOT NULL, fee REAL NOT NULL DEFAULT 150)');
        }
        if (old < 3) {
          await db.execute('CREATE TABLE IF NOT EXISTS restaurants(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE NOT NULL, cuisine TEXT NOT NULL, rating TEXT NOT NULL, eta TEXT NOT NULL, delivery_fee REAL NOT NULL DEFAULT 99, image TEXT, description TEXT, is_open INTEGER NOT NULL DEFAULT 1)');
          await db.execute("UPDATE products SET image = CASE name WHEN 'Double Smash Burger' THEN 'assets/images/products/double_smash_burger.jpg' WHEN 'Crispy Zinger Burger' THEN 'assets/images/products/crispy_zinger_burger.jpg' WHEN 'Loaded Cheese Fries' THEN 'assets/images/products/loaded_cheese_fries.jpg' WHEN 'Pepperoni Pizza' THEN 'assets/images/products/pepperoni_pizza.jpg' WHEN 'Chicken Biryani' THEN 'assets/images/products/chicken_biryani.jpg' WHEN 'Chicken Karahi' THEN 'assets/images/products/chicken_karahi.jpg' WHEN 'Chocolate Lava Cake' THEN 'assets/images/products/chocolate_lava_cake.jpg' WHEN 'Fresh Milk 1L' THEN 'assets/images/products/fresh_milk.jpg' WHEN 'Bananas 1 Dozen' THEN 'assets/images/products/bananas.jpg' WHEN 'Farm Fresh Eggs' THEN 'assets/images/products/farm_eggs.jpg' WHEN 'Brown Bread' THEN 'assets/images/products/brown_bread.jpg' WHEN 'Orange Juice 1L' THEN 'assets/images/products/orange_juice.jpg' ELSE image END");
          await _seedRestaurants(db);
        }
      });
  }

  Future<void> _seed(Database db) async {
    final rows = [
      ['Double Smash Burger','Meow Burgers & Fries','Double beef patty, cheddar and house sauce.',890,'Burgers',0],
      ['Crispy Zinger Burger','Meow Burgers & Fries','Crispy chicken, lettuce and spicy mayo.',650,'Burgers',0],
      ['Loaded Cheese Fries','Meow Burgers & Fries','Golden fries with cheese and jalapeños.',450,'Sides',0],
      ['Pepperoni Pizza','Purrfect Pizza Co.','Classic mozzarella and pepperoni pizza.',1450,'Pizza',0],
      ['Chicken Biryani','Whiskers Biryani House','Aromatic basmati rice and tender chicken.',520,'Pakistani',0],
      ['Chicken Karahi','Whiskers Biryani House','Traditional tomato chicken karahi.',1150,'Pakistani',0],
      ['Chocolate Lava Cake','Sweet Paws Bakery','Warm chocolate cake with a molten centre.',480,'Desserts',0],
      ['Fresh Milk 1L','CatMart','Fresh dairy milk.',340,'Dairy',1],
      ['Bananas 1 Dozen','CatMart','Fresh bananas.',280,'Fruits',1],
      ['Farm Fresh Eggs','CatMart','Pack of 12 farm eggs.',420,'Dairy',1],
      ['Brown Bread','CatMart','Whole wheat bakery bread.',190,'Bakery',1],
      ['Orange Juice 1L','CatMart','Fresh orange juice.',520,'Drinks',1],
    ];
    final batch = db.batch();
    for (final p in rows) {
      batch.insert('products', {'name':p[0], 'restaurant':p[1], 'description':p[2], 'price':p[3], 'category':p[4], 'image':_productImage(p[0]), 'is_grocery':p[5], 'available':1, 'stock':100});
    }
    batch.insert('vouchers', {'code':'FOODCAT50','discount':50,'active':1}, conflictAlgorithm: ConflictAlgorithm.ignore);
    batch.insert('vouchers', {'code':'WELCOME100','discount':100,'active':1}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await batch.commit(noResult: true);
  }

  String _productImage(Object? name) => switch (name) {
    'Double Smash Burger' => 'assets/images/products/double_smash_burger.jpg',
    'Crispy Zinger Burger' => 'assets/images/products/crispy_zinger_burger.jpg',
    'Loaded Cheese Fries' => 'assets/images/products/loaded_cheese_fries.jpg',
    'Pepperoni Pizza' => 'assets/images/products/pepperoni_pizza.jpg',
    'Chicken Biryani' => 'assets/images/products/chicken_biryani.jpg',
    'Chicken Karahi' => 'assets/images/products/chicken_karahi.jpg',
    'Chocolate Lava Cake' => 'assets/images/products/chocolate_lava_cake.jpg',
    'Fresh Milk 1L' => 'assets/images/products/fresh_milk.jpg',
    'Bananas 1 Dozen' => 'assets/images/products/bananas.jpg',
    'Farm Fresh Eggs' => 'assets/images/products/farm_eggs.jpg',
    'Brown Bread' => 'assets/images/products/brown_bread.jpg',
    'Orange Juice 1L' => 'assets/images/products/orange_juice.jpg',
    _ => '',
  };

  Future<void> _seedRestaurants(Database db) async {
    final rows = [
      ['Meow Burgers & Fries','Burgers • Fast food','4.8','20–30 min',99,'assets/images/restaurants/meow_burgers_restaurant.jpg','Smash burgers, crispy chicken and loaded sides'],
      ['Purrfect Pizza Co.','Pizza • Italian','4.7','25–35 min',120,'assets/images/restaurants/purrfect_pizza_restaurant.jpg','Freshly baked pizzas with generous toppings'],
      ['Whiskers Biryani House','Pakistani • Desi','4.9','30–40 min',99,'assets/images/restaurants/whiskers_biryani_restaurant.jpg','Comforting biryani and traditional karahi'],
      ['Sweet Paws Bakery','Bakery • Desserts','4.6','20–30 min',80,'assets/images/restaurants/sweet_paws_bakery.jpg','Sweet treats, cakes and freshly baked goods'],
    ];
    final batch = db.batch();
    for (final r in rows) {
      batch.insert('restaurants', {'name':r[0], 'cuisine':r[1], 'rating':r[2], 'eta':r[3], 'delivery_fee':r[4], 'image':r[5], 'description':r[6], 'is_open':1}, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String,Object?>>> restaurants() async => (await database).query('restaurants', where:'is_open = 1', orderBy:'rating DESC');
  Future<List<Map<String,Object?>>> productsByRestaurant(String name) async => (await database).query('products', where:'restaurant = ? AND is_grocery = 0 AND available = 1', whereArgs:[name], orderBy:'name');

  String _passwordHash(String password) => sha256.convert(utf8.encode(password)).toString();
  Future<Map<String,Object?>?> login(String email, String password, String role) async {
    final rows = await (await database).query('users', where:'email = ? AND password = ? AND role = ?', whereArgs:[email.trim().toLowerCase(), _passwordHash(password), role], limit:1);
    return rows.isEmpty ? null : rows.first;
  }
  Future<void> register({required String name, required String email, required String password, required String role, String phone = ''}) async { await (await database).insert('users', {'name':name.trim(),'email':email.trim().toLowerCase(),'password':_passwordHash(password),'role':role,'phone':phone,'created_at':DateTime.now().toIso8601String()}); }
  Future<List<Map<String,Object?>>> products({bool grocery=false,String query='',String? category}) async {
    final db=await database; final where=['is_grocery = ?','available = 1','name LIKE ?']; final args=<Object?>[grocery?1:0,'%$query%'];
    if(category!=null && category!='All'){where.add('category = ?');args.add(category);}
    return db.query('products',where:where.join(' AND '),whereArgs:args,orderBy:'name');
  }
  Future<List<Map<String,Object?>>> cart() async => (await database).query('cart_items',orderBy:'id DESC');
  Future<void> addToCart(Map<String,Object?> p) async {final db=await database;final found=await db.query('cart_items',where:'product_id = ?',whereArgs:[p['id']]);if(found.isEmpty){await db.insert('cart_items',{'product_id':p['id'],'name':p['name'],'price':p['price'],'quantity':1,'image':p['image']});}else{await db.update('cart_items',{'quantity':(found.first['quantity'] as int)+1},where:'product_id = ?',whereArgs:[p['id']]);}}
  Future<void> changeQuantity(int id,int delta) async {final db=await database;final r=await db.query('cart_items',where:'id = ?',whereArgs:[id]);if(r.isEmpty)return;final q=(r.first['quantity'] as int)+delta;if(q<1){await db.delete('cart_items',where:'id = ?',whereArgs:[id]);}else{await db.update('cart_items',{'quantity':q},where:'id = ?',whereArgs:[id]);}}
  Future<void> clearCart() async { await (await database).delete('cart_items'); }
  Future<void> createOrder({required String address,required double total,required String itemsJson,required String email}) async {final db=await database;final code='FC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';await db.insert('orders',{'order_code':code,'user_email':email,'items_json':itemsJson,'total':total,'status':'Confirmed','address':address,'created_at':DateTime.now().toIso8601String()});await db.insert('deliveries',{'order_code':code,'status':'Finding rider','fee':150});await clearCart();}
  Future<List<Map<String,Object?>>> orders({String? email}) async => (await database).query('orders',where:email==null?null:'user_email = ?',whereArgs:email==null?null:[email],orderBy:'id DESC');
  Future<List<Map<String,Object?>>> addresses() async => (await database).query('addresses',orderBy:'is_default DESC,id DESC');
  Future<void> addAddress(String title,String address) async { await (await database).insert('addresses',{'title':title,'address':address,'is_default':0}); }
  Future<void> favorite(int id) async {final db=await database;final r=await db.query('favorites',where:'product_id = ?',whereArgs:[id]);if(r.isEmpty){await db.insert('favorites',{'product_id':id,'created_at':DateTime.now().toIso8601String()});}else{await db.delete('favorites',where:'product_id = ?',whereArgs:[id]);}}
  Future<bool> isFavorite(int id) async => (await (await database).query('favorites',where:'product_id = ?',whereArgs:[id])).isNotEmpty;
  Future<List<Map<String,Object?>>> favorites() async => (await database).rawQuery('SELECT p.* FROM products p INNER JOIN favorites f ON p.id=f.product_id ORDER BY f.created_at DESC');
  Future<String?> setting(String key) async {final r=await (await database).query('app_settings',where:'key = ?',whereArgs:[key]);return r.isEmpty?null:r.first['value'] as String;}
  Future<void> saveSetting(String key,String value) async { await (await database).insert('app_settings',{'key':key,'value':value},conflictAlgorithm:ConflictAlgorithm.replace); }
  Future<void> addTicket(String subject,String message) async { await (await database).insert('support_tickets',{'subject':subject,'message':message,'status':'Open','created_at':DateTime.now().toIso8601String()}); }
  Future<List<Map<String,Object?>>> tickets() async => (await database).query('support_tickets',orderBy:'id DESC');
  Future<List<Map<String,Object?>>> allUsers() async => (await database).query('users',orderBy:'created_at DESC');
  Future<List<Map<String,Object?>>> allOrders() async => (await database).query('orders',orderBy:'id DESC');
  Future<void> updateOrderStatus(int id,String status) async { await (await database).update('orders',{'status':status},where:'id = ?',whereArgs:[id]); }
  Future<void> updateProductStock(int id,int stock) async { await (await database).update('products',{'stock':stock},where:'id = ?',whereArgs:[id]); }
  Future<List<Map<String,Object?>>> allProducts() async => (await database).query('products',orderBy:'id DESC');
}
