import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

enum Art { burger, chicken, pizza, fries, biryani, drink, dessert, noodles }

const kCategories = ['Burgers', 'Pizza', 'Desi', 'Chinese', 'Desserts', 'Drinks'];
const kCatArt = {
  'Burgers': Art.burger,
  'Pizza': Art.pizza,
  'Desi': Art.biryani,
  'Chinese': Art.noodles,
  'Desserts': Art.dessert,
  'Drinks': Art.drink,
  'Sides': Art.fries,
};
const kExtras = {
  'Extra cheddar': 80,
  'Jalapeños': 50,
  'Make it a meal': 220,
  'Extra sauce': 40,
  'Dipping sauce': 60,
  'Extra cheese': 120,
  'Extra shot': 80,
  'Make it large': 60,
  'Extra raita': 50,
  'Extra naan': 60,
  'Extra topping': 70,
  'Ice cream scoop': 120,
};

List<String> extrasFor(String cat) {
  switch (cat) {
    case 'Burgers':
      return ['Extra cheddar', 'Jalapeños', 'Make it a meal'];
    case 'Sides':
      return ['Extra sauce', 'Dipping sauce'];
    case 'Pizza':
      return ['Extra cheese', 'Dipping sauce'];
    case 'Drinks':
      return ['Extra shot', 'Make it large'];
    case 'Desi':
      return ['Extra raita', 'Extra naan'];
    case 'Desserts':
      return ['Extra topping', 'Ice cream scoop'];
    default:
      return ['Extra sauce'];
  }
}
const kPromos = {'WELCOME10': 10, 'FOODIE20': 20};

class Food {
  final String id, rid;
  String name, desc, cat;
  int price;
  Art art;
  bool available;
  Food(this.id, this.rid, this.name, this.desc, this.cat, this.price, this.art, {this.available = true});
}

class Rest {
  final String id, name, tagline, time, area;
  final double rating, km;
  final int from;
  final Art art;
  final bool free, offer;
  String status; // Approved / Pending / Suspended
  Rest(this.id, this.name, this.tagline, this.time, this.area, this.rating, this.km, this.from, this.art, {this.free = true, this.offer = false, this.status = 'Approved'});
}

class Line {
  final Food food;
  int qty;
  final List<String> extras;
  Line(this.food, this.qty, this.extras);
  int get unit => food.price + extras.fold<int>(0, (a, e) => a + (kExtras[e] ?? 0));
  int get total => unit * qty;
}

class Addr {
  String label, line;
  Addr(this.label, this.line);
}

class Note {
  final String title, body, kind;
  final DateTime at;
  bool unread;
  Note(this.title, this.body, this.kind, this.at, {this.unread = true});
}

enum OStatus { placed, accepted, preparing, ready, pickedUp, delivered, rejected }

extension OStatusX on OStatus {
  String get label => const {
        OStatus.placed: 'Placed',
        OStatus.accepted: 'Accepted',
        OStatus.preparing: 'Preparing',
        OStatus.ready: 'Ready for pickup',
        OStatus.pickedUp: 'On the way',
        OStatus.delivered: 'Delivered',
        OStatus.rejected: 'Rejected',
      }[this]!;
}

class Order {
  final String id, rid, customer, address, payment, code, note;
  final List<Line> lines;
  final int sub, fee, tax, disc, total;
  final bool mine;
  final DateTime at;
  OStatus status;
  DateTime changed;
  bool auto;
  bool riderControl = false;
  String? rider;
  Order({
    required this.id,
    required this.rid,
    required this.customer,
    required this.address,
    required this.payment,
    required this.code,
    required this.lines,
    required this.sub,
    required this.fee,
    required this.tax,
    required this.disc,
    required this.total,
    required this.mine,
    required this.status,
    required this.at,
    this.auto = true,
    this.note = '',
  }) : changed = at;
  int get items => lines.fold<int>(0, (a, l) => a + l.qty);
  bool get open => status != OStatus.delivered && status != OStatus.rejected;
}

class Approval {
  final String type, name, city;
  String status; // Pending / Approved / Rejected
  Approval(this.type, this.name, this.city, this.status);
}

class Doc {
  final String name;
  String status;
  Doc(this.name, this.status);
}

class Payout {
  final String date;
  final int amount;
  Payout(this.date, this.amount);
}

class Done {
  final String id, rest, dist;
  final int pay;
  Done(this.id, this.rest, this.dist, this.pay);
}

class AppState extends ChangeNotifier {
  // ---- layout ----
  bool fullWidth = false;

