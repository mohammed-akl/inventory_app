import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart';

import '../data/local_db.dart';

class InventoryRepository {
  final SupabaseClient supabase;
  final AppDatabase localDb;

  InventoryRepository(this.supabase, this.localDb);

  // --- SYNC LOGIC ---

  Future<void> syncAll() async {
    await Future.wait([
      syncVendors(),
      syncProducts(),
    ]);
    // Product prices should ideally sync after products and vendors exist to satisfy constraints.
    await syncProductPrices();
  }

  Future<void> syncVendors() async {
    final response = await supabase.from('vendors').select();
    await localDb.transaction(() async {
      for (final row in response) {
        final vendor = VendorsCompanion.insert(
          id: row['id'],
          name: row['name'],
          contactInfo: Value(row['contact_info']),
          createdAt: DateTime.parse(row['created_at']),
          updatedAt: DateTime.parse(row['updated_at']),
        );
        await localDb.into(localDb.vendors).insertOnConflictUpdate(vendor);
      }
    });
  }

  Future<void> syncProducts() async {
    final response = await supabase.from('products').select();
    await localDb.transaction(() async {
      for (final row in response) {
        final product = ProductsCompanion.insert(
          id: row['id'],
          name: row['name'],
          description: Value(row['description']),
          sku: Value(row['sku']),
          imageUrl: Value(row['image_url']),
          createdAt: DateTime.parse(row['created_at']),
          updatedAt: DateTime.parse(row['updated_at']),
        );
        await localDb.into(localDb.products).insertOnConflictUpdate(product);
      }
    });
  }

  Future<void> syncProductPrices() async {
    final response = await supabase.from('product_prices').select();
    await localDb.transaction(() async {
      // Clear old prices (if they were deleted on server) or use a more robust sync strategy
      // For simplicity, we can do insertOnConflictUpdate, but deleting local prices
      // that don't exist on server requires fetching current IDs.
      // Let's do a simple wipe and insert if we want exact mirror, or just upsert.
      // Upsert:
      for (final row in response) {
        final price = ProductPricesCompanion.insert(
          id: row['id'],
          productId: row['product_id'],
          vendorId: row['vendor_id'],
          price: (row['price'] as num).toDouble(),
          createdAt: DateTime.parse(row['created_at']),
          updatedAt: DateTime.parse(row['updated_at']),
        );
        await localDb.into(localDb.productPrices).insertOnConflictUpdate(price);
      }
    });
  }

  // --- WRITE LOGIC (Direct to API, then sync) ---

  // Check Admin Role
  bool get isAdmin => supabase.auth.currentUser?.appMetadata['role'] == 'admin';

  Future<void> createVendor(String name, String? contactInfo) async {
    if (!isAdmin) throw Exception('Admin only feature');
    await supabase.from('vendors').insert({
      'name': name,
      'contact_info': contactInfo,
    });
    await syncVendors();
  }

  Future<void> updateVendor(String id, String name, String? contactInfo) async {
    if (!isAdmin) throw Exception('Admin only feature');
    await supabase.from('vendors').update({
      'name': name,
      'contact_info': contactInfo,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
    await syncVendors();
  }

  Future<void> deleteVendor(String id) async {
    if (!isAdmin) throw Exception('Admin only feature');
    // Note: Due to ON DELETE CASCADE on server, product_prices will be deleted there too.
    await supabase.from('vendors').delete().eq('id', id);
    // Locally clean up
    await (localDb.delete(localDb.vendors)..where((tbl) => tbl.id.equals(id))).go();
    // Cascade deletes handle locally via drift references or doing it manually.
  }

  Future<void> createProduct(String name, String? description, String? sku, String? imageUrl) async {
    if (!isAdmin) throw Exception('Admin only feature');
    await supabase.from('products').insert({
      'name': name,
      'description': description,
      'sku': sku,
      'image_url': imageUrl,
    });
    await syncProducts();
  }

  Future<void> updateProduct(String id, String name, String? description, String? sku, String? imageUrl) async {
    if (!isAdmin) throw Exception('Admin only feature');
    await supabase.from('products').update({
      'name': name,
      'description': description,
      'sku': sku,
      'image_url': imageUrl,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
    await syncProducts();
  }

  Future<void> deleteProduct(String id) async {
    if (!isAdmin) throw Exception('Admin only feature');
    await supabase.from('products').delete().eq('id', id);
    await (localDb.delete(localDb.products)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> setProductPrice(String productId, String vendorId, double price) async {
    if (!isAdmin) throw Exception('Admin only feature');
    // Upsert equivalent if needed, or check existence
    final existing = await supabase.from('product_prices').select().eq('product_id', productId).eq('vendor_id', vendorId).maybeSingle();
    if (existing != null) {
      await supabase.from('product_prices').update({
        'price': price,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', existing['id']);
    } else {
      await supabase.from('product_prices').insert({
        'product_id': productId,
        'vendor_id': vendorId,
        'price': price,
      });
    }
    await syncProductPrices();
  }
}
