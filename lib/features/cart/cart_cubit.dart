import 'package:flutter_bloc/flutter_bloc.dart';

import 'cart.dart';

sealed class CartState {
  const CartState(this.items);
  final List<CartItem> items;
  CartTotals get totals => calculateTotals(items);
}

final class CartLoading extends CartState {
  const CartLoading() : super(const []);
}

final class CartReady extends CartState {
  const CartReady(super.items);
}

final class CartFailure extends CartState {
  const CartFailure(super.items, this.message);
  final String message;
}

class CartCubit extends Cubit<CartState> {
  CartCubit(this.store, {required this.userId}) : super(const CartLoading());
  final CartStore store;
  final int userId;

  Future<void> load() async {
    try {
      emit(CartReady(await store.load(userId: userId)));
    } catch (error) {
      emit(CartFailure(state.items, error.toString()));
    }
  }

  Future<void> replace(List<CartItem> items) async {
    try {
      await store.save(items, userId: userId);
      emit(CartReady(List.unmodifiable(items)));
    } catch (error) {
      emit(CartFailure(state.items, error.toString()));
    }
  }

  Future<void> add(CartItem item) async {
    if (item.quantity <= 0 || item.product.stock <= 0) return;
    final next = [...state.items];
    final index = next.indexWhere(
      (entry) => entry.product.id == item.product.id,
    );
    final quantity = index == -1
        ? item.quantity
        : next[index].quantity + item.quantity;
    final bounded = quantity.clamp(1, item.product.stock).toInt();
    if (index == -1) {
      next.add(item.copyWith(quantity: bounded));
    } else {
      next[index] = next[index].copyWith(quantity: bounded);
    }
    await replace(next);
  }

  Future<void> removeAt(int index) async {
    final next = [...state.items]..removeAt(index);
    await replace(next);
  }

  Future<void> setQuantity(int index, int quantity) async {
    if (quantity <= 0) return removeAt(index);
    final next = [...state.items];
    next[index] = next[index].copyWith(
      quantity: quantity.clamp(1, next[index].product.stock).toInt(),
    );
    await replace(next);
  }

  Future<void> clear() async {
    await store.clear(userId: userId);
    emit(const CartReady([]));
  }
}
