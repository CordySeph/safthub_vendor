import 'package:flutter/material.dart';
import '../../data/models/bank_account_model.dart';
import '../../data/services/bank_service.dart';

class BankProvider extends ChangeNotifier {
  final BankService _bankService = BankService();

  List<BankAccountModel> _accounts = [];
  bool _isLoading = false;

  List<BankAccountModel> get accounts => _accounts;
  bool get isLoading => _isLoading;

  Future<void> fetchAccounts() async {
    _isLoading = true;
    notifyListeners();
    _accounts = await _bankService.getBankAccounts();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addAccount(String bankName, String accountNumber, String accountHolderName, bool isDefault) async {
    final success = await _bankService.addBankAccount({
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_holder_name': accountHolderName,
      'is_default': isDefault,
    });
    if (success) await fetchAccounts();
    return success;
  }

  Future<bool> deleteAccount(String id) async {
    final success = await _bankService.deleteBankAccount(id);
    if (success) await fetchAccounts();
    return success;
  }

  Future<bool> setDefault(String id) async {
    final success = await _bankService.setDefaultAccount(id);
    if (success) await fetchAccounts();
    return success;
  }
}
