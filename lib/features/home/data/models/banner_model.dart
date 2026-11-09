class BannerModel {
  final String id;
  final String imageUrl;
  final bool isPopular;
  final String productId;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    required this.productId,
    this.isPopular = false,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      productId: json['productId'] as String,
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'productId': productId,
      'isPopular': isPopular,
    };
  }
}
