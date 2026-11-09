class ProductModel {
  final String id;
  final String code;
  final String name;
  final int priceMmk;
  final bool isNew;
  final int? discountPercent;
  final String description;
  final String imageUrl;

  const ProductModel({
    required this.id,
    required this.code,
    required this.name,
    required this.priceMmk,
    required this.isNew,
    required this.discountPercent,
    required this.description,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      priceMmk: json['priceMmk'] as int,
      isNew: json['isNew'] as bool,
      discountPercent: json['discountPercent'] as int?,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'priceMmk': priceMmk,
    'isNew': isNew,
    'discountPercent': discountPercent,
    'description': description,
    'imageUrl': imageUrl,
  };

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      priceMmk: map['priceMmk'],
      isNew: map['isNew'] == 1,
      discountPercent: map['discountPercent'],
      description: map['description'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'priceMmk': priceMmk,
      'isNew': isNew ? 1 : 0,
      'discountPercent': discountPercent,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
