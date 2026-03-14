import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

class VendorsScreen extends ConsumerWidget {
  const VendorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsStream = ref.watch(vendorsStreamProvider);
    final repo = ref.read(inventoryRepositoryProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: repo.syncVendors,
        child: vendorsStream.when(
          data: (vendors) {
            if (vendors.isEmpty) {
              return ListView(
                 children: const [
                   SizedBox(height: 100),
                   Center(child: Text('No vendors found.')),
                 ]
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vendors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final vendor = vendors[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: const Icon(Icons.storefront, color: AppTheme.primaryColor),
                    ),
                    title: Text(
                      vendor.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: vendor.contactInfo != null ? Text(vendor.contactInfo!) : null,
                    trailing: repo.isAdmin ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                          onPressed: () {
                            context.push('/edit-vendor', extra: vendor);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Delete Vendor'),
                                content: const Text('Are you sure? This will delete associated product prices.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, true), 
                                    child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              )
                            );
                            if (confirm == true) {
                              try {
                                await repo.deleteVendor(vendor.id);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ) : null,
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error loading vendors: $e')),
        ),
      ),
      floatingActionButton: repo.isAdmin ? FloatingActionButton(
        onPressed: () {
          context.push('/add-vendor');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }
}
