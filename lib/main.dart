import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/main_wrapper.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';

import 'package:chefship_vendor/core/theme/theme_provider.dart';
import 'package:chefship_vendor/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:chefship_vendor/features/menu/presentation/providers/menu_provider.dart';
import 'package:chefship_vendor/features/orders/presentation/providers/order_provider.dart';
import 'package:chefship_vendor/features/staff/presentation/providers/staff_provider.dart';
import 'package:chefship_vendor/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:chefship_vendor/features/discounts/presentation/providers/discount_provider.dart';
import 'package:chefship_vendor/features/reviews/presentation/providers/review_provider.dart';
import 'package:chefship_vendor/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:chefship_vendor/features/menu/presentation/providers/addon_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => DiscountProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => AddonProvider()),
      ],
      child: const ChefShipVendorApp(),
    ),
  );
}

class ChefShipVendorApp extends StatelessWidget {
  const ChefShipVendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'ChefShip Vendor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const MainWrapper();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
