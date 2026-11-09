import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:jdonut_app/features/home/data/datasource/shop_local_data_source.dart';
import 'package:jdonut_app/features/home/data/models/shop_model.dart';

class ShopRepository {
  final ShopLocalDataSource localDataSource;

  ShopRepository(this.localDataSource);

  Future<List<ShopModel>> getShops() {
    return localDataSource.getShops();
  }

  Future<ShopModel?> getShopById(String id) {
    return localDataSource.getShopById(id);
  }

  Future<void> seedShops() async {
    final hasData = await localDataSource.hasShops();

    if (hasData) return;

    final jsonString = await rootBundle.loadString('assets/json/shops.json');

    final List<dynamic> jsonList = jsonDecode(jsonString);

    final shops = jsonList.map((json) {
      return ShopModel.fromJson(json);
    }).toList();

    await localDataSource.insertShops(shops);
  }
}
