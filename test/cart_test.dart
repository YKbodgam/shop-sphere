import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shopsphere/features/cart/cart.dart';
import 'package:shopsphere/features/cart/cart_cubit.dart';
import 'package:shopsphere/features/products/domain/product.dart';
import 'package:shopsphere/core/errors/failure.dart';

Product product({
  int id = 1,
  double price = 80,
  double discount = 20,
  int stock = 5,
}) {
  return Product(
    id: id,
    title: 'Product $id',
    description: 'Description',
    category: 'category',
    price: price,
    discountPercentage: discount,
    rating: 4.5,
    stock: stock,
    thumbnail: 'https://example.com/image.png',
    images: const [],
  );
}

void main() {
  group('cart calculations', () {
    test('calculates subtotal, discount, and total for multiple items', () {
      final totals = calculateTotals([
        CartItem(product: product(), quantity: 2),
        CartItem(product: product(id: 2, price: 50, discount: 10), quantity: 1),
      ]);

      expect(totals.subtotal, 250);
      expect(totals.discount, 50);
      expect(totals.total, 200);
    });

    test('merges an existing product and caps quantity at stock', () async {
      SharedPreferences.setMockInitialValues({});
      final store = CartStore(await SharedPreferences.getInstance());
      final cubit = CartCubit(store, userId: 7);
      await cubit.add(CartItem(product: product(stock: 3), quantity: 2));
      await cubit.add(CartItem(product: product(stock: 3), quantity: 2));

      expect(cubit.state.items, hasLength(1));
      expect(cubit.state.items.single.quantity, 3);
    });

    test('decreasing quantity from one removes the cart line', () async {
      SharedPreferences.setMockInitialValues({});
      final store = CartStore(await SharedPreferences.getInstance());
      final cubit = CartCubit(store, userId: 7);
      await cubit.add(CartItem(product: product(), quantity: 1));
      await cubit.setQuantity(0, 0);

      expect(cubit.state.items, isEmpty);
    });
  });

  group('cart persistence', () {
    test('keeps carts isolated by user id', () async {
      SharedPreferences.setMockInitialValues({});
      final store = CartStore(await SharedPreferences.getInstance());
      final item = CartItem(product: product(), quantity: 1);
      await store.save([item], userId: 10);

      expect(await store.load(userId: 10), hasLength(1));
      expect(await store.load(userId: 11), isEmpty);
    });

    test('reports malformed persisted data as a storage failure', () async {
      SharedPreferences.setMockInitialValues({'shopsphere_cart_10': '{bad'});
      final store = CartStore(await SharedPreferences.getInstance());

      expect(store.load(userId: 10), throwsA(isA<StorageFailure>()));
    });
  });
}