  // ---- customer ----
  String name = 'Alex Morgan', email = 'alex@email.com', phone = '0300 1234567';
  final List<Addr> addresses = [Addr('Home', 'Gulberg III, Lahore'), Addr('Work', 'MM Alam Road, Lahore')];
  int addrIdx = 0;
  String payment = 'Cash on delivery';
  final List<String> payments = ['Cash on delivery', 'Card ending 4242', 'Foodie wallet'];
  final List<Line> cart = [];
  String? cartRid;
  String promo = 'WELCOME10';
  String note = '';
  final Set<String> favs = {'r1', 'r2', 'r3'};
  final List<String> recent = ['Chicken burger', 'Biryani'];
  final List<Note> notes = [
    Note('Order update', 'Your food is being prepared', 'order', DateTime.now().subtract(const Duration(minutes: 6))),
    Note('Special offer', '20% off your next order. Use code FOODIE20', 'offer', DateTime.now().subtract(const Duration(hours: 3))),
    Note('Order delivered', 'Enjoy your meal', 'done', DateTime.now().subtract(const Duration(days: 1)), unread: false),
  ];
  bool pushOn = true, offersOn = true;

  // ---- rider ----
  bool riderOnline = true;
  String riderName = 'Ali Raza', riderPhone = '0301 5550199';
  int riderToday = 2450, riderWeek = 14850, riderJobs = 8, riderTips = 1250;
  final List<Done> history = [
    Done('FD-20472', 'Crust & Co.', '3.1 km', 220),
    Done('FD-20450', 'Spice District', '1.8 km', 160),
    Done('FD-20421', 'Cafe Bloom', '2.7 km', 190),
  ];
  final List<Payout> payouts = [Payout('Nov 06, 2026', 2450), Payout('Nov 05, 2026', 1980), Payout('Nov 04, 2026', 2120)];
  final List<Doc> docs = [Doc('Motorcycle details', 'Added'), Doc('Driving licence', 'Verified'), Doc('CNIC', 'Verified'), Doc('Vehicle registration', 'Pending')];

  // ---- owner ----
  String ownerRid = 'r1';
  bool ownerOpen = true, ownerAuto = false;
  int commission = 15;
  int ownerRevenue = 48250, ownerOrdersToday = 128;
  final List<String> menuCats = ['Burgers', 'Sides', 'Drinks', 'Desserts'];
  final List<(String, int, String)> reviews = [
    ('Alex M.', 5, 'Great taste and quick delivery.'),
    ('Sara K.', 4, 'Loved the fries and packaging.'),
    ('Bilal H.', 5, 'Juiciest burger in Gulberg, easily.'),
    ('Hina R.', 4, 'Tasty, just a little late on a busy night.'),
  ];

  // ---- admin ----
  final List<Approval> approvals = [
    Approval('Restaurant', 'Karachi Broast', 'Karachi', 'Pending'),
    Approval('Rider', 'Hassan Malik', 'Lahore', 'Pending'),
    Approval('Restaurant', 'Chai Wala Cafe', 'Islamabad', 'Pending'),
  ];

