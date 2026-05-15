import 'package:chefship_vendor/core/api/api_client.dart';
import '../models/bank_account_model.dart';

class BankService {
  final ApiClient _apiClient = ApiClient();
  final String _basePath = '/api/vendor/bank-accounts';

  Future<List<BankAccountModel>> getBankAccounts() async {
    try {
      final response = await _apiClient.dio.get(_basePath);
      final List data = response.data ?? [];
      return data.map((json) => BankAccountModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addBankAccount(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(_basePath, data: data);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setDefaultAccount(String id) async {
    try {
      final response = await _apiClient.dio.post('$_basePath/$id/set-default');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBankAccount(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('$_basePath/$id', data: data);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBankAccount(String id) async {
    try {
      final response = await _apiClient.dio.delete('$_basePath/$id');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
