import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chefship_vendor/features/auth/presentation/providers/auth_provider.dart';

class StoreRegistrationScreen extends StatefulWidget {
  const StoreRegistrationScreen({super.key});

  @override
  State<StoreRegistrationScreen> createState() => _StoreRegistrationScreenState();
}

class _StoreRegistrationScreenState extends State<StoreRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _categoryController = TextEditingController();
  
  // For simplicity, using dummy lat/lng, in real app would use a map picker
  final double _lat = 13.736717;
  final double _lng = 100.539800;
  bool _isLocationValid = false;
  String? _locationStatus;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _checkLocation() async {
    final result = await context.read<AuthProvider>().checkStoreLocation(_lat, _lng);
    if (result != null && mounted) {
      setState(() {
        _isLocationValid = result['in_service_zone'] ?? false;
        _locationStatus = result['message'];
      });
    }
  }

  Future<void> _handleRegisterStore() async {
    if (_formKey.currentState!.validate()) {
      if (!_isLocationValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify that your store is in a service zone.')),
        );
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.registerStore({
        'Name': _nameController.text,
        'Address': _addressController.text,
        'PhoneNumber': _phoneController.text,
        'Category': _categoryController.text,
        'Latitude': _lat,
        'Longitude': _lng,
        'PriceRange': '\$\$',
      });

      if (success) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Store submitted for review!')),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Submission failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Your Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Complete Your Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell us about your restaurant to start selling.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter restaurant name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (e.g. Thai, Italian, Cafe)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Full Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) => value!.isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Store Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              const Text(
                'Location Verification',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Coordinates: $_lat, $_lng',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: authProvider.isLoading ? null : _checkLocation,
                    icon: const Icon(Icons.location_on),
                    label: const Text('Verify Service Zone'),
                  ),
                ],
              ),
              if (_locationStatus != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _locationStatus!,
                    style: TextStyle(
                      color: _isLocationValid ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _handleRegisterStore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit for Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