  // ---- catalogue ----
  final List<Rest> rests = [
    Rest('r1', 'The Burger Lab', 'Smash burgers, made fresh every single day.', '20–30 min', 'Gulberg III', 4.9, 1.2, 650, Art.burger, free: true, offer: true),
    Rest('r2', 'Crust & Co.', 'Stone-baked pizza with a proper crispy crust.', '25–35 min', 'Gulberg II', 4.8, 2.4, 950, Art.pizza, free: true),
    Rest('r3', 'Spice District', 'Desi favourites cooked the traditional way.', '30–40 min', 'MM Alam Road', 4.7, 3.1, 480, Art.biryani, free: false, offer: true),
    Rest('r4', 'Cafe Bloom', 'Coffee, shakes and sweet things all day.', '15–25 min', 'Main Boulevard', 4.6, 1.8, 320, Art.drink, free: true),
  ];
  final List<Food> foods = [
    Food('f1', 'r1', 'Classic smash burger', 'Double smashed beef, cheddar, pickles & house sauce.', 'Burgers', 650, Art.burger),
    Food('f2', 'r1', 'Crispy chicken burger', 'Crunchy fried chicken, slaw and spicy mayo.', 'Burgers', 590, Art.chicken),
    Food('f3', 'r1', 'Loaded masala fries', 'Crisp fries tossed in masala with sauces.', 'Sides', 350, Art.fries),
    Food('f4', 'r1', 'Iced latte', 'Chilled espresso with milk over ice.', 'Drinks', 320, Art.drink),
    Food('f5', 'r1', 'Fudge brownie', 'Warm chocolate brownie with a gooey centre.', 'Desserts', 280, Art.dessert),
    Food('f6', 'r2', 'Pepperoni pizza', 'Stone-baked with mozzarella and pepperoni.', 'Pizza', 1150, Art.pizza),
    Food('f7', 'r2', 'Margherita pizza', 'Tomato, fresh mozzarella and basil.', 'Pizza', 950, Art.pizza),
    Food('f8', 'r2', 'Garlic bread sticks', 'Golden, buttery and loaded with garlic.', 'Sides', 420, Art.fries),
    Food('f9', 'r3', 'Chicken biryani', 'Fragrant basmati rice with tender spiced chicken.', 'Desi', 480, Art.biryani),
    Food('f10', 'r3', 'Chicken karahi', 'Slow-cooked with tomatoes, ginger and green chilli.', 'Desi', 1250, Art.biryani),
    Food('f11', 'r3', 'Hakka noodles', 'Wok-tossed noodles with crunchy vegetables.', 'Chinese', 520, Art.noodles),
    Food('f12', 'r3', 'Chicken manchurian', 'Crispy chicken in a sticky garlic soy sauce.', 'Chinese', 690, Art.noodles),
    Food('f13', 'r4', 'Cold coffee', 'Creamy blended coffee over ice.', 'Drinks', 350, Art.drink),
    Food('f14', 'r4', 'Glazed donut box', 'Six fresh glazed donuts with sprinkles.', 'Desserts', 450, Art.dessert),
    Food('f15', 'r4', 'New York cheesecake', 'Rich and creamy with a buttery biscuit base.', 'Desserts', 520, Art.dessert),
  ];
  final List<Order> orders = [];
  int _seq = 20481;
  Timer? _timer;

  Rest rest(String id) => rests.firstWhere((r) => r.id == id);
  List<Food> menuOf(String rid) => foods.where((f) => f.rid == rid).toList();

  AppState() {
    final f1 = foods[0], f3 = foods[2];
    orders.addAll([
      Order(id: 'FD-20481', rid: 'r1', customer: 'Alex Morgan', address: 'Gulberg III, Lahore', payment: 'Cash on delivery', code: '4821', lines: [Line(f1, 1, []), Line(f3, 1, [])], sub: 1000, fee: 100, tax: 50, disc: 100, total: 1050, mine: true, status: OStatus.preparing, at: DateTime.now().subtract(const Duration(minutes: 6)), auto: false),
      Order(id: 'FD-20479', rid: 'r2', customer: 'Sara K.', address: 'DHA Phase 5, Lahore', payment: 'Card ending 4242', code: '1190', lines: [Line(foods[6], 1, [])], sub: 950, fee: 0, tax: 48, disc: 108, total: 890, mine: false, status: OStatus.delivered, at: DateTime.now().subtract(const Duration(hours: 5)), auto: false),
      Order(id: 'FD-20472', rid: 'r2', customer: 'Alex Morgan', address: 'Gulberg III, Lahore', payment: 'Cash on delivery', code: '7305', lines: [Line(foods[5], 1, [])], sub: 1150, fee: 0, tax: 58, disc: 115, total: 1093, mine: true, status: OStatus.delivered, at: DateTime.now().subtract(const Duration(days: 2)), auto: false),
      Order(id: 'FD-20450', rid: 'r3', customer: 'Alex Morgan', address: 'MM Alam Road, Lahore', payment: 'Cash on delivery', code: '2284', lines: [Line(foods[8], 2, [])], sub: 960, fee: 100, tax: 48, disc: 0, total: 1108, mine: true, status: OStatus.delivered, at: DateTime.now().subtract(const Duration(days: 5)), auto: false),
    ]);
  }

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    var changed = false;
    for (final o in orders) {
      if (!o.auto || !o.open) continue;
      if (now.difference(o.changed).inSeconds < 18) continue;
      // Once a rider takes over, only the rider moves the order past "ready".
      if (o.riderControl && o.status.index >= OStatus.ready.index) continue;
      advance(o, quiet: true);
      changed = true;
    }
    if (changed) notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---------- cart ----------
  int get cartCount => cart.fold<int>(0, (a, l) => a + l.qty);
  int get sub => cart.fold<int>(0, (a, l) => a + l.total);
  int get fee => cart.isEmpty ? 0 : (sub >= 1500 ? 0 : 100);
  int get tax => (sub * 0.05).round();
  int get disc => (sub * (kPromos[promo] ?? 0) / 100).round();
  int get total => cart.isEmpty ? 0 : sub + fee + tax - disc;

