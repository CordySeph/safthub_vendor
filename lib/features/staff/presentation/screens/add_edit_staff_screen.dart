import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_provider.dart';
import '../../data/models/staff_model.dart';

class AddEditStaffScreen extends StatefulWidget {
  final StaffMember? staff;
  const AddEditStaffScreen({super.key, this.staff});

  @override
  State<AddEditStaffScreen> createState() => _AddEditStaffScreenState();
}

class _AddEditStaffScreenState extends State<AddEditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _selectedRoleId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff?.name);
    _emailController = TextEditingController(text: widget.staff?.email);
    _passwordController = TextEditingController();
    _selectedRoleId = widget.staff?.roleId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final isEdit = widget.staff != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Staff' : 'Add New Staff')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
              enabled: !isEdit,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            if (!isEdit) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: staffProvider.roles.any((r) => r.id == _selectedRoleId) ? _selectedRoleId : null,
              decoration: const InputDecoration(labelText: 'Role'),
              items: staffProvider.roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
              onChanged: (v) => setState(() => _selectedRoleId = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: staffProvider.isLoading ? null : () async {
                if (_formKey.currentState!.validate()) {
                  bool success;
                  if (isEdit) {
                    success = await staffProvider.updateStaff(
                      widget.staff!.id,
                      name: _nameController.text,
                      roleId: _selectedRoleId,
                    );
                  } else {
                    success = await staffProvider.createStaff(
                      _nameController.text,
                      _emailController.text,
                      _passwordController.text,
                      _selectedRoleId!,
                    );
                  }

                  if (!mounted) return;
                  if (success) {
                    Navigator.pop(context);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'Staff updated' : 'Staff added')),
                    );
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Operation failed')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: staffProvider.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isEdit ? 'Save Changes' : 'Add Staff'),
            ),
          ],
        ),
      ),
    );
  }
}
