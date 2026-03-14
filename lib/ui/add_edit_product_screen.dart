import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../data/local_db.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final Product? product;

  const AddEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _skuController;
  late TextEditingController _imgController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
    _imgController = TextEditingController(text: widget.product?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _skuController.dispose();
    _imgController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final sku = _skuController.text.trim();
      final img = _imgController.text.trim();

      if (widget.product == null) {
        await repo.createProduct(
          _nameController.text.trim(), 
          _descController.text.trim(),
          sku.isEmpty ? null : sku,
          img.isEmpty ? null : img,
        );
      } else {
        await repo.updateProduct(
          widget.product!.id, 
          _nameController.text.trim(), 
          _descController.text.trim(),
          sku.isEmpty ? null : sku,
          img.isEmpty ? null : img,
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name *'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'SKU'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imgController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Product'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
