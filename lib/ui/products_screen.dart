import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsStream = ref.watch(productsStreamProvider);
    final repo = ref.read(inventoryRepositoryProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products (Name, SKU)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: repo.syncProducts,
              child: productsStream.when(
                data: (allProducts) {
                  final products = allProducts.where((p) {
                    final nameMatch = p.name.toLowerCase().contains(_searchQuery);
                    final skuMatch = p.sku?.toLowerCase().contains(_searchQuery) ?? false;
                    return nameMatch || skuMatch;
                  }).toList();

                  if (products.isEmpty) {
                    return ListView(
                       children: const [
                         SizedBox(height: 100),
                         Center(child: Text('No products found.')),
                       ]
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            backgroundImage: product.imageUrl != null ? NetworkImage(product.imageUrl!) : null,
                            child: product.imageUrl == null ? const Icon(Icons.inventory, color: AppTheme.primaryColor) : null,
                          ),
                          title: Text(
                            product.name,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: product.sku != null ? Text('SKU: ${product.sku}') : null,
                          onTap: () {
                            context.push('/product-prices', extra: product);
                          },
                          trailing: repo.isAdmin ? IconButton(
                            icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                            onPressed: () {
                              context.push('/edit-product', extra: product);
                            },
                          ) : null,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error loading products: $e')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: repo.isAdmin ? FloatingActionButton(
        onPressed: () {
          context.push('/add-product');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }
}

