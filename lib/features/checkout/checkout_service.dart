import '../products/product_repository.dart';
import '../cart/cart.dart';
import 'domain/order.dart';

class CheckoutService {
  CheckoutService(this.products);

  final ProductRepository products;
  bool _submitting = false;

  Future<Order> submit({
    required int userId,
    required List<CartItem> items,
  }) async {
    if (_submitting) throw StateError('An order is already being submitted.');
    if (items.isEmpty) throw StateError('Your cart is empty.');
    for (final item in items) {
      if (item.quantity <= 0 || item.quantity > item.product.stock) {
        throw StateError('Some item quantities are no longer available.');
      }
    }
    _submitting = true;
    try {
      return Order.fromJson(
        await products.placeOrder(
          userId,
          items
              .map((e) => {'id': e.product.id, 'quantity': e.quantity})
              .toList(),
        ),
      );
    } finally {
      _submitting = false;
    }
  }
}
