import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/bank_provider.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BankProvider>().fetchAccounts();
    });
  }

  void _showAddAccountDialog() {
    final bankNameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final holderNameController = TextEditingController();
    bool isDefault = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Bank Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: bankNameController,
                  decoration: const InputDecoration(labelText: 'Bank Name'),
                ),
                TextField(
                  controller: accountNumberController,
                  decoration: const InputDecoration(labelText: 'Account Number'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: holderNameController,
                  decoration: const InputDecoration(labelText: 'Account Holder Name'),
                ),
                CheckboxListTile(
                  title: const Text('Set as default'),
                  value: isDefault,
                  onChanged: (val) => setState(() => isDefault = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await context.read<BankProvider>().addAccount(
                  bankNameController.text,
                  accountNumberController.text,
                  holderNameController.text,
                  isDefault,
                );
                if (!context.mounted) return;
                if (success) Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bankProvider = context.watch<BankProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Accounts'),
      ),
      body: bankProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bankProvider.accounts.isEmpty
              ? _buildEmptyState()
              : _buildAccountList(bankProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAccountDialog,
        backgroundColor: const Color(0xFFFF7A00),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.creditCard, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No bank accounts added yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountList(BankProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.accounts.length,
      itemBuilder: (context, index) {
        final account = provider.accounts[index];
        return Card(
          child: ListTile(
            leading: const Icon(LucideIcons.banknote, color: Color(0xFFFF7A00)),
            title: Text(account.bankName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.accountNumberMask),
                Text(account.accountHolderName),
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (account.isDefault)
                  const Chip(
                    label: Text('Default', style: TextStyle(fontSize: 10)),
                    backgroundColor: Color(0xFFFF7A00),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deleteAccount(account.id),
                ),
              ],
            ),
            onTap: account.isDefault ? null : () => provider.setDefault(account.id),
          ),
        );
      },
    );
  }
}
