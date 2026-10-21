class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final bool isFavorite;
  final double rating;
  final int ratingCount;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isFavorite = false,
    this.rating = 5.0,
    this.ratingCount = 0,
    this.description = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final img = (json['imageUrl'] ?? json['mainImageUrl'] ?? '') as String;

    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'Women',
      imageUrl: img,
      isFavorite: json['isFavorite'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
      'rating': rating,
      'ratingCount': ratingCount,
      'description': description,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    String? imageUrl,
    bool? isFavorite,
    double? rating,
    int? ratingCount,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      description: description ?? this.description,
    );
  }
}
