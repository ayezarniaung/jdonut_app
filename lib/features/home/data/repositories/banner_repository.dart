import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:jdonut_app/features/home/data/datasource/banner_local_data_source.dart';
import 'package:jdonut_app/features/home/data/models/banner_model.dart';

class BannerRepository {
  final BannerLocalDataSource localDataSource;

  BannerRepository(this.localDataSource);

  Future<List<BannerModel>> getBanners() async {
    return await localDataSource.getBanners();
  }

  Future<BannerModel?> getBannerById(String id) async {
    return await localDataSource.getBannerById(id);
  }

  Future<void> insertBanners(List<BannerModel> banners) async {
    await localDataSource.insertBanners(banners);
  }

  // Seed JSON only when the local database is empty.
  Future<void> seedBanners() async {
    final existingBanners = await localDataSource.getBanners();

    if (existingBanners.isNotEmpty) return;

    final jsonString = await rootBundle.loadString('assets/json/banners.json');

    final List<dynamic> jsonData = jsonDecode(jsonString);

    final banners = jsonData.map((item) => BannerModel.fromJson(item)).toList();

    await localDataSource.insertBanners(banners);
  }
}
