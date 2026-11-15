import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../data/app_database.dart';
import '../core/foodcat_colors.dart';
import '../data/cart_provider.dart';
import 'auth_screen.dart';
import '../widgets/brand_wordmark.dart';

const pink=FoodCatColors.primary, ink=FoodCatColors.dark, muted=FoodCatColors.muted;

class HomeShell extends StatefulWidget {
  final Map<String, Object?> user;
  const HomeShell({super.key, required this.user});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  Map<String, Object?> get user => widget.user;
  String get role => user['role'] as String;

  List<_Tab> get tabs => switch (role) {
    'Customer' => [
      _Tab('Discover', Icons.home_rounded),
      _Tab('CatMart', Icons.shopping_basket_outlined),
      _Tab('Orders', Icons.receipt_long),
      _Tab('Account', Icons.person_outline),
    ],
    'Restaurant Partner' => [
      _Tab('Dashboard', Icons.dashboard_outlined),
      _Tab('Orders', Icons.receipt_long),
      _Tab('Menu & Stock', Icons.restaurant_menu),
      _Tab('Store', Icons.storefront),
    ],
    'Rider' => [
      _Tab('My Shift', Icons.map_outlined),
      _Tab('Deliveries', Icons.delivery_dining),
      _Tab('Earnings', Icons.account_balance_wallet_outlined),
      _Tab('Profile', Icons.person_outline),
    ],
    _ => [
      _Tab('Overview', Icons.dashboard),
      _Tab('Dispatch', Icons.route),
      _Tab('Merchants', Icons.store_mall_directory_outlined),
      _Tab('More', Icons.grid_view),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final pages = switch (role) {
      'Customer' => [
        CustomerHome(user: user),
        const GroceryPage(),
        OrdersPage(email: user['email'] as String),
        AccountPage(user: user),
      ],
      'Restaurant Partner' => [
        PartnerDashboard(user: user),
        const PartnerOrdersPage(),
        const InventoryPage(),
        const PartnerStorePage(),
      ],
      'Rider' => [
        RiderShiftPage(user: user),
        const RiderDeliveriesPage(),
        const RiderEarningsPage(),
        RiderProfilePage(user: user),
      ],
      _ => [
        const AdminOverviewPage(),
        const DispatchPage(),
        const MerchantPage(),
        const AdminMorePage(),
      ],
    };

    return Scaffold(
      appBar: AppBar(
        title: const FoodCatWordmark(),
        actions: [
          if (role == 'Customer')
            Consumer<CartProvider>(
              builder: (context, cart, _) => IconButton(
                onPressed: () => go(CartPage(email: user['email'] as String)),
                icon: Badge(
                  isLabelVisible: cart.count > 0,
                  label: Text('${cart.count}'),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') go(SettingsPage(role: role));
              if (value == 'profile') go(ProfilePage(user: user));
              if (value == 'help') go(const SupportPage());
              if (value == 'logout') logout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('My profile')),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'help', child: Text('Help & support')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'logout', child: Text('Sign out')),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: tabs.map((tab) => NavigationDestination(
          icon: Icon(tab.icon),
          label: tab.label,
        )).toList(),
      ),
    );
  }

  void go(Widget page) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => page),
  );

  void logout() => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const AuthScreen()),
    (_) => false,
  );
}

class _Tab{final String label;final IconData icon;const _Tab(this.label,this.icon);}

class CustomerHome extends StatefulWidget{final Map<String,Object?> user;const CustomerHome({super.key,required this.user});@override State<CustomerHome> createState()=>_CustomerHomeState();}
class _CustomerHomeState extends State<CustomerHome> {
  List<Map<String, Object?>> items = [];
  String category = 'All';
  final categories = ['All', 'Burgers', 'Pizza', 'Pakistani', 'Sides', 'Desserts'];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final products = await AppDatabase.instance.products(category: category);
    if (mounted) setState(() => items = products);
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: load,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: pink),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DELIVER TO', style: TextStyle(
                    fontSize: 10, color: muted, fontWeight: FontWeight.bold,
                  )),
                  Text('Gulberg III, Lahore', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressPage()),
              ),
              child: const Text('Change'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchPage()),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(children: [
              Icon(Icons.search, color: muted),
              SizedBox(width: 10),
              Text('Search dishes, restaurants & more', style: TextStyle(color: muted)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 158,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFE21B70), Color(0xFFAB1457)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('A little treat, on us!', style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900,
              )),
              Text('Get Rs. 100 off your first order', style: TextStyle(color: Colors.white)),
              Spacer(),
              Text('USE WELCOME100  →', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold,
              )),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _Heading('Explore categories', ''),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((item) => ChoiceChip(
            label: Text(item),
            selected: category == item,
            onSelected: (_) {
              setState(() => category = item);
              load();
            },
          )).toList(),
        ),
        const SizedBox(height: 18),
        _Heading('Restaurants near you', 'See all'),
        const SizedBox(height: 8),
        FutureBuilder<List<Map<String,Object?>>>(
          future: AppDatabase.instance.restaurants(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox(height: 190, child: Center(child: CircularProgressIndicator()));
            final restaurants = snapshot.data!;
            return SizedBox(
              height: 226,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: restaurants.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _RestaurantCard(restaurant: restaurants[index]),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        _Heading('Popular dishes', 'Made for you'),
        ...items.map((product) => ProductCard(product: product)),
      ],
    ),
  );
}


class GroceryPage extends StatefulWidget{const GroceryPage({super.key});@override State<GroceryPage> createState()=>_GroceryPageState();}
class _GroceryPageState extends State<GroceryPage>{List<Map<String,Object?>> items=[];@override void initState(){super.initState();AppDatabase.instance.products(grocery:true).then((v){if(mounted)setState(()=>items=v);});}@override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('CatMart',style:TextStyle(fontSize:27,fontWeight:FontWeight.w900,color:pink)),const Text('Everyday essentials, delivered with care.'),const SizedBox(height:16),Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:const Color(0xFFFFE5F0),borderRadius:BorderRadius.circular(18)),child:const Text('Fresh picks for your home',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),),const SizedBox(height:16),...items.map((p)=>ProductCard(product:p))]);}

class ProductCard extends StatelessWidget {
  final Map<String,Object?> product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final image = (product['image'] ?? '').toString();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: SizedBox(
              width: 104, height: 104,
              child: image.isNotEmpty
                ? Image.asset(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _foodImageFallback())
                : _foodImageFallback(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${product['name']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 3),
            Text('${product['restaurant']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 7),
            Text('Rs. ${(product['price'] as num).toStringAsFixed(0)}', style: const TextStyle(color: pink, fontWeight: FontWeight.w900, fontSize: 15)),
            const SizedBox(height: 6),
            SizedBox(height: 34, child: FilledButton(
              onPressed: () async {
                await context.read<CartProvider>().add(product);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to your cart')));
              },
              style: FilledButton.styleFrom(backgroundColor: pink, padding: const EdgeInsets.symmetric(horizontal: 18)),
              child: const Text('Add to cart'),
            )),
          ])),
          IconButton(
            tooltip: 'Add to favourites',
            onPressed: () async {
              await AppDatabase.instance.favorite(product['id'] as int);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Favourite list updated')));
            },
            icon: const Icon(Icons.favorite_border, color: pink),
          ),
        ]),
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: .06, end: 0, curve: Curves.easeOut);
  }
}

