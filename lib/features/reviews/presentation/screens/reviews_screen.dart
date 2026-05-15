import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/review_provider.dart';
import '../../data/models/review_model.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().fetchReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Reviews'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => reviewProvider.fetchReviews(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => reviewProvider.fetchReviews(),
        color: const Color(0xFFFF7A00),
        child: reviewProvider.isLoading && reviewProvider.reviews.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00)))
            : reviewProvider.reviews.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reviewProvider.reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviewProvider.reviews[index];
                      return _buildReviewCard(review);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.messageSquare, size: 64, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text('No reviews yet', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                child: Text(
                  review.userName?.isNotEmpty == true ? review.userName![0].toUpperCase() : 'C',
                  style: const TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName ?? 'Customer', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      _formatDate(review.createdAt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              _buildRatingStars(review.rating),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment, style: const TextStyle(fontSize: 14)),
          if (review.reply != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A00).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.reply, size: 14, color: Color(0xFFFF7A00)),
                      SizedBox(width: 4),
                      Text('Your Reply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(review.reply!, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showReplyDialog(review),
                icon: const Icon(LucideIcons.messageSquare, size: 16),
                label: const Text('Reply'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF7A00)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showReplyDialog(ReviewModel review) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To: ${review.userName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('"${review.comment}"', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type your reply...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                
                final success = await context.read<ReviewProvider>().reply(review.id, controller.text);
                
                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text(success ? 'Reply posted' : 'Failed to post reply')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00)),
            child: const Text('Post Reply'),
          ),
        ],
      ),
    );
  }
}
