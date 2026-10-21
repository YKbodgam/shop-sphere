import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/failure.dart';
import '../products/domain/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});
  final Product product;
  final int quantity;
  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);
  Map<String, dynamic> toJson() => {
    'product': {
      'id': product.id,
      'title': product.title,
      'price': product.price,
      'discountPercentage': product.discountPercentage,
      'thumbnail': product.thumbnail,
      'stock': product.stock,
      'category': product.category,
      'description': product.description,
      'rating': product.rating,
      'images': product.images,
    },
    'quantity': quantity,
  };
  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
    product: Product.fromJson(Map<String, dynamic>.from(j['product'] as Map)),
    quantity: (j['quantity'] as num).toInt(),
  );
  @override
  List<Object?> get props => [product.id, quantity];
}

class CartStore {
  CartStore(this.prefs);
  final SharedPreferences prefs;
  String _key(int? userId) => 'shopsphere_cart_${userId ?? 0}';
  Future<List<CartItem>> load({int? userId}) async {
    try {
      final raw = prefs.getString(_key(userId));
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      throw const StorageFailure(
        'We could not restore your cart. Please try again.',
      );
    }
  }

  Future<void> save(List<CartItem> items, {int? userId}) async {
    try {
      final saved = await prefs.setString(
        _key(userId),
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );
      if (!saved) throw const StorageFailure();
    } catch (error) {
      if (error is StorageFailure) rethrow;
      throw const StorageFailure();
    }
  }

  Future<void> clear({int? userId}) async {
    try {
      final removed = await prefs.remove(_key(userId));
      if (!removed && prefs.containsKey(_key(userId))) {
        throw const StorageFailure();
      }
    } catch (error) {
      if (error is StorageFailure) rethrow;
      throw const StorageFailure();
    }
  }
}

class CartTotals {
  const CartTotals(this.subtotal, this.discount, this.total);
  final double subtotal, discount, total;
}

CartTotals calculateTotals(List<CartItem> items) {
  var subtotal = 0.0, discount = 0.0;
  for (final item in items) {
    final current = item.product.price * item.quantity;
    final original = item.product.originalPrice * item.quantity;
    subtotal += original;
    discount += original - current;
  }
  return CartTotals(subtotal, discount, subtotal - discount);
}
