import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chefship_vendor/features/auth/presentation/providers/auth_provider.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.hourglass_empty,
              size: 80,
              color: Color(0xFFFF7A00),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pending Approval',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your restaurant application has been submitted and is currently being reviewed by our administrators. This usually takes 1-2 business days.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.read<AuthProvider>().loadUser(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Refresh Status'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {}, // Could link to support
              child: const Text('Contact Support'),
            ),
          ],
        ),
      ),
    );
  }
}
