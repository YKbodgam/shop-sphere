import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({required this.id, required this.title, required this.description, required this.category, required this.price, required this.discountPercentage, required this.rating, required this.stock, this.brand, required this.thumbnail, required this.images, this.reviews = const []});
  final int id; final String title; final String description; final String category; final double price; final double discountPercentage; final double rating; final int stock; final String? brand; final String thumbnail; final List<String> images; final List<Review> reviews;
  double get originalPrice => price / (1 - discountPercentage / 100);
  bool get inStock => stock > 0;
  factory Product.fromJson(Map<String, dynamic> json) => Product(id: (json['id'] as num).toInt(), title: json['title'] as String? ?? 'Untitled product', description: json['description'] as String? ?? '', category: json['category'] as String? ?? '', price: (json['price'] as num?)?.toDouble() ?? 0, discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0, rating: (json['rating'] as num?)?.toDouble() ?? 0, stock: (json['stock'] as num?)?.toInt() ?? 0, brand: json['brand'] as String?, thumbnail: json['thumbnail'] as String? ?? '', images: (json['images'] as List? ?? const []).whereType<String>().toList(), reviews: (json['reviews'] as List? ?? const []).whereType<Map>().map((e) => Review.fromJson(Map<String, dynamic>.from(e))).toList());
  @override List<Object?> get props => [id, title, price, stock];
}
class Review { const Review({required this.rating, required this.comment, required this.reviewerName}); final int rating; final String comment; final String reviewerName; factory Review.fromJson(Map<String,dynamic> j) => Review(rating: (j['rating'] as num?)?.toInt() ?? 0, comment: j['comment'] as String? ?? '', reviewerName: j['reviewerName'] as String? ?? 'Customer'); }
class Category { const Category({required this.slug, required this.name}); final String slug; final String name; factory Category.fromJson(Map<String,dynamic> j) => Category(slug: j['slug'] as String? ?? '', name: j['name'] as String? ?? j['slug'] as String? ?? ''); }
