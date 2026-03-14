import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_providers.dart';

// Shell components
import 'vendors_screen.dart';
import 'products_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ProductsScreen(),
    VendorsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Trigger initial sync here if desired
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryRepositoryProvider).syncAll().catchError((e) {
        debugPrint('Sync failed on launch: $e');
      });
    });
  }

  void _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      context.go('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Products' : 'Vendors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              try {
                await ref.read(inventoryRepositoryProvider).syncAll();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync Complete')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync Failed: $e')));
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Vendors',
          ),
        ],
      ),
    );
  }
}
