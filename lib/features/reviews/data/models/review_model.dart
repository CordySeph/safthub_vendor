class ReviewModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userProfilePicture;
  final double rating;
  final String comment;
  final String? reply;
  final DateTime? repliedAt;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userProfilePicture,
    required this.rating,
    required this.comment,
    this.reply,
    this.repliedAt,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? json['ID'] ?? '',
      userId: json['user_id'] ?? json['UserID'] ?? '',
      userName: json['user_name'] ?? json['UserName'] ?? 'Customer',
      userProfilePicture: json['user_profile_picture'],
      rating: (json['rating'] ?? json['Rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? json['Comment'] ?? '',
      reply: json['reply'] ?? json['Reply'],
      repliedAt: json['replied_at'] != null ? DateTime.parse(json['replied_at']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? json['CreatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
