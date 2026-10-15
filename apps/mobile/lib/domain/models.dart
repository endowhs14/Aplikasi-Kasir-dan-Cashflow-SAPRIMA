import 'money.dart';

typedef Json = Map<String, Object?>;

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.unit,
    required this.price,
    required this.service,
    required this.stock,
    required this.version,
  });
  final String id, name, sku, category, unit;
  final int price, stock, version;
  final bool service;
  factory Product.fromMap(Json m) => Product(
    id: m['id'] as String,
    name: m['name'] as String,
    sku: m['sku'] as String,
    category: m['category'] as String,
    unit: m['unit'] as String,
    price: m['price'] as int,
    service: m['service'] == 1,
    stock: m['stock'] as int,
    version: m['version'] as int,
  );
  Json toMap() => {
    'id': id,
    'name': name,
    'sku': sku,
    'category': category,
    'unit': unit,
    'price': price,
    'service': service ? 1 : 0,
    'stock': stock,
    'version': version,
  };
}

class CartLine {
  const CartLine(this.product, this.quantity);
  final Product product;
  final int quantity;
  int get total => lineTotal(product.price, quantity);
  Json toMap() => {'product': product.toMap(), 'quantity': quantity};
  factory CartLine.fromMap(Json m) => CartLine(
    Product.fromMap(Map<String, Object?>.from(m['product'] as Map)),
    m['quantity'] as int,
  );
}

class Sale {
  const Sale(this.data, this.items);
  final Json data;
  final List<Json> items;
  String get id => data['id'] as String;
  String get number => data['receipt'] as String;
  int get total => data['total'] as int;
  String get occurredAt => data['occurred_at'] as String;
}
