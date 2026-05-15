import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chefship_vendor/features/auth/presentation/providers/auth_provider.dart';

class BusinessHoursScreen extends StatefulWidget {
  const BusinessHoursScreen({super.key});

  @override
  State<BusinessHoursScreen> createState() => _BusinessHoursScreenState();
}

class _BusinessHoursScreenState extends State<BusinessHoursScreen> {
  final List<String> _days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  late Map<String, dynamic> _hours;

  @override
  void initState() {
    super.initState();
    final restaurant = context.read<AuthProvider>().restaurant;
    _hours = restaurant?.businessHours != null 
        ? Map<String, dynamic>.from(restaurant!.businessHours!)
        : {};
    
    // Initialize missing days
    for (var day in _days) {
      if (!_hours.containsKey(day)) {
        _hours[day] = null;
      }
    }
  }

  Future<void> _selectTime(String day, bool isOpen) async {
    final initialTime = _hours[day] != null 
        ? TimeOfDay(
            hour: int.parse(_hours[day][isOpen ? 'open' : 'close'].split(':')[0]),
            minute: int.parse(_hours[day][isOpen ? 'open' : 'close'].split(':')[1]),
          )
        : const TimeOfDay(hour: 9, minute: 0);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (_hours[day] == null) {
          _hours[day] = {'open': '09:00', 'close': '22:00'};
        }
        final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        _hours[day][isOpen ? 'open' : 'close'] = formattedTime;
      });
    }
  }

  Future<void> _handleSave() async {
    final messenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.updateStoreDetails({
      'business_hours': _hours,
    });

    if (success) {
      messenger.showSnackBar(const SnackBar(content: Text('Business hours updated successfully')));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(authProvider.error ?? 'Update failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Hours'),
        actions: [
          TextButton(
            onPressed: authProvider.isLoading ? null : _handleSave,
            child: const Text('Save', style: TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _days.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final day = _days[index];
          final isClosed = _hours[day] == null;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    day.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: isClosed
                      ? const Text('Closed', style: TextStyle(color: Colors.red))
                      : Row(
                          children: [
                            _timeButton(day, true),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('-'),
                            ),
                            _timeButton(day, false),
                          ],
                        ),
                ),
                Switch(
                  value: !isClosed,
                  onChanged: (val) {
                    setState(() {
                      if (val) {
                        _hours[day] = {'open': '09:00', 'close': '22:00'};
                      } else {
                        _hours[day] = null;
                      }
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _timeButton(String day, bool isOpen) {
    final timeStr = _hours[day][isOpen ? 'open' : 'close'];
    return InkWell(
      onTap: () => _selectTime(day, isOpen),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(timeStr),
      ),
    );
  }
}
