import 'package:chefship_vendor/core/api/api_client.dart';
import '../models/staff_model.dart';

class StaffService {
  final ApiClient _apiClient = ApiClient();

  // Roles & Permissions
  Future<List<StaffPermission>> getAllPermissions() async {
    try {
      final response = await _apiClient.dio.get('/api/vendor/staff-roles/permissions');
      final List data = response.data ?? [];
      return data.map((json) => StaffPermission.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<StaffRole>> getRoles() async {
    try {
      final response = await _apiClient.dio.get('/api/vendor/staff-roles');
      final List data = response.data ?? [];
      return data.map((json) => StaffRole.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createRole(String name) async {
    try {
      final response = await _apiClient.dio.post('/api/vendor/staff-roles', data: {'name': name});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateRole(String roleId, String name) async {
    try {
      final response = await _apiClient.dio.put('/api/vendor/staff-roles/$roleId', data: {'name': name});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setRolePermissions(String roleId, List<String> permissionIds) async {
    try {
      final response = await _apiClient.dio.put('/api/vendor/staff-roles/$roleId/permissions', data: {
        'permission_ids': permissionIds,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRole(String roleId) async {
    try {
      final response = await _apiClient.dio.delete('/api/vendor/staff-roles/$roleId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Staff Management
  Future<List<StaffMember>> getStaff() async {
    try {
      final response = await _apiClient.dio.get('/api/vendor/staff');
      final List data = response.data ?? [];
      return data.map((json) => StaffMember.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createStaff(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/vendor/staff', data: data);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStaff(String staffId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('/api/vendor/staff/$staffId', data: data);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteStaff(String staffId) async {
    try {
      final response = await _apiClient.dio.delete('/api/vendor/staff/$staffId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
