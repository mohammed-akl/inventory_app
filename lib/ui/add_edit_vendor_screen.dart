import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../data/local_db.dart';

class AddEditVendorScreen extends ConsumerStatefulWidget {
  final Vendor? vendor;

  const AddEditVendorScreen({Key? key, this.vendor}) : super(key: key);

  @override
  ConsumerState<AddEditVendorScreen> createState() => _AddEditVendorScreenState();
}

class _AddEditVendorScreenState extends ConsumerState<AddEditVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vendor?.name ?? '');
    _contactController = TextEditingController(text: widget.vendor?.contactInfo ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      if (widget.vendor == null) {
        await repo.createVendor(_nameController.text.trim(), _contactController.text.trim());
      } else {
        await repo.updateVendor(widget.vendor!.id, _nameController.text.trim(), _contactController.text.trim());
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
        title: Text(widget.vendor == null ? 'Add Vendor' : 'Edit Vendor'),
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
                decoration: const InputDecoration(labelText: 'Vendor Name *'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Info'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Vendor'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
