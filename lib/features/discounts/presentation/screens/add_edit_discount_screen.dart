import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/discount_provider.dart';
import '../../data/models/discount_model.dart';

class AddEditDiscountScreen extends StatefulWidget {
  final DiscountModel? discount;
  const AddEditDiscountScreen({super.key, this.discount});

  @override
  State<AddEditDiscountScreen> createState() => _AddEditDiscountScreenState();
}

class _AddEditDiscountScreenState extends State<AddEditDiscountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _valueController;
  late TextEditingController _minValueController;
  String _type = 'percentage';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.discount?.code);
    _valueController = TextEditingController(text: widget.discount?.value.toInt().toString());
    _minValueController = TextEditingController(text: widget.discount?.minOrderValue.toInt().toString());
    _type = widget.discount?.type ?? 'percentage';
    if (widget.discount != null) {
      _startDate = widget.discount!.startDate;
      _endDate = widget.discount!.endDate;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    _minValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.discount != null;
    final discountProvider = context.watch<DiscountProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Discount' : 'Create Discount')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Discount Code',
                hintText: 'e.g. SUMMER10',
                prefixIcon: Icon(LucideIcons.tag, size: 20),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Discount Type'),
              items: const [
                DropdownMenuItem(value: 'percentage', child: Text('Percentage (%)')),
                DropdownMenuItem(value: 'fixed_amount', child: Text('Fixed Amount (฿)')),
              ],
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: _type == 'percentage' ? 'Percentage Off (%)' : 'Amount Off (฿)',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minValueController,
              decoration: const InputDecoration(labelText: 'Min. Order Value (฿)'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            const Text('Validity Period', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(LucideIcons.calendar, size: 16),
                    label: Text('Starts: ${_formatDate(_startDate)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(LucideIcons.calendar, size: 16),
                    label: Text('Ends: ${_formatDate(_endDate)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: discountProvider.isLoading ? null : _saveDiscount,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: discountProvider.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isEdit ? 'Save Changes' : 'Create Discount'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF7A00),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveDiscount() async {
    if (_formKey.currentState!.validate()) {
      final discount = DiscountModel(
        id: widget.discount?.id ?? '',
        code: _codeController.text.toUpperCase(),
        type: _type,
        value: double.parse(_valueController.text),
        minOrderValue: double.parse(_minValueController.text),
        startDate: _startDate,
        endDate: _endDate,
        isActive: widget.discount?.isActive ?? true,
      );

      bool success;
      if (widget.discount != null) {
        success = await context.read<DiscountProvider>().updateDiscount(discount.id, discount.toJson());
      } else {
        success = await context.read<DiscountProvider>().createDiscount(discount);
      }

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.discount != null ? 'Discount updated' : 'Discount created')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save discount')),
        );
      }
    }
  }
}
