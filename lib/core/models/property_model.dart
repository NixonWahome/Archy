/// Property model for real estate listings
class PropertyModel {
  final String id;
  final String title;
  final String description;
  final String address;
  final double price;
  final String imageUrl;
  final List<String> images;
  final int bedrooms;
  final int bathrooms;
  final double squareFeet;
  final String propertyType; // 'house', 'apartment', 'villa', 'land'
  final String status; // 'available', 'sold', 'pending'
  final String developerId;
  final String developerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.price,
    required this.imageUrl,
    required this.images,
    required this.bedrooms,
    required this.bathrooms,
    required this.squareFeet,
    required this.propertyType,
    required this.status,
    required this.developerId,
    required this.developerName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PropertyModel.fromMap(Map<String, dynamic> map) {
    return PropertyModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      bedrooms: map['bedrooms'] ?? 0,
      bathrooms: map['bathrooms'] ?? 0,
      squareFeet: (map['squareFeet'] ?? 0).toDouble(),
      propertyType: map['propertyType'] ?? 'house',
      status: map['status'] ?? 'available',
      developerId: map['developerId'] ?? '',
      developerName: map['developerName'] ?? '',
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'address': address,
      'price': price,
      'imageUrl': imageUrl,
      'images': images,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'squareFeet': squareFeet,
      'propertyType': propertyType,
      'status': status,
      'developerId': developerId,
      'developerName': developerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