Widget _foodImageFallback() => Container(
  color: const Color(0xFFFFE5F0),
  child: const Center(child: Icon(Icons.fastfood_rounded, color: pink, size: 34)),
);

class _RestaurantCard extends StatelessWidget {
  final Map<String,Object?> restaurant;
  const _RestaurantCard({required this.restaurant});
  @override
  Widget build(BuildContext context) {
    final image = '${restaurant['image'] ?? ''}';
    return SizedBox(
      width: 252,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantPage(name: '${restaurant['name']}'))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 126, width: double.infinity, child: image.isEmpty ? _foodImageFallback() : Image.asset(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _foodImageFallback())),
            Padding(padding: const EdgeInsets.fromLTRB(12, 9, 12, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${restaurant['name']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(height: 3),
              Text('${restaurant['cuisine']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 11)),
              const SizedBox(height: 7),
              Row(children: [const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 16), Text(' ${restaurant['rating']}  •  ${restaurant['eta']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)), const Spacer(), Text('Rs. ${restaurant['delivery_fee']}', style: const TextStyle(fontSize: 11, color: pink, fontWeight: FontWeight.bold))]),
            ])),
          ]),
        ),
      ).animate().fadeIn(duration: 350.ms).slideX(begin: .06, end: 0),
    );
  }
}

IconData _productIcon(String c)=>switch(c){'Pizza'=>Icons.local_pizza,'Burgers'=>Icons.lunch_dining,'Pakistani'=>Icons.rice_bowl,'Dairy'=>Icons.egg_alt,'Fruits'=>Icons.eco,'Desserts'=>Icons.cake,_=>Icons.fastfood};

class CartPage extends StatefulWidget{final String email;const CartPage({super.key,required this.email});@override State<CartPage> createState()=>_CartPageState();}
class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your cart')),
    body: Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (cart.items.isEmpty) {
          return const _Empty(
            icon: Icons.shopping_bag_outlined,
            title: 'Your cart is waiting',
            subtitle: 'Add something delicious to get started.',
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: cart.items.map((p) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFE5F0),
                      child: Icon(Icons.fastfood, color: pink),
                    ),
                    title: Text('${p['name']}'),
                    subtitle: Text('Rs. ${p['price']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => cart.change(p['id'] as int, -1),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${p['quantity']}'),
                        IconButton(
                          onPressed: () => cart.change(p['id'] as int, 1),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              color: Colors.white,
              child: Column(
                children: [
                  _line('Subtotal', 'Rs. ${cart.total.toStringAsFixed(0)}'),
                  _line('Delivery', 'Rs. 150'),
                  const Divider(),
                  _line('Total', 'Rs. ${(cart.total + 150).toStringAsFixed(0)}', bold: true),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutPage(
                            total: cart.total + 150,
                            email: widget.email,
                          ),
                        ),
                      ),
                      child: const Text('Proceed to checkout'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

class CheckoutPage extends StatefulWidget{final double total;final String email;const CheckoutPage({super.key,required this.total,required this.email});@override State<CheckoutPage> createState()=>_CheckoutPageState();}
class _CheckoutPageState extends State<CheckoutPage>{final address=TextEditingController(text:'House 12, Main Boulevard, Gulberg III, Lahore');String payment='Cash on delivery';bool busy=false;@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Checkout')),body:ListView(padding:const EdgeInsets.all(18),children:[const Text('Delivery address',style:TextStyle(fontWeight:FontWeight.bold,fontSize:17)),const SizedBox(height:10),TextField(controller:address,maxLines:2,decoration:const InputDecoration(prefixIcon:Icon(Icons.location_on_outlined),hintText:'Enter complete address')),const SizedBox(height:22),const Text('Payment method',style:TextStyle(fontWeight:FontWeight.bold,fontSize:17)),...['Cash on delivery','Card (demo only)','Wallet (demo only)'].map((p)=>RadioListTile<String>(value:p,groupValue:payment,title:Text(p),onChanged:(v)=>setState(()=>payment=v!))),const SizedBox(height:14),_line('Order total','Rs. ${widget.total.toStringAsFixed(0)}',bold:true),const SizedBox(height:18),FilledButton(onPressed:busy?null:place,child:Text(busy?'Placing order...':'Place order'))]));Future<void> place()async{if(address.text.trim().length<8){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Please enter a complete address.')));return;}setState(()=>busy=true);final cart=await AppDatabase.instance.cart();await AppDatabase.instance.createOrder(address:address.text,total:widget.total,itemsJson:jsonEncode(cart),email:widget.email);if(!mounted)return;await context.read<CartProvider>().refresh();showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('Order placed!'),content:Text('Your FoodCat order has been saved locally. Payment: $payment'),actions:[TextButton(onPressed:()=>Navigator.popUntil(context,(r)=>r.isFirst),child:const Text('Done'))]));}}

class OrdersPage extends StatefulWidget{final String email;const OrdersPage({super.key,required this.email});@override State<OrdersPage> createState()=>_OrdersPageState();}
class _OrdersPageState extends State<OrdersPage>{
  List<Map<String,Object?>> rows=[];
  @override void initState(){super.initState();load();}
  Future<void> load() async {final r=await AppDatabase.instance.orders(email:widget.email);if(mounted)setState(()=>rows=r);}
  @override Widget build(BuildContext context) => rows.isEmpty
    ? const _Empty(icon:Icons.receipt_long,title:'No orders yet',subtitle:'Your delicious orders will appear here.')
    : ListView(padding:const EdgeInsets.all(16),children:rows.map((o)=>Card(child:ListTile(
      leading:const CircleAvatar(backgroundColor:Color(0xFFFFE5F0),child:Icon(Icons.receipt,color:pink)),
      title:Text('${o['order_code']}'),
      subtitle:Text('${o['status']}  •  Rs. ${o['total']}\\n${o['created_at']}'),
      isThreeLine:true,trailing:const Icon(Icons.chevron_right),
      onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>OrderDetailPage(order:o))),
    ))).toList());
}

class AccountPage extends StatelessWidget{final Map<String,Object?> user;const AccountPage({super.key,required this.user});@override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(18),children:[_profileHeader(user),const SizedBox(height:16),_menu(context,'My profile',Icons.person_outline,()=>_push(context,ProfilePage(user:user))),_menu(context,'Saved addresses',Icons.location_on_outlined,()=>_push(context,const AddressPage())),_menu(context,'Favourites',Icons.favorite_border,()=>_push(context,const FavoritesPage())),_menu(context,'CatPro membership',Icons.workspace_premium_outlined,()=>_push(context,const CatProPage())),_menu(context,'Notifications',Icons.notifications_none,()=>_push(context,const NotificationsPage())),_menu(context,'Help & support',Icons.support_agent,()=>_push(context,const SupportPage())),_menu(context,'Settings',Icons.settings_outlined,()=>_push(context,SettingsPage(role:user['role'] as String))),_menu(context,'Sign out',Icons.logout,()=>Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const AuthScreen()),(_)=>false))]);}

