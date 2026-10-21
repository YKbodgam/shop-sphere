import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'domain/product.dart';
import 'product_repository.dart';

class ProductState {
  const ProductState({
    this.products = const [],
    this.categories = const [],
    this.loading = false,
    this.loadingMore = false,
    this.categoriesLoading = false,
    this.error,
    this.total = 0,
    this.query = '',
    this.category,
    this.sort,
    this.order = 'asc',
  });
  final List<Product> products;
  final List<Category> categories;
  final bool loading, loadingMore, categoriesLoading;
  final String? error;
  final int total;
  final String query;
  final String? category;
  final String? sort;
  final String order;
  ProductState copyWith({
    List<Product>? products,
    List<Category>? categories,
    bool? loading,
    bool? loadingMore,
    bool? categoriesLoading,
    String? error,
    int? total,
    String? query,
    String? category,
    bool clearError = false,
    String? sort,
    String? order,
  }) => ProductState(
    products: products ?? this.products,
    categories: categories ?? this.categories,
    loading: loading ?? this.loading,
    categoriesLoading: categoriesLoading ?? this.categoriesLoading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: clearError ? null : error ?? this.error,
    total: total ?? this.total,
    query: query ?? this.query,
    category: category ?? this.category,
    sort: sort ?? this.sort,
    order: order ?? this.order,
  );
}

class ProductCubit extends Cubit<ProductState> {
  ProductCubit(this.repo) : super(const ProductState());
  final ProductRepository repo;
  Timer? _debounce;
  int _requestId = 0;

  bool get hasMore => state.products.length < state.total;
  Future<void> loadCategories() async {
    emit(state.copyWith(categoriesLoading: true));
    try {
      emit(
        state.copyWith(
          categories: await repo.categories(),
          categoriesLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(categoriesLoading: false));
    }
  }

  Future<void> load({bool refresh = false}) async {
    if (state.loading || state.loadingMore) return;
    final requestId = ++_requestId;
    final offset = refresh ? 0 : state.products.length;
    if (!refresh && !hasMore && state.products.isNotEmpty) return;
    emit(
      state.copyWith(
        products: refresh ? const [] : null,
        loading: refresh || state.products.isEmpty,
        loadingMore: !refresh && state.products.isNotEmpty,
        clearError: true,
      ),
    );
    try {
      final page = await repo.list(
        skip: offset,
        query: state.query,
        category: state.category,
        sort: state.sort,
        order: state.order,
      );
      if (requestId != _requestId || isClosed) return;
      final existing = refresh ? const <Product>[] : state.products;
      final ids = existing.map((product) => product.id).toSet();
      final merged = [
        ...existing,
        ...page.products.where((product) => !ids.contains(product.id)),
      ];
      emit(
        state.copyWith(
          products: merged,
          total: page.total,
          loading: false,
          loadingMore: false,
          clearError: true,
        ),
      );
    } catch (error) {
      if (requestId != _requestId || isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          loadingMore: false,
          error: 'Unable to load products. Please try again.',
        ),
      );
    }
  }

  void search(String value) {
    _debounce?.cancel();
    final query = value.trim();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      emit(state.copyWith(query: query));
      load(refresh: true);
    });
  }

  void selectCategory(String? value) {
    emit(state.copyWith(category: value));
    load(refresh: true);
  }

  void setSort(String? sort, String order) {
    emit(state.copyWith(sort: sort, order: order));
    load(refresh: true);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
