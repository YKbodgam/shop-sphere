import 'domain/product.dart';

class CatalogueState {
  const CatalogueState({
    this.products = const [],
    this.categories = const [],
    this.query = '',
    this.category,
    this.sort,
    this.order = 'asc',
    this.loading = false,
    this.loadingMore = false,
    this.categoriesLoading = false,
    this.error,
    this.categoryError,
    this.total = 0,
  });
  final List<Product> products;
  final List<Category> categories;
  final String query;
  final String? category;
  final String? sort;
  final String order;
  final bool loading, loadingMore, categoriesLoading;
  final String? error, categoryError;
  final int total;
  bool get hasMore => products.length < total;
  CatalogueState copyWith({
    List<Product>? products,
    List<Category>? categories,
    String? query,
    String? category,
    String? sort,
    String? order,
    bool? loading,
    bool? loadingMore,
    bool? categoriesLoading,
    String? error,
    String? categoryError,
    int? total,
    bool clearError = false,
    bool clearCategoryError = false,
  }) => CatalogueState(
    products: products ?? this.products,
    categories: categories ?? this.categories,
    query: query ?? this.query,
    category: category ?? this.category,
    sort: sort ?? this.sort,
    order: order ?? this.order,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    categoriesLoading: categoriesLoading ?? this.categoriesLoading,
    error: clearError ? null : error ?? this.error,
    categoryError: clearCategoryError
        ? null
        : categoryError ?? this.categoryError,
    total: total ?? this.total,
  );
}
