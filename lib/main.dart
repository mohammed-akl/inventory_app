import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme.dart';
import 'providers/app_providers.dart';

// Screens will go here (UI features)
import 'ui/sign_in_screen.dart';
import 'ui/home_screen.dart'; 
import 'ui/add_edit_vendor_screen.dart';
import 'ui/add_edit_product_screen.dart';
import 'ui/product_prices_screen.dart';
import '../data/local_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnon = dotenv.env['SUPABASE_ANON'] ?? '';
  
  // Wait for Supabase initialization
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnon,
  );

  runApp(
    const ProviderScope(
      child: InventoryApp(),
    ),
  );
}

class InventoryApp extends ConsumerWidget {
  const InventoryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Basic routing using GoRouter. Re-evaluates on auth state changes
    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final session = Supabase.instance.client.auth.currentSession;
        final isLoggingIn = state.uri.toString() == '/signin';

        if (session == null && !isLoggingIn) return '/signin';
        if (session != null && isLoggingIn) return '/';
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/signin',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/add-vendor',
          builder: (context, state) => const AddEditVendorScreen(),
        ),
        GoRoute(
          path: '/edit-vendor',
          builder: (context, state) => AddEditVendorScreen(vendor: state.extra as Vendor),
        ),
        GoRoute(
          path: '/add-product',
          builder: (context, state) => const AddEditProductScreen(),
        ),
        GoRoute(
          path: '/edit-product',
          builder: (context, state) => AddEditProductScreen(product: state.extra as Product),
        ),
        GoRoute(
          path: '/product-prices',
          builder: (context, state) => ProductPricesScreen(product: state.extra as Product),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Inventory App',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
