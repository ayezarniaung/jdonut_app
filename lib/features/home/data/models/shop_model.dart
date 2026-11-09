class ShopModel {
  final String id;
  final String name;
  final String address;
  final String imageUrl;

  const ShopModel({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'address': address, 'imageUrl': imageUrl};
  }
}
