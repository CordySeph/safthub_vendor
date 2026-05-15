import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';
import '../../data/models/staff_model.dart';

class RoleManagementScreen extends StatelessWidget {
  const RoleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles & Permissions'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => _showAddRoleDialog(context),
          ),
        ],
      ),
      body: staffProvider.isLoading && staffProvider.roles.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: staffProvider.roles.length,
              itemBuilder: (context, index) {
                final role = staffProvider.roles[index];
                return _buildRoleCard(context, role);
              },
            ),
    );
  }

  Widget _buildRoleCard(BuildContext context, StaffRole role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ExpansionTile(
        title: Text(role.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${role.permissions.length} permissions', style: const TextStyle(fontSize: 12)),
        leading: const Icon(LucideIcons.shieldCheck, color: Color(0xFFFF7A00)),
        childrenPadding: const EdgeInsets.all(16),
        expandedAlignment: Alignment.topLeft,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Permissions', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _showEditPermissionsDialog(context, role),
                icon: const Icon(LucideIcons.edit3, size: 14),
                label: const Text('Edit Permissions'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (role.permissions.isEmpty)
            const Text('No permissions assigned', style: TextStyle(color: Colors.grey, fontSize: 13))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: role.permissions.map((p) => _buildPermissionChip(p)).toList(),
            ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showEditRoleNameDialog(context, role),
                child: const Text('Rename'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _showDeleteRoleDialog(context, role),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionChip(StaffPermission p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Text(
        p.name,
        style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showAddRoleDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Role'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Kitchen Staff, Manager'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await context.read<StaffProvider>().createRole(controller.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditRoleNameDialog(BuildContext context, StaffRole role) {
    final controller = TextEditingController(text: role.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Role'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Role Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await context.read<StaffProvider>().updateRole(role.id, controller.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteRoleDialog(BuildContext context, StaffRole role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete "${role.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await context.read<StaffProvider>().deleteRole(role.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditPermissionsDialog(BuildContext context, StaffRole role) {
    final allPermissions = context.read<StaffProvider>().allPermissions;
    final selectedIds = role.permissions.map((p) => p.id).toSet();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Permissions for ${role.name}'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allPermissions.length,
                  itemBuilder: (context, index) {
                    final p = allPermissions[index];
                    final isSelected = selectedIds.contains(p.id);
                    return CheckboxListTile(
                      title: Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text(p.description, style: const TextStyle(fontSize: 12)),
                      value: isSelected,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            selectedIds.add(p.id);
                          } else {
                            selectedIds.remove(p.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    await context.read<StaffProvider>().setRolePermissions(role.id, selectedIds.toList());
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