class PartnerDashboard extends StatelessWidget{final Map<String,Object?> user;const PartnerDashboard({super.key,required this.user});@override Widget build(BuildContext context)=>_dashboard('Good morning, ${user['name']}','Your restaurant at a glance',[['New orders','08'],['Preparing','05'],['Today sales','Rs. 24.5k'],['Menu items','32']],[['Live orders',Icons.receipt_long,()=>_push(context,const PartnerOrdersPage())],['Manage menu & stock',Icons.restaurant_menu,()=>_push(context,const InventoryPage())],['Revenue & payouts',Icons.payments_outlined,()=>_push(context,const PartnerPayoutPage())],['Store profile & hours',Icons.storefront,()=>_push(context,const PartnerStorePage())],['Reviews & feedback',Icons.star_outline,()=>_push(context,const ReviewsPage())],['Partner settings',Icons.settings,()=>_push(context,const SettingsPage(role:'Restaurant Partner'))]]);}
class PartnerOrdersPage extends StatelessWidget{const PartnerOrdersPage({super.key});@override Widget build(BuildContext context)=>_OrderManager(title:'Restaurant orders',partner:true);}
class InventoryPage extends StatefulWidget{const InventoryPage({super.key});@override State<InventoryPage> createState()=>_InventoryPageState();}
class _InventoryPageState extends State<InventoryPage> {
  List<Map<String, Object?>> rows = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final products = await AppDatabase.instance.allProducts();
    if (mounted) setState(() => rows = products);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Menu & inventory'),
      actions: [
        IconButton(
          onPressed: () => _editProduct(context, null, load),
          icon: const Icon(Icons.add),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text(
          'Update item availability and stock levels.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 12),
        ...rows.map((product) => Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFE5F0),
              child: Icon(Icons.fastfood, color: pink),
            ),
            title: Text('${product['name']}'),
            subtitle: Text('Rs. ${product['price']} • Stock: ${product['stock']}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  await _editProduct(context, product, load);
                }
                if (value == 'toggle') {
                  final db = await AppDatabase.instance.database;
                  await db.update(
                    'products',
                    {'available': product['available'] == 1 ? 0 : 1},
                    where: 'id = ?',
                    whereArgs: [product['id']],
                  );
                  await load();
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit stock')),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(product['available'] == 1
                    ? 'Mark unavailable'
                    : 'Mark available'),
                ),
              ],
            ),
          ),
        )),
      ],
    ),
  );
}

