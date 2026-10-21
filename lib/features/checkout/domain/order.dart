import 'package:equatable/equatable.dart';

class Order extends Equatable {
  const Order({required this.id, required this.total, required this.totalProducts, required this.totalQuantity});
  final int id;
  final double total;
  final int totalProducts;
  final int totalQuantity;
  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: (json['id'] as num?)?.toInt() ?? 0,
    total: (json['total'] as num?)?.toDouble() ?? 0,
    totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
    totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
  );
  Map<String, dynamic> toJson() => {'id': id, 'total': total, 'totalProducts': totalProducts, 'totalQuantity': totalQuantity};
  @override List<Object?> get props => [id, total, totalProducts, totalQuantity];
}
