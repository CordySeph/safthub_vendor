import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';
import '../../data/models/staff_model.dart';
import 'add_edit_staff_screen.dart';
import 'role_management_screen.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.shield),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RoleManagementScreen()),
            ),
            tooltip: 'Roles & Permissions',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => staffProvider.loadData(),
        color: const Color(0xFFFF7A00),
        child: staffProvider.isLoading && staffProvider.staffList.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00)))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader('Store Staff', '${staffProvider.staffList.length} members'),
                  const SizedBox(height: 16),
                  if (staffProvider.staffList.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 64),
                        child: Text('No staff members found', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ...staffProvider.staffList.map((staff) => _buildStaffCard(staff)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditStaffScreen()),
        ),
        backgroundColor: const Color(0xFFFF7A00),
        child: const Icon(LucideIcons.userPlus, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildStaffCard(StaffMember staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFF7A00).withValues(alpha: 0.1),
          child: const Icon(LucideIcons.user, color: Color(0xFFFF7A00)),
        ),
        title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(staff.email, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                staff.roleName ?? 'No Role',
                style: const TextStyle(color: Color(0xFFFF7A00), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditStaffScreen(staff: staff)),
              );
            } else if (value == 'delete') {
              _showDeleteConfirmation(staff);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(StaffMember staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Staff'),
        content: Text('Are you sure you want to remove ${staff.name} from your store?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final staffProvider = context.read<StaffProvider>();
              Navigator.pop(context);
              final success = await staffProvider.deleteStaff(staff.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(success ? 'Staff removed successfully' : 'Failed to remove staff')),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
