import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import 'domain/product.dart';

class ProductPage {
  const ProductPage(this.products, this.total);
  final List<Product> products;
  final int total;
}

abstract interface class ProductDataSource {
  Future<ProductPage> list({
    int skip,
    String? query,
    String? category,
    String? sort,
    String order,
  });
  Future<Product> details(int id);
  Future<List<Category>> categories();
}

class ProductRepository implements ProductDataSource {
  ProductRepository(this.api);
  final ApiClient api;
  @override
  Future<ProductPage> list({
    int skip = 0,
    String? query,
    String? category,
    String? sort,
    String order = 'asc',
  }) async {
    final path = query != null && query.trim().isNotEmpty
        ? '/products/search'
        : category != null && category.isNotEmpty
        ? '/products/category/$category'
        : '/products';
    final r = await api.request(
      () => api.dio.get(
        path,
        queryParameters: {
          'limit': 20,
          'skip': skip,
          if (query != null && query.trim().isNotEmpty) 'q': query,
          'sortBy': ?sort,
          if (sort != null) 'order': order,
        },
      ),
    );
    final data = Map<String, dynamic>.from(r.data);
    return ProductPage(
      (data['products'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      (data['total'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<Product> details(int id) async {
    final r = await api.request(() => api.dio.get('/products/$id'));
    return Product.fromJson(Map<String, dynamic>.from(r.data));
  }

  @override
  Future<List<Category>> categories() async {
    final r = await api.request(() => api.dio.get(Endpoints.categories));
    return (r.data as List? ?? const [])
        .map((entry) {
          if (entry is String) {
            return Category(slug: entry, name: entry.replaceAll('-', ' '));
          }
          if (entry is Map) {
            return Category.fromJson(Map<String, dynamic>.from(entry));
          }
          return null;
        })
        .whereType<Category>()
        .where((category) => category.slug.isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>> placeOrder(
    int userId,
    List<Map<String, int>> products,
  ) async {
    final r = await api.request(
      () => api.dio.post(
        '/carts/add',
        data: {'userId': userId, 'products': products},
      ),
    );
    return Map<String, dynamic>.from(r.data);
  }
}
