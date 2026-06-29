import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/property_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';

/// Create / edit a property listing.
class PropertyFormScreen extends StatefulWidget {
  final bool isDarkMode;
  final PropertyModel? existing;

  const PropertyFormScreen({super.key, required this.isDarkMode, this.existing});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _address;
  late final TextEditingController _price;
  late final TextEditingController _bedrooms;
  late final TextEditingController _bathrooms;
  late final TextEditingController _squareFeet;

  String _type = 'house';
  String _status = 'available';
  PlatformFile? _image;
  bool _saving = false;

  static const _types = ['house', 'apartment', 'villa', 'land'];
  static const _statuses = ['available', 'reserved', 'sold'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _address = TextEditingController(text: e?.address ?? '');
    _price = TextEditingController(
      text: e != null ? e.price.toStringAsFixed(0) : '',
    );
    _bedrooms = TextEditingController(text: e?.bedrooms.toString() ?? '');
    _bathrooms = TextEditingController(text: e?.bathrooms.toString() ?? '');
    _squareFeet = TextEditingController(
      text: e != null ? e.squareFeet.toStringAsFixed(0) : '',
    );
    _type = e?.propertyType ?? 'house';
    _status = e?.status ?? 'available';
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _address.dispose();
    _price.dispose();
    _bedrooms.dispose();
    _bathrooms.dispose();
    _squareFeet.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _image = result.files.first);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final auth = context.read<AuthService>();
    final db = context.read<DatabaseService>();
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      setState(() => _saving = false);
      return;
    }

    try {
      final dev = await auth.getUserData(uid);
      final now = DateTime.now();
      final id = widget.existing?.id ?? db.newDocId();

      // Upload image first (if any) so the listing is created with its URL.
      String imageUrl = widget.existing?.imageUrl ?? '';
      if (_image != null) {
        imageUrl = await db.uploadPropertyImage(id, _image!) ?? imageUrl;
      }

      final property = PropertyModel(
        id: id,
        title: _title.text.trim(),
        description: _description.text.trim(),
        address: _address.text.trim(),
        price: double.tryParse(_price.text.trim()) ?? 0,
        imageUrl: imageUrl,
        images: imageUrl.isEmpty ? const [] : [imageUrl],
        bedrooms: int.tryParse(_bedrooms.text.trim()) ?? 0,
        bathrooms: int.tryParse(_bathrooms.text.trim()) ?? 0,
        squareFeet: double.tryParse(_squareFeet.text.trim()) ?? 0,
        propertyType: _type,
        status: _status,
        developerId: uid,
        developerName: dev?.name ?? auth.currentUser?.email ?? 'Developer',
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.existing == null) {
        await db.createProperty(property);
      } else {
        await db.updateProperty(property);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save property: $e')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Property' : 'New Property')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Location / address'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(
                  labelText: 'Price (KES)',
                  prefixText: 'KES ',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return 'Enter a valid price';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bedrooms,
                      decoration: const InputDecoration(labelText: 'Beds'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bathrooms,
                      decoration: const InputDecoration(labelText: 'Baths'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _squareFeet,
                      decoration: const InputDecoration(labelText: 'm²'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: _types
                    .map((t) =>
                        DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? 'house'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: _statuses
                    .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? 'available'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined),
                label: Text(_image == null ? 'Add photo' : _image!.name),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(editing ? 'Save changes' : 'Create listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