Future<void> _editProduct(
  BuildContext context,
  Map<String, Object?>? product,
  Future<void> Function() reload,
) async {
  final controller = TextEditingController(
    text: '${product?['stock'] ?? '100'}',
  );
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Update ${product?['name'] ?? 'stock'}'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Available stock'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final quantity = int.tryParse(controller.text);
            if (quantity != null && product != null) {
              await AppDatabase.instance.updateProductStock(
                product['id'] as int,
                quantity,
              );
            }
            if (dialogContext.mounted) Navigator.pop(dialogContext);
            await reload();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class PartnerStorePage extends StatelessWidget{final Map<String,Object?>? user;const PartnerStorePage({super.key,this.user});@override Widget build(BuildContext context)=>FeatureListPage(title:'Store profile',subtitle:'Configure how customers see your restaurant.',items:[['Restaurant information','Name, description and contact details',Icons.storefront],['Opening hours','Set weekly opening and closing times',Icons.schedule],['Delivery coverage','Service areas and delivery radius',Icons.map_outlined],['Pause orders','Temporarily stop incoming orders',Icons.pause_circle_outline],['Notifications','Choose order and payout alerts',Icons.notifications_outlined],['Store settings','Preferences and account options',Icons.settings]],actions:{'Restaurant information':()=>_push(context,const EditProfilePage(title:'Restaurant information')),'Opening hours':()=>_push(context,const OpeningHoursPage()),'Delivery coverage':()=>_push(context,const CoveragePage()),'Pause orders':()=>_push(context,const PauseOrdersPage()),'Notifications':()=>_push(context,const NotificationsPage()),'Store settings':()=>_push(context,const SettingsPage(role:'Restaurant Partner'))});}
class PartnerPayoutPage extends StatelessWidget{const PartnerPayoutPage({super.key});@override Widget build(BuildContext context)=>_dashboard('Revenue & payouts','Illustrative demo figures',[['Today','Rs. 24,500'],['This week','Rs. 138,200'],['Pending payout','Rs. 42,600'],['Completed payouts','Rs. 18']],[['Payout history',Icons.history,()=>_push(context,const HistoryPage(title:'Payout history'))],['Bank account details',Icons.account_balance,()=>_push(context,const EditProfilePage(title:'Payout account'))],['Download statement',Icons.download,()=>_push(context,const HistoryPage(title:'Statements'))]]);}

class RiderShiftPage extends StatelessWidget{final Map<String,Object?> user;const RiderShiftPage({super.key,required this.user});@override Widget build(BuildContext context)=>_dashboard('Hello, ${user['name']}','Ready to make deliveries?',[['Shift status','Offline'],['Today deliveries','06'],['Today earnings','Rs. 1,250'],['Rating','4.9 ★']],[['Go online / shift controls',Icons.power_settings_new,()=>_push(context,const ShiftControlsPage())],['Available delivery requests',Icons.notifications_active,()=>_push(context,const RiderDeliveriesPage())],['Navigation & pickup guide',Icons.navigation,()=>_push(context,const RiderGuidePage())],['Earnings wallet',Icons.account_balance_wallet,()=>_push(context,const RiderEarningsPage())],['Vehicle & documents',Icons.two_wheeler,()=>_push(context,const RiderDocumentsPage())],['Rider settings',Icons.settings,()=>_push(context,const SettingsPage(role:'Rider'))]]);}
class RiderDeliveriesPage extends StatelessWidget{const RiderDeliveriesPage({super.key});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Delivery requests')),body:ListView(padding:const EdgeInsets.all(16),children:[const Text('Sample delivery queue for the demo app.',style:TextStyle(color:muted)),...['FC-2041 • Meow Burgers • Gulberg III','FC-2042 • CatMart • Model Town','FC-2043 • Purrfect Pizza • DHA Phase 5'].map((e)=>Card(child:ListTile(leading:const CircleAvatar(backgroundColor:Color(0xFFFFE5F0),child:Icon(Icons.delivery_dining,color:pink)),title:Text(e),subtitle:const Text('Pickup and drop-off details'),trailing:FilledButton(onPressed:()=>_push(context,DeliveryDetailPage(orderCode:e.split(' • ').first)),child:const Text('View')))))]));}
class RiderEarningsPage extends StatelessWidget{const RiderEarningsPage({super.key});@override Widget build(BuildContext context)=>_dashboard('Earnings wallet','Track your delivery income',[['Today','Rs. 1,250'],['This week','Rs. 8,450'],['This month','Rs. 31,200'],['Completed trips','64']],[['Earning history',Icons.history,()=>_push(context,const HistoryPage(title:'Earning history'))],['Payout method',Icons.account_balance,()=>_push(context,const EditProfilePage(title:'Payout method'))],['Weekly performance',Icons.insights,()=>_push(context,const ReviewsPage())]]);}
class RiderProfilePage extends StatelessWidget{final Map<String,Object?> user;const RiderProfilePage({super.key,required this.user});@override Widget build(BuildContext context)=>FeatureListPage(title:'Rider profile',subtitle:'Your rider account and documents.',items:[['Personal details','Name, phone and email',Icons.person],['Vehicle details','Bike model and registration',Icons.two_wheeler],['Documents','Licence and identity verification',Icons.badge],['Safety centre','Emergency and safety information',Icons.health_and_safety],['Settings','App preferences',Icons.settings]],actions:{'Personal details':()=>_push(context,ProfilePage(user:user)),'Vehicle details':()=>_push(context,const RiderDocumentsPage()),'Documents':()=>_push(context,const RiderDocumentsPage()),'Safety centre':()=>_push(context,const SafetyPage()),'Settings':()=>_push(context,const SettingsPage(role:'Rider'))});}

class AdminOverviewPage extends StatelessWidget{const AdminOverviewPage({super.key});@override Widget build(BuildContext context)=>_dashboard('Platform overview','FoodCat operations snapshot',[['Gross sales','Rs. 486k'],['Orders today','1,284'],['Active riders','86'],['Restaurants','148']],[['Order management',Icons.receipt_long,()=>_push(context,const AdminOrdersPage())],['User management',Icons.people_outline,()=>_push(context,const UserManagementPage())],['Merchant approvals',Icons.verified_user,()=>_push(context,const MerchantPage())],['Live dispatch map',Icons.route,()=>_push(context,const DispatchPage())],['Promotions & vouchers',Icons.local_offer_outlined,()=>_push(context,const VoucherPage())],['Reports & analytics',Icons.analytics,()=>_push(context,const ReportsPage())],['Platform settings',Icons.settings,()=>_push(context,const SettingsPage(role:'Admin'))]]);}
class DispatchPage extends StatelessWidget{const DispatchPage({super.key});@override Widget build(BuildContext context)=>_dashboard('Dispatch centre','Monitor rider availability and deliveries',[['Online riders','86'],['Unassigned orders','12'],['On delivery','54'],['Delayed','03']],[['Rider fleet',Icons.two_wheeler,()=>_push(context,const RiderFleetPage())],['Unassigned orders',Icons.assignment_late,()=>_push(context,const AdminOrdersPage())],['Delivery zones',Icons.map,()=>_push(context,const CoveragePage())],['Dispatch settings',Icons.settings,()=>_push(context,const SettingsPage(role:'Admin'))]]);}
class MerchantPage extends StatelessWidget{const MerchantPage({super.key});@override Widget build(BuildContext context)=>_dashboard('Merchant centre','Manage restaurant partner applications',[['Pending review','08'],['Approved','148'],['Rejected','03'],['Suspended','02']],[['Review pending applications',Icons.pending_actions,()=>_push(context,const MerchantReviewPage())],['Approved restaurants',Icons.store,()=>_push(context,const MerchantReviewPage())],['Partner support',Icons.support_agent,()=>_push(context,const SupportPage())]]);}
class AdminMorePage extends StatelessWidget{const AdminMorePage({super.key});@override Widget build(BuildContext context)=>FeatureListPage(title:'Platform management',subtitle:'Manage every part of the FoodCat ecosystem.',items:[['Users & roles','Review customer, rider and partner accounts',Icons.people],['Orders','View and update all orders',Icons.receipt_long],['Rider fleet','Rider performance and availability',Icons.two_wheeler],['Vouchers & CatPro','Manage discount campaigns',Icons.local_offer],['Reports','Sales and operations reports',Icons.analytics],['Support inbox','Customer and partner tickets',Icons.support_agent],['Settings','Platform configuration',Icons.settings]],actions:{'Users & roles':()=>_push(context,const UserManagementPage()),'Orders':()=>_push(context,const AdminOrdersPage()),'Rider fleet':()=>_push(context,const RiderFleetPage()),'Vouchers & CatPro':()=>_push(context,const VoucherPage()),'Reports':()=>_push(context,const ReportsPage()),'Support inbox':()=>_push(context,const SupportPage()),'Settings':()=>_push(context,const SettingsPage(role:'Admin'))});}

class _OrderManager extends StatefulWidget{final String title;final bool partner;const _OrderManager({required this.title,this.partner=false});@override State<_OrderManager> createState()=>_OrderManagerState();}
class _OrderManagerState extends State<_OrderManager>{List<Map<String,Object?>> rows=[];@override void initState(){super.initState();load();}Future<void>load()async{final r=await AppDatabase.instance.allOrders();if(mounted)setState(()=>rows=r);} @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.title)),body:rows.isEmpty?const _Empty(icon:Icons.receipt_long,title:'No orders to show',subtitle:'New orders will appear here when customers check out.'):ListView(padding:const EdgeInsets.all(14),children:rows.map((o)=>Card(child:ListTile(title:Text('${o['order_code']}'),subtitle:Text('${o['status']} • Rs. ${o['total']}\n${o['address']}'),isThreeLine:true,trailing:PopupMenuButton<String>(onSelected:(s)async{await AppDatabase.instance.updateOrderStatus(o['id'] as int,s);load();},itemBuilder:(_)=>['Confirmed','Preparing','Ready for pickup','On the way','Delivered','Cancelled'].map((s)=>PopupMenuItem(value:s,child:Text(s))).toList())))).toList()));}
class AdminOrdersPage extends StatelessWidget{const AdminOrdersPage({super.key});@override Widget build(BuildContext context)=>const _OrderManager(title:'All platform orders');}
class UserManagementPage extends StatefulWidget{const UserManagementPage({super.key});@override State<UserManagementPage> createState()=>_UserManagementPageState();}
class _UserManagementPageState extends State<UserManagementPage>{List<Map<String,Object?>> users=[];@override void initState(){super.initState();load();}Future<void>load()async{final u=await AppDatabase.instance.allUsers();if(mounted)setState(()=>users=u);}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('User management')),body:users.isEmpty?const _Empty(icon:Icons.people_outline,title:'No registered users',subtitle:'New accounts will appear here.'):ListView(padding:const EdgeInsets.all(14),children:users.map((u)=>Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.person)),title:Text('${u['name']}'),subtitle:Text('${u['email']} • ${u['role']}')))).toList()));}
class MerchantReviewPage extends StatelessWidget{const MerchantReviewPage({super.key});@override Widget build(BuildContext context)=>FeatureListPage(title:'Merchant applications',subtitle:'Sample review queue. Connect a secure backend before using real applications.',items:[['Purrfect Pizza Co.','Documents submitted • Pending',Icons.store],['Whiskers Biryani House','Awaiting bank details • Pending',Icons.restaurant],['Meow Burgers & Fries','Approved merchant',Icons.verified]],actions:{'Purrfect Pizza Co.':()=>_push(context,const MerchantApplicationPage(name:'Purrfect Pizza Co.')),'Whiskers Biryani House':()=>_push(context,const MerchantApplicationPage(name:'Whiskers Biryani House')),'Meow Burgers & Fries':()=>_push(context,const MerchantApplicationPage(name:'Meow Burgers & Fries'))});}
class MerchantApplicationPage extends StatelessWidget{final String name;const MerchantApplicationPage({super.key,required this.name});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Merchant application')),body:ListView(padding:const EdgeInsets.all(18),children:[Text(name,style:const TextStyle(fontSize:23,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Review business details, owner identity, bank account and food licence documents.'),const SizedBox(height:20),_line('Application status','Pending review'),_line('Business verification','Documents submitted'),_line('Payout verification','Awaiting review'),const SizedBox(height:20),FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Demo action: approval request recorded locally.'))),child:const Text('Approve merchant')),OutlinedButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Demo action: request for more information sent.'))),child:const Text('Request more information'))]));}
class RiderFleetPage extends StatelessWidget{const RiderFleetPage({super.key});@override Widget build(BuildContext context)=>FeatureListPage(title:'Rider fleet',subtitle:'Demo rider roster and shift status.',items:[['Hamza Ali','Online • Gulberg III',Icons.two_wheeler],['Ayesha Khan','Available • DHA',Icons.two_wheeler],['Bilal Ahmed','On delivery • Model Town',Icons.two_wheeler],['Sara Malik','Offline • Johar Town',Icons.two_wheeler]],actions:{'Hamza Ali':()=>_push(context,const RiderDetailPage(name:'Hamza Ali')),'Ayesha Khan':()=>_push(context,const RiderDetailPage(name:'Ayesha Khan')),'Bilal Ahmed':()=>_push(context,const RiderDetailPage(name:'Bilal Ahmed')),'Sara Malik':()=>_push(context,const RiderDetailPage(name:'Sara Malik'))});}
class RiderDetailPage extends StatelessWidget{final String name;const RiderDetailPage({super.key,required this.name});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Rider details')),body:ListView(padding:const EdgeInsets.all(18),children:[Text(name,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)),_line('Status','Available'),_line('Rating','4.9 / 5'),_line('Completed deliveries','126'),_line('Current zone','Lahore'),const SizedBox(height:18),FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Rider contact action is a demo.'))),child:const Text('Contact rider'))]));}
class VoucherPage extends StatefulWidget{const VoucherPage({super.key});@override State<VoucherPage> createState()=>_VoucherPageState();}
class _VoucherPageState extends State<VoucherPage>{List<Map<String,Object?>> vouchers=[];@override void initState(){super.initState();load();}Future<void>load()async{final r=await (await AppDatabase.instance.database).query('vouchers');if(mounted)setState(()=>vouchers=r);}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Vouchers & CatPro'),actions:[IconButton(onPressed:add,icon:const Icon(Icons.add))]),body:ListView(padding:const EdgeInsets.all(14),children:[const Text('Discount codes stored in the local SQLite database.'),const SizedBox(height:12),...vouchers.map((v)=>Card(child:ListTile(leading:const Icon(Icons.local_offer,color:pink),title:Text('${v['code']}'),subtitle:Text('Rs. ${v['discount']} off'),trailing:Switch(value:v['active']==1,onChanged:(b)async{await (await AppDatabase.instance.database).update('vouchers',{'active':b?1:0},where:'id = ?',whereArgs:[v['id']]);load();}))))]));Future<void>add()async{final c=TextEditingController(),d=TextEditingController(text:'100');await showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('Create voucher'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:c,decoration:const InputDecoration(labelText:'Voucher code')),TextField(controller:d,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Discount in Rs.'))]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:()async{final discount=double.tryParse(d.text)??0;if(c.text.trim().isNotEmpty){await (await AppDatabase.instance.database).insert('vouchers',{'code':c.text.trim().toUpperCase(),'discount':discount,'active':1});}if(context.mounted)Navigator.pop(context);load();},child:const Text('Create'))]));}}
class ReportsPage extends StatelessWidget{const ReportsPage({super.key});@override Widget build(BuildContext context)=>_dashboard('Reports & analytics','Demo operational indicators',[['Gross merchandise value','Rs. 486,200'],['Average order','Rs. 780'],['Repeat customers','38%'],['Order completion','96.4%']],[['Sales report',Icons.bar_chart,()=>_push(context,const HistoryPage(title:'Sales report'))],['Restaurant performance',Icons.store,()=>_push(context,const HistoryPage(title:'Restaurant performance'))],['Rider performance',Icons.delivery_dining,()=>_push(context,const RiderFleetPage())],['Export centre',Icons.download,()=>_push(context,const HistoryPage(title:'Export centre'))]]);}

