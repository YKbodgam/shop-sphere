import '../product_repository.dart';
import 'product.dart';

class LoadProducts {
  const LoadProducts(this.repository);
  final ProductRepository repository;
  Future<ProductPage> call({
    int skip = 0,
    String? query,
    String? category,
    String? sort,
    String order = 'asc',
  }) => repository.list(
    skip: skip,
    query: query,
    category: category,
    sort: sort,
    order: order,
  );
}

class LoadProductDetails {
  const LoadProductDetails(this.repository);
  final ProductRepository repository;
  Future<Product> call(int id) => repository.details(id);
}
