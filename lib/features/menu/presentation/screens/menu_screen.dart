import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:chefship_vendor/features/menu/presentation/providers/menu_provider.dart';
import 'package:chefship_vendor/features/menu/data/models/menu_item_model.dart';
import 'package:chefship_vendor/features/menu/presentation/screens/add_menu_item_screen.dart';
import 'package:chefship_vendor/features/menu/presentation/screens/edit_menu_item_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String selectedCategoryId = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: Color(0xFFFF7A00)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMenuItemScreen()),
              );
            },
          ),
        ],
      ),
      body: menuProvider.isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00)))
        : Column(
            children: [
              _buildCategorySelector(menuProvider.categories),
              Expanded(
                child: _buildProductList(menuProvider.menuItems),
              ),
            ],
          ),
    );
  }

  Widget _buildCategorySelector(List<CategoryModel> categories) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: () => setState(() => selectedCategoryId = 'All'),
              child: _buildCategoryChip('All', selectedCategoryId == 'All'),
            );
          }
          if (index == categories.length + 1) {
            return GestureDetector(
              onTap: _showAddCategoryDialog,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(LucideIcons.plus, size: 16, color: Colors.white),
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategoryId == category.id;
          return GestureDetector(
            onTap: () => setState(() => selectedCategoryId = category.id),
            child: _buildCategoryChip(category.name, isSelected),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected || Theme.of(context).brightness == Brightness.dark ? null : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Category Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await context.read<MenuProvider>().createCategory(controller.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<MenuItemModel> items) {
    final filteredItems = selectedCategoryId == 'All' 
      ? items 
      : items.where((i) => i.categoryId != null && i.categoryId == selectedCategoryId).toList();

    if (filteredItems.isEmpty) {
      return const Center(
        child: Text('No items in this category', style: TextStyle(color: Color(0xFF666666))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final product = filteredItems[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditMenuItemScreen(product: product)),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: Theme.of(context).brightness == Brightness.dark ? null : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.image, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '฿${product.price}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch(
                      value: product.isAvailable,
                      activeTrackColor: const Color(0xFFFF7A00),
                      activeThumbColor: Colors.white,
                      onChanged: (value) {},
                    ),
                    const Text('Available', style: TextStyle(fontSize: 10, color: Color(0xFF666666))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