class SettingsPage extends StatefulWidget{final String role;const SettingsPage({super.key,required this.role});@override State<SettingsPage> createState()=>_SettingsPageState();}
class _SettingsPageState extends State<SettingsPage>{bool push=true,email=true,sms=false,dark=false,offers=true;@override void initState(){super.initState();load();}Future<void>load()async{for(final k in ['push','email','sms','dark','offers']){final v=await AppDatabase.instance.setting(k);if(v!=null){final b=v=='true';if(!mounted)return;setState((){if(k=='push')push=b;if(k=='email')email=b;if(k=='sms')sms=b;if(k=='dark')dark=b;if(k=='offers')offers=b;});}}}Future<void>save(String k,bool v)async{await AppDatabase.instance.saveSetting(k,'$v');}Widget toggle(String title,String subtitle,bool value,ValueChanged<bool> onChanged)=>SwitchListTile(title:Text(title,style:const TextStyle(fontWeight:FontWeight.w600)),subtitle:Text(subtitle,style:const TextStyle(color:muted,fontSize:12)),value:value,activeColor:pink,onChanged:onChanged);@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text('${widget.role} settings')),body:ListView(padding:const EdgeInsets.all(16),children:[const Text('PREFERENCES',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:muted,letterSpacing:1)),Card(child:Column(children:[toggle('Push notifications','Order and account updates',push,(v){setState(()=>push=v);save('push',v);}),toggle('Email updates','Receipts and important notices',email,(v){setState(()=>email=v);save('email',v);}),toggle('SMS alerts','Time-sensitive updates by text',sms,(v){setState(()=>sms=v);save('sms',v);}),toggle('Promotions','Offers, rewards and new features',offers,(v){setState(()=>offers=v);save('offers',v);}),toggle('Dark appearance preference','Save your preferred appearance',dark,(v){setState(()=>dark=v);save('dark',v);})])),const SizedBox(height:18),const Text('ACCOUNT & SECURITY',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:muted,letterSpacing:1)),_menu(context,'Change password',Icons.lock_outline,()=>_push(context,const ChangePasswordPage())),_menu(context,'Privacy policy',Icons.privacy_tip_outlined,()=>_push(context,const LegalPage(title:'Privacy policy'))),_menu(context,'Terms of service',Icons.description_outlined,()=>_push(context,const LegalPage(title:'Terms of service'))),_menu(context,'About FoodCat',Icons.info_outline,()=>_push(context,const AboutPage())),const SizedBox(height:12),const Center(child:Text('FoodCat • Demo build 1.0.0',style:TextStyle(color:muted,fontSize:12)))]));}

