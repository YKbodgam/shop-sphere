import 'cart.dart';

class CartCalculator {
  const CartCalculator._();
  static CartTotals totals(Iterable<CartItem> items) =>
      calculateTotals(items.toList(growable: false));
  static int quantity(Iterable<CartItem> items) =>
      items.fold(0, (sum, item) => sum + item.quantity);
  static bool canAdd(CartItem item, int requested) =>
      requested > 0 && item.product.stock >= requested;
}
