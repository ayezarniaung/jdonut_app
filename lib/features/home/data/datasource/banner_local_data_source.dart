import 'package:jdonut_app/core/database/app_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:jdonut_app/features/home/data/models/banner_model.dart';

class BannerLocalDataSource {
  final AppDatabase database;

  BannerLocalDataSource(this.database);

  Future<List<BannerModel>> getBanners() async {
    final db = await database.database;
    final result = await db.query(
      'banners',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'sortOrder ASC',
    );

    return result.map((row) {
      return BannerModel.fromJson({...row, 'isPopular': row['isPopular'] == 1});
    }).toList();
  }

  Future<BannerModel?> getBannerById(String id) async {
    final db = await database.database;
    final result = await db.query(
      'banners',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final row = result.first;

    return BannerModel.fromJson({...row, 'isPopular': row['isPopular'] == 1});
  }

  Future<void> insertBanners(List<BannerModel> banners) async {
    final db = await database.database;
    final batch = db.batch();

    for (final banner in banners) {
      batch.insert('banners', {
        'id': banner.id,
        'imageUrl': banner.imageUrl,
        'isPopular': banner.isPopular ? 1 : 0,
        'productId': banner.productId,
        'isActive': 1,
        'sortOrder': banners.indexOf(banner),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }
}