class ProfilePage extends StatelessWidget{final Map<String,Object?> user;const ProfilePage({super.key,required this.user});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('My profile')),body:ListView(padding:const EdgeInsets.all(18),children:[_profileHeader(user),const SizedBox(height:20),_line('Full name','${user['name']}'),_line('Email','${user['email']}'),_line('Account role','${user['role']}'),_line('Phone','${user['phone']??'Not provided'}'),const SizedBox(height:18),FilledButton(onPressed:()=>_push(context,const EditProfilePage(title:'Edit profile')),child:const Text('Edit profile'))]));}
class EditProfilePage extends StatelessWidget{final String title;const EditProfilePage({super.key,required this.title});@override Widget build(BuildContext context){final name=TextEditingController(),phone=TextEditingController();return Scaffold(appBar:AppBar(title:Text(title)),body:ListView(padding:const EdgeInsets.all(18),children:[TextField(controller:name,decoration:const InputDecoration(labelText:'Name / account holder')),const SizedBox(height:12),TextField(controller:phone,decoration:const InputDecoration(labelText:'Phone / account reference')),const SizedBox(height:18),FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Demo form saved for this session. Connect an API to persist profile changes.'))),child:const Text('Save changes'))]));}}
class ChangePasswordPage extends StatelessWidget{const ChangePasswordPage({super.key});@override Widget build(BuildContext context){final a=TextEditingController(),b=TextEditingController();return Scaffold(appBar:AppBar(title:const Text('Change password')),body:ListView(padding:const EdgeInsets.all(18),children:[TextField(controller:a,obscureText:true,decoration:const InputDecoration(labelText:'Current password')),const SizedBox(height:12),TextField(controller:b,obscureText:true,decoration:const InputDecoration(labelText:'New password')),const SizedBox(height:18),FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Password changes require a secure authentication backend.'))),child:const Text('Update password'))]));}}
class AddressPage extends StatefulWidget{const AddressPage({super.key});@override State<AddressPage> createState()=>_AddressPageState();}
class _AddressPageState extends State<AddressPage>{List<Map<String,Object?>> rows=[];@override void initState(){super.initState();load();}Future<void>load()async{final r=await AppDatabase.instance.addresses();if(mounted)setState(()=>rows=r);}Future<void>add()async{final t=TextEditingController(text:'Home'),a=TextEditingController();await showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('Add delivery address'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:t,decoration:const InputDecoration(labelText:'Label')),TextField(controller:a,maxLines:2,decoration:const InputDecoration(labelText:'Complete address'))]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:()async{if(a.text.trim().isNotEmpty)await AppDatabase.instance.addAddress(t.text,a.text);if(context.mounted)Navigator.pop(context);load();},child:const Text('Save'))]));}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Saved addresses'),actions:[IconButton(onPressed:add,icon:const Icon(Icons.add))]),body:ListView(padding:const EdgeInsets.all(14),children:[...rows.map((r)=>Card(child:ListTile(leading:const Icon(Icons.location_on,color:pink),title:Text('${r['title']}'),subtitle:Text('${r['address']}')))),if(rows.isEmpty)const _Empty(icon:Icons.location_on,title:'No saved addresses',subtitle:'Add a home or work address for faster checkout.'),if(rows.isEmpty)FilledButton(onPressed:add,child:const Text('Add address'))]));}
class FavoritesPage extends StatefulWidget{const FavoritesPage({super.key});@override State<FavoritesPage> createState()=>_FavoritesPageState();}
class _FavoritesPageState extends State<FavoritesPage>{List<Map<String,Object?>> rows=[];@override void initState(){super.initState();load();}Future<void>load()async{final r=await AppDatabase.instance.favorites();if(mounted)setState(()=>rows=r);}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Favourites')),body:rows.isEmpty?const _Empty(icon:Icons.favorite_border,title:'Nothing saved yet',subtitle:'Tap the heart on a dish to keep it here.'):ListView(padding:const EdgeInsets.all(14),children:rows.map((p)=>ProductCard(product:p)).toList()));}
class NotificationsPage extends StatelessWidget{const NotificationsPage({super.key});@override Widget build(BuildContext context)=>FeatureListPage(title:'Notifications',subtitle:'Your important FoodCat updates.',items:[['Welcome to FoodCat','Your account is ready to use.',Icons.waving_hand],['Order updates','Order status changes will appear here.',Icons.receipt_long],['Offers & rewards','New promotions and CatPro rewards.',Icons.local_offer]],actions:{'Welcome to FoodCat':()=>_push(context,const NotificationDetailPage(title:'Welcome to FoodCat')),'Order updates':()=>_push(context,const NotificationDetailPage(title:'Order updates')),'Offers & rewards':()=>_push(context,const NotificationDetailPage(title:'Offers & rewards'))});}
class SupportPage extends StatefulWidget{const SupportPage({super.key});@override State<SupportPage> createState()=>_SupportPageState();}
class _SupportPageState extends State<SupportPage>{final s=TextEditingController(),m=TextEditingController();List<Map<String,Object?>> tickets=[];@override void initState(){super.initState();load();}Future<void>load()async{final r=await AppDatabase.instance.tickets();if(mounted)setState(()=>tickets=r);}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Help & support')),body:ListView(padding:const EdgeInsets.all(18),children:[const Text('How can we help?',style:TextStyle(fontSize:23,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Send a support request. It will be saved in your local demo database.'),const SizedBox(height:16),TextField(controller:s,decoration:const InputDecoration(labelText:'Subject')),const SizedBox(height:10),TextField(controller:m,maxLines:4,decoration:const InputDecoration(labelText:'Describe your issue')),const SizedBox(height:12),FilledButton(onPressed:()async{if(s.text.trim().isEmpty||m.text.trim().isEmpty)return;await AppDatabase.instance.addTicket(s.text,m.text);s.clear();m.clear();load();if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Support request saved.')));},child:const Text('Submit request')),const SizedBox(height:22),const Text('Your requests',style:TextStyle(fontWeight:FontWeight.bold,fontSize:17)),...tickets.map((t)=>Card(child:ListTile(title:Text('${t['subject']}'),subtitle:Text('${t['status']} • ${t['created_at']}'))))]));}

class CatProPage extends StatelessWidget{const CatProPage({super.key});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('CatPro membership')),body:ListView(padding:const EdgeInsets.all(18),children:[Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF30233D),Color(0xFF6A3B68)]),borderRadius:BorderRadius.circular(22)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.workspace_premium,color:Color(0xFFFFD76A),size:36),SizedBox(height:12),Text('CatPro',style:TextStyle(color:Colors.white,fontSize:28,fontWeight:FontWeight.w900)),Text('A little more joy in every order.',style:TextStyle(color:Colors.white70))])),const SizedBox(height:20),...['Free delivery on selected orders','Exclusive member-only offers','Priority customer support','Special birthday rewards'].map((e)=>ListTile(leading:const Icon(Icons.check_circle,color:pink),title:Text(e))),FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('CatPro subscription is a demo feature.'))),child:const Text('Explore membership'))]));}
class OrderDetailPage extends StatelessWidget{final Map<String,Object?> order;const OrderDetailPage({super.key,required this.order});@override Widget build(BuildContext context){final items=jsonDecode(order['items_json'] as String) as List;return Scaffold(appBar:AppBar(title:Text('${order['order_code']}')),body:ListView(padding:const EdgeInsets.all(18),children:[Text('${order['status']}',style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:pink)),const SizedBox(height:14),_line('Order placed','${order['created_at']}'),_line('Delivery address','${order['address']}'),_line('Total','Rs. ${order['total']}'),const SizedBox(height:18),const Text('Items',style:TextStyle(fontWeight:FontWeight.bold,fontSize:17)),...items.map((e)=>ListTile(title:Text('${e['name']}'),subtitle:Text('Quantity: ${e['quantity']}'),trailing:Text('Rs. ${e['price']}'))),const SizedBox(height:14),FilledButton(onPressed:()=>_push(context,const TrackOrderPage()),child:const Text('Track order'))]));}}
class TrackOrderPage extends StatelessWidget{const TrackOrderPage({super.key});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Live order tracking')),body:ListView(padding:const EdgeInsets.all(20),children:[Container(height:170,decoration:BoxDecoration(color:const Color(0xFFFFE5F0),borderRadius:BorderRadius.circular(20)),child:const Center(child:Icon(Icons.map_outlined,color:pink,size:80))),const SizedBox(height:20),...['Order confirmed','Restaurant is preparing your food','Rider assigned','On the way to you','Delivered'].asMap().entries.map((e)=>ListTile(leading:CircleAvatar(backgroundColor:e.key<2?pink:const Color(0xFFFFE5F0),child:Icon(Icons.check,color:e.key<2?Colors.white:pink)),title:Text(e.value),subtitle:Text(e.key<2?'Completed':'Waiting for update'))),const Text('Tracking shown here is a local demo. Live GPS requires rider location permissions and a backend service.',style:TextStyle(color:muted))]));}
class RestaurantPage extends StatelessWidget {
  final String name;
  const RestaurantPage({super.key, required this.name});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(name)),
    body: FutureBuilder<List<Map<String,Object?>>>(
      future: AppDatabase.instance.productsByRestaurant(name),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final menu = snapshot.data!;
        return ListView(padding: const EdgeInsets.all(16), children: [
          FutureBuilder<List<Map<String,Object?>>>(
            future: AppDatabase.instance.restaurants(),
            builder: (context, restaurantSnapshot) {
              final found = restaurantSnapshot.data?.where((r) => r['name'] == name).toList() ?? [];
              final r = found.isEmpty ? null : found.first;
              final image = '${r?['image'] ?? ''}';
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(borderRadius: BorderRadius.circular(18), child: SizedBox(height: 178, width: double.infinity, child: image.isEmpty ? _foodImageFallback() : Image.asset(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _foodImageFallback()))),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                Text('${r?['cuisine'] ?? 'Freshly prepared'}  •  ★ ${r?['rating'] ?? '4.8'}  •  ${r?['eta'] ?? '25–35 min'}', style: const TextStyle(color: muted)),
                if (r != null) Text('${r['description']}', style: const TextStyle(color: muted, fontSize: 12)),
              ]);
            },
          ),
          const SizedBox(height: 20),
          const Text('MENU', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: pink)),
          const SizedBox(height: 10),
          if (menu.isEmpty) const _Empty(icon: Icons.restaurant_menu, title: 'Menu coming soon', subtitle: 'This restaurant has not added dishes yet.'),
          ...menu.map((product) => ProductCard(product: product)),
        ]);
      },
    ),
  );
}
class SearchPage extends StatefulWidget{const SearchPage({super.key});@override State<SearchPage> createState()=>_SearchPageState();}
class _SearchPageState extends State<SearchPage>{final c=TextEditingController();List<Map<String,Object?>> rows=[];Future<void>search(String q)async{final a=await AppDatabase.instance.products(query:q);final b=await AppDatabase.instance.products(grocery:true,query:q);if(mounted)setState(()=>rows=[...a,...b]);}@override void initState(){super.initState();search('');}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Search FoodCat')),body:Column(children:[Padding(padding:const EdgeInsets.all(14),child:TextField(controller:c,onChanged:search,decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search dishes, stores and groceries'))),Expanded(child:ListView(padding:const EdgeInsets.symmetric(horizontal:14),children:rows.map((p)=>ProductCard(product:p)).toList()))]));}
class DeliveryDetailPage extends StatelessWidget{final String orderCode;const DeliveryDetailPage({super.key,required this.orderCode});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Delivery details')),body:ListView(padding:const EdgeInsets.all(18),children:[Text(orderCode,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)),_line('Pickup','Meow Burgers & Fries, Gulberg'),_line('Drop-off','Main Boulevard, Lahore'),_line('Estimated distance','3.2 km'),_line('Delivery fee','Rs. 150'),const SizedBox(height:20),FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Demo: delivery accepted.'))),child:const Text('Accept delivery')),OutlinedButton(onPressed:()=>_push(context,const RiderGuidePage()),child:const Text('Pickup & navigation guide'))]));}
class ShiftControlsPage extends StatefulWidget{const ShiftControlsPage({super.key});@override State<ShiftControlsPage> createState()=>_ShiftControlsPageState();}
class _ShiftControlsPageState extends State<ShiftControlsPage>{bool online=false;@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Shift controls')),body:Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(online?Icons.delivery_dining:Icons.power_settings_new,color:online?Colors.green:pink,size:76),const SizedBox(height:16),Text(online?'You are online':'You are offline',style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Toggle your availability for new delivery requests.',textAlign:TextAlign.center),const SizedBox(height:20),Switch(value:online,activeColor:pink,onChanged:(v)=>setState(()=>online=v)),FilledButton(onPressed:()=>setState(()=>online=!online),child:Text(online?'Go offline':'Go online'))]))));}
class RiderGuidePage extends StatelessWidget{const RiderGuidePage({super.key});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Pickup & navigation guide')),body:ListView(padding:const EdgeInsets.all(18),children:[...['Review the pickup address and order code','Reach the restaurant safely','Confirm the order before leaving','Use your navigation app for the customer address','Confirm delivery only after handing over the order'].asMap().entries.map((e)=>ListTile(leading:CircleAvatar(backgroundColor:const Color(0xFFFFE5F0),child:Text('${e.key+1}',style:const TextStyle(color:pink,fontWeight:FontWeight.bold))),title:Text(e.value))),const Text('Turn-by-turn navigation and GPS route sharing are not enabled in this offline demo.',style:TextStyle(color:muted))]));}
class RiderDocumentsPage extends StatelessWidget{const RiderDocumentsPage({super.key});@override Widget build(BuildContext context)=>FeatureListPage(title:'Vehicle & documents',subtitle:'Keep rider information up to date.',items:[['Vehicle','Motorcycle • Registration details',Icons.two_wheeler],['Driving licence','Upload and verify licence',Icons.badge],['Identity document','Identity verification status',Icons.contact_page],['Emergency contact','Add a trusted contact',Icons.emergency]],actions:{'Vehicle':()=>_push(context,const EditProfilePage(title:'Vehicle details')),'Driving licence':()=>_push(context,const EditProfilePage(title:'Driving licence')),'Identity document':()=>_push(context,const EditProfilePage(title:'Identity document')),'Emergency contact':()=>_push(context,const EditProfilePage(title:'Emergency contact'))});}
class SafetyPage extends StatelessWidget{const SafetyPage({super.key});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Safety centre')),body:ListView(padding:const EdgeInsets.all(18),children:[const Icon(Icons.health_and_safety,color:pink,size:60),const Text('Your safety comes first',style:TextStyle(fontSize:23,fontWeight:FontWeight.bold)),const Text('Wear a helmet, follow traffic rules, keep your phone charged and never use your phone while riding.'),const SizedBox(height:20),FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Emergency calling is not connected in this demo.'))),child:const Text('Emergency help information'))]));}
class CoveragePage extends StatelessWidget{const CoveragePage({super.key});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Delivery coverage')),body:ListView(padding:const EdgeInsets.all(18),children:[Container(height:180,decoration:BoxDecoration(color:const Color(0xFFFFE5F0),borderRadius:BorderRadius.circular(18)),child:const Center(child:Icon(Icons.map,color:pink,size:72))),const SizedBox(height:16),...['Gulberg','DHA','Model Town','Johar Town','Garden Town'].map((z)=>CheckboxListTile(value:true,onChanged:(_)=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Zone editing is a demo interaction.'))),title:Text(z))),const Text('Map coverage editing requires a mapping SDK and backend geofencing.',style:TextStyle(color:muted))]));}
class PauseOrdersPage extends StatefulWidget{const PauseOrdersPage({super.key});@override State<PauseOrdersPage> createState()=>_PauseOrdersPageState();}
class _PauseOrdersPageState extends State<PauseOrdersPage>{bool paused=false;@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Pause orders')),body:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(paused?Icons.pause_circle:Icons.play_circle,color:pink,size:70),Text(paused?'Orders are paused':'Your store is accepting orders',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),Switch(value:paused,activeColor:pink,onChanged:(v)=>setState(()=>paused=v)),FilledButton(onPressed:()=>setState(()=>paused=!paused),child:Text(paused?'Resume orders':'Pause incoming orders'))])));}
class OpeningHoursPage extends StatelessWidget {
  const OpeningHoursPage({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    appBar:AppBar(title:const Text('Opening hours')),
    body:ListView(padding:const EdgeInsets.all(16),children:['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'].map((d)=>Card(
      child:ListTile(title:Text(d),subtitle:const Text('10:00 AM – 11:00 PM'),
        trailing:IconButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Edit $d hours (demo)'))),icon:const Icon(Icons.edit_outlined)),
      ),
    )).toList()),
  );
}
class ReviewsPage extends StatelessWidget{const ReviewsPage({super.key});@override Widget build(BuildContext context)=>FeatureListPage(title:'Reviews & feedback',subtitle:'Example feedback cards for your business.',items:[['Great food and quick delivery','★★★★★ • Customer review',Icons.star],['Packaging could be better','★★★☆☆ • Customer review',Icons.rate_review],['Excellent service','★★★★★ • Customer review',Icons.thumb_up]],actions:{'Great food and quick delivery':()=>_push(context,const ReviewDetailPage()),'Packaging could be better':()=>_push(context,const ReviewDetailPage()),'Excellent service':()=>_push(context,const ReviewDetailPage())});}
class ReviewDetailPage extends StatelessWidget{const ReviewDetailPage({super.key});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Review details')),body:ListView(padding:const EdgeInsets.all(18),children:[const Text('Customer feedback',style:TextStyle(fontSize:23,fontWeight:FontWeight.bold)),const Text('Thank you for your feedback. Your review helps improve the FoodCat experience.'),const SizedBox(height:20),TextField(maxLines:4,decoration:const InputDecoration(labelText:'Write a public response')),const SizedBox(height:12),FilledButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Reply saved as a demo.'))),child:const Text('Post reply'))]));}
class HistoryPage extends StatelessWidget{final String title;const HistoryPage({super.key,required this.title});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(title)),body:const _Empty(icon:Icons.history,title:'No records to display',subtitle:'Transaction and report records will appear when connected to live services.'));}
class NotificationDetailPage extends StatelessWidget{final String title;const NotificationDetailPage({super.key,required this.title});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(title)),body:Padding(padding:const EdgeInsets.all(20),child:Text('$title\n\nFoodCat notifications and updates will appear in this section.',style:const TextStyle(fontSize:17,height:1.6))));}
class LegalPage extends StatelessWidget{final String title;const LegalPage({super.key,required this.title});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(title)),body:const Padding(padding:EdgeInsets.all(20),child:Text('This is a starter policy page for the FoodCat demo. Before publishing, replace this text with reviewed legal terms, privacy disclosures, data retention details and contact information.')));}
class AboutPage extends StatelessWidget{const AboutPage({super.key});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('About FoodCat')),body:ListView(padding:const EdgeInsets.all(20),children:[const Icon(Icons.pets,color:pink,size:64),const Text('FoodCat',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const Text('Food, groceries and happy moments.'),const SizedBox(height:12),_line('Version','1.0.0'),_line('Build','Local demo'),_line('Database','SQLite') ]));}