  /// Returns false if the cart holds items from another restaurant (pass replace: true to clear it).
  bool addToCart(Food f, int qty, List<String> extras, {bool replace = false}) {
    if (cart.isNotEmpty && cartRid != f.rid) {
      if (!replace) return false;
      cart.clear();
    }
    cartRid = f.rid;
    final key = (List<String>.from(extras)..sort()).join('|');
    for (final l in cart) {
      if (l.food.id == f.id && (List<String>.from(l.extras)..sort()).join('|') == key) {
        l.qty += qty;
        notifyListeners();
        return true;
      }
    }
    cart.add(Line(f, qty, List<String>.from(extras)));
    notifyListeners();
    return true;
  }

  void setQty(Line l, int q) {
    if (q <= 0) {
      cart.remove(l);
      if (cart.isEmpty) cartRid = null;
    } else {
      l.qty = q;
    }
    notifyListeners();
  }

  bool applyPromo(String code) {
    final c = code.trim().toUpperCase();
    if (!kPromos.containsKey(c)) return false;
    promo = c;
    notifyListeners();
    return true;
  }

  void clearPromo() {
    promo = '';
    notifyListeners();
  }

  void reorder(Order o) {
    cart.clear();
    for (final l in o.lines) {
      cart.add(Line(l.food, l.qty, List<String>.from(l.extras)));
    }
    cartRid = o.rid;
    notifyListeners();
  }

  Order placeOrder() {
    _seq += 1;
    final code = (1000 + math.Random().nextInt(9000)).toString();
    final o = Order(
      id: 'FD-$_seq',
      rid: cartRid ?? 'r1',
      customer: name,
      address: addresses.isEmpty ? 'Lahore' : addresses[addrIdx].line,
      payment: payment,
      code: code,
      lines: List<Line>.from(cart),
      sub: sub,
      fee: fee,
      tax: tax,
      disc: disc,
      total: total,
      mine: true,
      status: OStatus.placed,
      at: DateTime.now(),
      note: note,
    );
    orders.insert(0, o);
    if (o.rid == ownerRid) {
      ownerOrdersToday += 1;
      if (ownerAuto) advance(o, quiet: true);
    }
    cart.clear();
    cartRid = null;
    note = '';
    notes.insert(0, Note('Order placed', '${o.id} was sent to ${rest(o.rid).name}', 'order', DateTime.now()));
    notifyListeners();
    return o;
  }

  Order? orderById(String id) {
    for (final o in orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  List<Order> get myOrders => orders.where((o) => o.mine).toList();

  // ---------- order lifecycle ----------
  static const _msgs = {
    OStatus.accepted: 'The restaurant accepted your order',
    OStatus.preparing: 'Your food is being prepared',
    OStatus.ready: 'Your order is ready and waiting for a rider',
    OStatus.pickedUp: 'Your rider picked up the order and is on the way',
    OStatus.delivered: 'Delivered. Enjoy your meal!',
    OStatus.rejected: 'Sorry, the restaurant could not accept your order',
  };

  void advance(Order o, {bool quiet = false}) {
    if (!o.open) return;
    final next = OStatus.values[math.min(o.status.index + 1, OStatus.delivered.index)];
    o.status = next;
    o.changed = DateTime.now();
    if (next == OStatus.pickedUp) o.rider ??= riderName;
    if (next == OStatus.delivered) {
      riderToday += 180;
      riderWeek += 180;
      riderJobs += 1;
      history.insert(0, Done(o.id, rest(o.rid).name, '2.4 km', 180));
      if (o.rid == ownerRid) ownerRevenue += o.total;
    }
    if (o.mine && _msgs.containsKey(next)) {
      notes.insert(0, Note(next == OStatus.delivered ? 'Order delivered' : 'Order update', _msgs[next]!, next == OStatus.delivered ? 'done' : 'order', DateTime.now()));
    }
    if (!quiet) notifyListeners();
  }

  void reject(Order o) {
    o.status = OStatus.rejected;
    o.changed = DateTime.now();
    if (o.mine) notes.insert(0, Note('Order update', _msgs[OStatus.rejected]!, 'order', DateTime.now()));
    notifyListeners();
  }

  /// Orders waiting for a rider.
  List<Order> get requests => orders.where((o) => o.open && !o.riderControl && o.status.index >= OStatus.accepted.index && o.status.index < OStatus.pickedUp.index).toList();
  Order? get activeJob {
    for (final o in orders) {
      if (o.riderControl && o.open) return o;
    }
    return null;
  }

  void acceptJob(Order o) {
    o.riderControl = true;
    o.rider = riderName;
    o.changed = DateTime.now();
    notifyListeners();
  }

  void ping() => notifyListeners();
}

final app = AppState();
