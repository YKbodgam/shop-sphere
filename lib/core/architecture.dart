/// Production integration points for the ShopSphere feature modules.
///
/// Data: Dio client + typed DummyJSON DTOs + secure token/cart data sources.
/// Domain: Product, CartItem, CartSummary entities and repository contracts.
/// Presentation: Cubits expose loading, success, empty and failure states.
/// The sample shell keeps the target visual language small and easy to integrate.
abstract final class ApiConfig {
  static const baseUrl = 'https://dummyjson.com';
  static const pageSize = 20;
  static const searchDebounce = Duration(milliseconds: 400);
}
