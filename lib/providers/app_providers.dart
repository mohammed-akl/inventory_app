import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../data/local_db.dart';
import '../repository/inventory_repository.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final localDbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final db = ref.watch(localDbProvider);
  return InventoryRepository(supabase, db);
});

// Providers for Streams to observe local data changes
final vendorsStreamProvider = StreamProvider<List<Vendor>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.select(db.vendors).watch();
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(localDbProvider);
  return db.select(db.products).watch();
});

final productPricesStreamProvider = StreamProvider.family<List<ProductPrice>, String>((ref, productId) {
  final db = ref.watch(localDbProvider);
  return (db.select(db.productPrices)..where((t) => t.productId.equals(productId))).watch();
});

// Auth Providers
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  // Can just be watched synchronously since authState updates rebuild if we want,
  // but simpler to use supabase getter
  return ref.watch(supabaseProvider).auth.currentUser;
});
