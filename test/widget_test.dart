import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopsphere/main.dart';
import 'package:shopsphere/features/products/domain/product.dart';

void main() {
  testWidgets('out-of-stock product disables add to cart', (
    WidgetTester tester,
  ) async {
    const product = Product(
      id: 1,
      title: 'Unavailable product',
      description: 'Description',
      category: 'category',
      price: 10,
      discountPercentage: 5,
      rating: 4,
      stock: 0,
      thumbnail: '',
      images: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(product: product, onTap: () {}, onAdd: null),
        ),
      ),
    );

    final addButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(addButton.onPressed, isNull);
  });
}
