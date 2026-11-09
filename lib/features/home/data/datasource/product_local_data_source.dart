import 'package:jdonut_app/core/database/app_database.dart';
import 'package:jdonut_app/features/home/data/models/product_model.dart';
import 'package:sqflite/sqflite.dart';

class ProductLocalDataSource {
  final AppDatabase database;

  ProductLocalDataSource(this.database);

  Future<void> insertProducts(List<ProductModel> products) async {
    final db = await database.database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final product in products) {
        batch.insert(
          'products',
          product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await database.database;

    final result = await db.query('products', orderBy: 'name ASC');

    return result.map((map) => ProductModel.fromMap(map)).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    final db = await database.database;

    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ProductModel.fromMap(result.first);
  }

  Future<int> getProductCount() async {
    final db = await database.database;

    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await database.database;

    return db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(String id) async {
    final db = await database.database;

    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllProducts() async {
    final db = await database.database;

    await db.delete('products');
  }
}
