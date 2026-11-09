import 'package:flutter_test/flutter_test.dart';

import 'dart:convert';

import 'package:jdonut_app/features/home/data/models/product_model.dart';
import 'package:jdonut_app/core/utils/app_logger.dart';

void main() {
  test('json test -> seed', () {
    const text = '''
{
  "id": "p_coconut",
  "code": "JD022123",
  "name": "Coconut Donut",
  "priceMmk": 3200,
  "isNew": true,
  "discountPercent": null,
  "description": "Enjoy our scrumptious donuts.",
  "imageUrl": "https://example.com/coconut.png"
}
''';

    final product = ProductModel.fromJson(jsonDecode(text));
    logger.w(product.name); // Coconut Donut
    logger.w(product.priceMmk); // 3200
    logger.w(product.discountPercent); // null
  });
}
