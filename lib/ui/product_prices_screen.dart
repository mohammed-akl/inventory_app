import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../data/local_db.dart';
import '../theme/app_theme.dart';

class ProductPricesScreen extends ConsumerWidget {
  final Product product;

  const ProductPricesScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricesStream = ref.watch(productPricesStreamProvider(product.id));
    final vendorsStream = ref.watch(vendorsStreamProvider);
    final repo = ref.read(inventoryRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${product.name} Prices'),
      ),
      body: pricesStream.when(
        data: (prices) {
          return vendorsStream.when(
            data: (vendors) {
              if (vendors.isEmpty) {
                return const Center(child: Text('Add vendors first to set prices.'));
              }
              
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vendors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final vendor = vendors[index];
                  final existingPrice = prices.where((p) => p.vendorId == vendor.id).firstOrNull;

                  return Card(
                    child: ListTile(
                      title: Text(vendor.name),
                      subtitle: existingPrice != null 
                          ? Text('Price: ₹${existingPrice.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor))
                          : const Text('No price set'),
                      trailing: repo.isAdmin ? IconButton(
                        icon: const Icon(Icons.edit_note, color: AppTheme.primaryColor),
                        onPressed: () {
                          _showPriceEditor(context, ref, vendor, existingPrice?.price);
                        },
                      ) : null,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading vendors: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading prices: $e')),
      ),
    );
  }

  void _showPriceEditor(BuildContext context, WidgetRef ref, Vendor vendor, double? currentPrice) {
    final controller = TextEditingController(text: currentPrice?.toString() ?? '');
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Set Price for ${vendor.name}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Price'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(controller.text.trim());
              if (val != null) {
                try {
                  await ref.read(inventoryRepositoryProvider).setProductPrice(product.id, vendor.id, val);
                  if (c.mounted) Navigator.pop(c);
                } catch (e) {
                  if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      )
    );
  }
}
