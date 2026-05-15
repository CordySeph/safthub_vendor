import 'package:flutter/material.dart';
import '../../data/models/staff_model.dart';
import '../../data/services/staff_service.dart';

class StaffProvider extends ChangeNotifier {
  final StaffService _staffService = StaffService();

  List<StaffMember> _staffList = [];
  List<StaffRole> _roles = [];
  List<StaffPermission> _allPermissions = [];
  bool _isLoading = false;

  List<StaffMember> get staffList => _staffList;
  List<StaffRole> get roles => _roles;
  List<StaffPermission> get allPermissions => _allPermissions;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      fetchStaff(),
      fetchRoles(),
      fetchPermissions(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStaff() async {
    _staffList = await _staffService.getStaff();
    notifyListeners();
  }

  Future<void> fetchRoles() async {
    _roles = await _staffService.getRoles();
    notifyListeners();
  }

  Future<void> fetchPermissions() async {
    _allPermissions = await _staffService.getAllPermissions();
    notifyListeners();
  }

  Future<bool> createStaff(String name, String email, String password, String roleId) async {
    _isLoading = true;
    notifyListeners();
    final success = await _staffService.createStaff({
      'name': name,
      'email': email,
      'password': password,
      'staff_role_id': roleId,
    });
    if (success) await fetchStaff();
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateStaff(String id, {String? name, String? roleId}) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (roleId != null) data['staff_role_id'] = roleId;
    
    final success = await _staffService.updateStaff(id, data);
    if (success) await fetchStaff();
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteStaff(String id) async {
    _isLoading = true;
    notifyListeners();
    final success = await _staffService.deleteStaff(id);
    if (success) await fetchStaff();
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> createRole(String name) async {
    _isLoading = true;
    notifyListeners();
    final success = await _staffService.createRole(name);
    if (success) await fetchRoles();
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateRole(String id, String name) async {
    _isLoading = true;
    notifyListeners();
    final success = await _staffService.updateRole(id, name);
    if (success) await fetchRoles();
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> setRolePermissions(String roleId, List<String> permissionIds) async {
    _isLoading = true;
    notifyListeners();
    final success = await _staffService.setRolePermissions(roleId, permissionIds);
    if (success) await fetchRoles();
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteRole(String id) async {
    _isLoading = true;
    notifyListeners();
    final success = await _staffService.deleteRole(id);
    if (success) await fetchRoles();
    _isLoading = false;
    notifyListeners();
    return success;
  }
}
