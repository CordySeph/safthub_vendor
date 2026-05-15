class BankAccountModel {
  final String id;
  final String bankName;
  final String accountNumberMask;
  final String accountHolderName;
  final bool isDefault;

  BankAccountModel({
    required this.id,
    required this.bankName,
    required this.accountNumberMask,
    required this.accountHolderName,
    required this.isDefault,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] ?? '',
      bankName: json['bank_name'] ?? '',
      accountNumberMask: json['account_number_mask'] ?? '',
      accountHolderName: json['account_holder_name'] ?? '',
      isDefault: json['is_default'] ?? false,
    );
  }
}
