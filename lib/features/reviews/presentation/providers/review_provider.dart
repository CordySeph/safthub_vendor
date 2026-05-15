import 'package:flutter/material.dart';
import '../../data/models/review_model.dart';
import '../../data/services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> fetchReviews() async {
    _isLoading = true;
    notifyListeners();

    _reviews = await _reviewService.getReviews();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> reply(String reviewId, String reply) async {
    final success = await _reviewService.replyToReview(reviewId, reply);
    if (success) {
      await fetchReviews();
    }
    return success;
  }
}
