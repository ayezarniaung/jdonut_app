import 'package:jdonut_app/core/database/app_database.dart';
import 'package:jdonut_app/features/home/data/models/shop_model.dart';
import 'package:sqflite/sqflite.dart';

class ShopLocalDataSource {
  final AppDatabase database;

  ShopLocalDataSource(this.database);

  Future<List<ShopModel>> getShops() async {
    final db = await database.database;

    final result = await db.query('shops', orderBy: 'id ASC');

    return result.map((json) {
      return ShopModel.fromJson(json);
    }).toList();
  }

  Future<ShopModel?> getShopById(String id) async {
    final db = await database.database;

    final result = await db.query(
      'shops',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return ShopModel.fromJson(result.first);
  }

  Future<void> insertShops(List<ShopModel> shops) async {
    final db = await database.database;

    final batch = db.batch();

    for (final shop in shops) {
      batch.insert(
        'shops',
        shop.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<bool> hasShops() async {
    final db = await database.database;

    final result = await db.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM shops) AS hasData',
    );

    return (result.first['hasData'] as int) == 1;
  }
}