class FeatureListPage extends StatelessWidget{final String title,subtitle;final List<List<Object>> items;final Map<String,VoidCallback> actions;const FeatureListPage({super.key,required this.title,required this.subtitle,required this.items,required this.actions});@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(title)),body:ListView(padding:const EdgeInsets.all(16),children:[Text(subtitle,style:const TextStyle(color:muted)),const SizedBox(height:14),...items.map((i)=>Card(child:ListTile(leading:CircleAvatar(backgroundColor:const Color(0xFFFFE5F0),child:Icon(i[2] as IconData,color:pink)),title:Text(i[0] as String,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(i[1] as String),trailing:const Icon(Icons.chevron_right),onTap:actions[i[0] as String]??()=>_push(context,const AboutPage()))))]));}
Widget _dashboard(String title,String subtitle,List<List<String>> stats,List<List<Object>> actions)=>Builder(builder:(context)=>Scaffold(appBar:AppBar(title:const Text('FoodCat workspace')),body:ListView(padding:const EdgeInsets.all(16),children:[Text(title,style:const TextStyle(fontSize:23,fontWeight:FontWeight.w900,color:ink)),Text(subtitle,style:const TextStyle(color:muted)),const SizedBox(height:18),GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,childAspectRatio:1.65,crossAxisSpacing:10,mainAxisSpacing:10,children:stats.map((s)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(17),border:Border.all(color:const Color(0xFFF1E7ED))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Text(s[0],style:const TextStyle(color:muted,fontSize:12)),const SizedBox(height:7),Text(s[1],style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900,color:pink))]))).toList()),const SizedBox(height:20),const Text('QUICK ACTIONS',style:TextStyle(fontSize:11,fontWeight:FontWeight.bold,color:muted,letterSpacing:1)),const SizedBox(height:8),...actions.map((a)=>Card(child:ListTile(leading:CircleAvatar(backgroundColor:const Color(0xFFFFE5F0),child:Icon(a[1] as IconData,color:pink)),title:Text(a[0] as String,style:const TextStyle(fontWeight:FontWeight.w600)),trailing:const Icon(Icons.chevron_right),onTap:a[2] as VoidCallback)))])));
class _Heading extends StatelessWidget{final String title,action;const _Heading(this.title,this.action);@override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:10),child:Row(children:[Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const Spacer(),if(action.isNotEmpty)TextButton(onPressed:()=>_push(context,const SearchPage()),child:Text(action))]));}
class _Empty extends StatelessWidget{final IconData icon;final String title,subtitle;const _Empty({required this.icon,required this.title,required this.subtitle});@override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(30),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(icon,color:pink,size:56),const SizedBox(height:12),Text(title,style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold)),const SizedBox(height:6),Text(subtitle,textAlign:TextAlign.center,style:const TextStyle(color:muted))])));}
Widget _profileHeader(Map<String,Object?> user)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:const Color(0xFFFFE5F0),borderRadius:BorderRadius.circular(18)),child:Row(children:[const CircleAvatar(radius:29,backgroundColor:Colors.white,child:Icon(Icons.person,color:pink,size:30)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${user['name']}',style:const TextStyle(fontWeight:FontWeight.bold,fontSize:17)),Text('${user['email']}',style:const TextStyle(color:muted,fontSize:12)),Text('${user['role']}',style:const TextStyle(color:pink,fontSize:12,fontWeight:FontWeight.bold))]))]));
Widget _menu(BuildContext context,String title,IconData icon,VoidCallback onTap)=>Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(leading:Icon(icon,color:pink),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w600)),trailing:const Icon(Icons.chevron_right,color:muted),onTap:onTap));
Widget _line(String title,String value,{bool bold=false})=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Text(title,style:const TextStyle(color:muted))),const SizedBox(width:10),Flexible(child:Text(value,textAlign:TextAlign.end,style:TextStyle(fontWeight:bold?FontWeight.w900:FontWeight.w600,color:ink)))]));
void _push(BuildContext context,Widget page)=>Navigator.push(context,MaterialPageRoute(builder:(_)=>page));
