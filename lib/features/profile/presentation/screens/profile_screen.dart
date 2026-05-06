import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:chefship_vendor/features/auth/presentation/providers/auth_provider.dart';

import 'package:chefship_vendor/core/theme/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildStoreHeader(auth),
            const SizedBox(height: 32),
            _buildMenuSection(context, 'Store Management', [
              _buildMenuItem(context, LucideIcons.store, 'Store Details', 'Name, address, contact', () {}),
              _buildMenuItem(context, LucideIcons.clock, 'Business Hours', 'Set opening times', () {}),
              _buildThemeTile(context, themeProvider),
              _buildMenuItem(context, LucideIcons.settings, 'Settings', 'Notifications, app settings', () {}),
            ]),
            _buildMenuSection(context, 'Financials', [
              _buildMenuItem(context, LucideIcons.creditCard, 'Bank Accounts', 'Manage payout methods', () {}),
              _buildMenuItem(context, LucideIcons.history, 'Payout History', 'View past transactions', () {}),
            ]),
            _buildMenuSection(context, 'Other', [
              _buildMenuItem(context, LucideIcons.helpCircle, 'Help & Support', 'Get assistance', () {}),
              _buildMenuItem(context, LucideIcons.logOut, 'Logout', 'Exit your account', () {
                context.read<AuthProvider>().logout();
              }, isDestructive: true),
            ]),
            const SizedBox(height: 40),
            const Text(
              'ChefShip Vendor v1.0.0',
              style: TextStyle(color: Color(0xFF666666), fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: Icon(
        themeProvider.themeMode == ThemeMode.dark
            ? LucideIcons.moon
            : themeProvider.themeMode == ThemeMode.light
                ? LucideIcons.sun
                : LucideIcons.monitor,
        color: Theme.of(context).iconTheme.color ?? Colors.white,
        size: 22,
      ),
      title: const Text(
        'Appearance',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        themeProvider.themeMode == ThemeMode.system
            ? 'System Default'
            : themeProvider.themeMode == ThemeMode.dark
                ? 'Dark Mode'
                : 'Light Mode',
        style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
      ),
      trailing: DropdownButton<ThemeMode>(
        value: themeProvider.themeMode,
        underline: const SizedBox(),
        onChanged: (ThemeMode? newMode) {
          if (newMode != null) {
            themeProvider.setThemeMode(newMode);
          }
        },
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
        ],
      ),
    );
  }

  Widget _buildStoreHeader(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7A00),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: Icon(LucideIcons.utensils, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                auth.restaurant?.name ?? 'Delicious Thai Bistro',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'ID: ${auth.restaurant?.id.substring(0, 10).toUpperCase() ?? "REST-998877"}',
                style: const TextStyle(color: Color(0xFF666666), fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(LucideIcons.mapPin, color: Color(0xFF666666), size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Sukhumvit, Bangkok',
                    style: TextStyle(color: Color(0xFF666666), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF7A00),
            ),
          ),
        ),
        Column(children: items),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    final textColor = isDestructive ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color;
    
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF666666), fontSize: 13)),
      trailing: const Icon(LucideIcons.chevronRight, color: Color(0xFF666666), size: 18),
    );
  }
}
