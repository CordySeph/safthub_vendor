import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chefship_vendor/features/auth/presentation/providers/auth_provider.dart';

class StoreDetailsScreen extends StatefulWidget {
  const StoreDetailsScreen({super.key});

  @override
  State<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    final restaurant = context.read<AuthProvider>().restaurant;
    _nameController = TextEditingController(text: restaurant?.name);
    _descriptionController = TextEditingController(text: restaurant?.description);
    _phoneController = TextEditingController(text: restaurant?.phoneNumber);
    _addressController = TextEditingController(text: restaurant?.address);
    _categoryController = TextEditingController(text: restaurant?.category);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final messenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.updateStoreDetails({
      'name': _nameController.text,
      'description': _descriptionController.text,
      'phone_number': _phoneController.text,
      'address': _addressController.text,
      'category': _categoryController.text,
    });

    if (success) {
      messenger.showSnackBar(const SnackBar(content: Text('Store details updated successfully')));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(authProvider.error ?? 'Update failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Details'),
        actions: [
          TextButton(
            onPressed: authProvider.isLoading ? null : _handleSave,
            child: const Text('Save', style: TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 16),
            _buildTextField('Store Name', _nameController, Icons.store),
            const SizedBox(height: 16),
            _buildTextField('Category', _categoryController, Icons.category),
            const SizedBox(height: 16),
            _buildTextField('Description', _descriptionController, Icons.description, maxLines: 3),
            const SizedBox(height: 32),
            _buildSectionTitle('Contact Information'),
            const SizedBox(height: 16),
            _buildTextField('Phone Number', _phoneController, Icons.phone, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField('Address', _addressController, Icons.location_on, maxLines: 2),
            const SizedBox(height: 40),
            if (authProvider.isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }
}
