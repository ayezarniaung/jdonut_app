import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:jdonut_app/features/home/data/datasource/product_local_data_source.dart';
import 'package:jdonut_app/features/home/data/models/product_model.dart';

class ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepository(this.localDataSource);

  // Product IDs
  final List<String> _seasonalIds = ['P001', 'P006', 'P008'];

  final List<String> _popularIds = ['P002', 'P004', 'P005'];

  final List<String> _orderAgainIds = ['P005', 'P008'];

  Future<List<ProductModel>> getProducts() {
    return localDataSource.getProducts();
  }

  // Filter products by IDs
  List<ProductModel> _filterProducts(
    List<ProductModel> products,
    List<String> ids,
  ) {
    return products.where((product) => ids.contains(product.id)).toList();
  }

  // Seasonal Specials
  Future<List<ProductModel>> getSeasonalProducts() async {
    final products = await getProducts();

    return _filterProducts(products, _seasonalIds);
  }

  // Popular
  Future<List<ProductModel>> getPopularProducts() async {
    final products = await getProducts();

    return _filterProducts(products, _popularIds);
  }

  // Order Again
  Future<List<ProductModel>> getOrderAgainProducts() async {
    final products = await getProducts();

    return _filterProducts(products, _orderAgainIds);
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String id) {
    return localDataSource.getProductById(id);
  }

  // Seed products
  Future<void> seedProducts() async {
    final count = await localDataSource.getProductCount();

    if (count > 0) return;

    final jsonString = await rootBundle.loadString('assets/json/products.json');

    final List<dynamic> jsonList = jsonDecode(jsonString);

    final products = jsonList
        .map((json) => ProductModel.fromMap(json))
        .toList();

    await localDataSource.insertProducts(products);
  }
}
