class RestaurantModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String address;
  final String status;
  final bool isTemporarilyClosed;
  final double rating;
  final String? logoUrl;
  final String? coverPhotoUrl;

  RestaurantModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.status,
    required this.isTemporarilyClosed,
    required this.rating,
    this.logoUrl,
    this.coverPhotoUrl,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['ID'] ?? json['id'] ?? '',
      ownerId: json['OwnerID'] ?? json['owner_id'] ?? '',
      name: json['Name'] ?? json['name'] ?? '',
      description: json['Description'] ?? json['description'] ?? '',
      address: json['Address'] ?? json['address'] ?? '',
      status: json['Status'] ?? json['status'] ?? '',
      isTemporarilyClosed: json['IsTemporarilyClosed'] ?? json['is_temporarily_closed'] ?? false,
      rating: (json['Rating'] ?? json['rating'] ?? 0).toDouble(),
      logoUrl: json['LogoURL'] ?? json['logo_url'],
      coverPhotoUrl: json['CoverPhotoURL'] ?? json['cover_photo_url'],
    );
  }
}
