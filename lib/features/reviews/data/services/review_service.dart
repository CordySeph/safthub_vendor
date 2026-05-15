import 'package:chefship_vendor/core/api/api_client.dart';
import '../models/review_model.dart';

class ReviewService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ReviewModel>> getReviews() async {
    try {
      // In many systems, this might be /api/vendor/reviews or /api/vendor/my-restaurant/reviews
      final response = await _apiClient.dio.get('/api/vendor/reviews');
      final List data = response.data['data'] ?? response.data ?? [];
      return data.map((json) => ReviewModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> replyToReview(String reviewId, String reply) async {
    try {
      final response = await _apiClient.dio.post('/api/vendor/reviews/$reviewId/reply', data: {
        'reply': reply,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
