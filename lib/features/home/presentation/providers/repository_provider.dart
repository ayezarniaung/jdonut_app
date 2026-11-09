import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut_app/core/database/app_database.dart';
import 'package:jdonut_app/features/home/data/datasource/banner_local_data_source.dart';
import 'package:jdonut_app/features/home/data/datasource/product_local_data_source.dart';
import 'package:jdonut_app/features/home/data/datasource/shop_local_data_source.dart';
import 'package:jdonut_app/features/home/data/repositories/product_repository.dart';
import 'package:jdonut_app/features/home/data/repositories/banner_repository.dart';
import 'package:jdonut_app/features/home/data/repositories/shop_repository.dart';

// Database
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

// Product
final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  return ProductLocalDataSource(ref.read(databaseProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.read(productLocalDataSourceProvider));
});

// Banner
final bannerLocalDataSourceProvider = Provider<BannerLocalDataSource>((ref) {
  return BannerLocalDataSource(ref.read(databaseProvider));
});

final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  return BannerRepository(ref.read(bannerLocalDataSourceProvider));
});

// Shop Local Data Source
final shopLocalDataSourceProvider = Provider<ShopLocalDataSource>((ref) {
  return ShopLocalDataSource(ref.read(databaseProvider));
});

// Shop Repository
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository(ref.read(shopLocalDataSourceProvider));
});
