import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/project_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';

/// Create / edit a project. Passing [existing] switches it to edit mode.
class ProjectFormScreen extends StatefulWidget {
  final bool isDarkMode;
  final ProjectModel? existing;

  const ProjectFormScreen({super.key, required this.isDarkMode, this.existing});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _address;
  late final TextEditingController _budget;

  PlatformFile? _pickedImage;
  bool _saving = false;
  String _status = 'planning';

  static const _statuses = ['planning', 'in_progress', 'on_hold', 'completed'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _address = TextEditingController(text: e?.address ?? '');
    _budget = TextEditingController(
      text: e != null ? e.budget.toStringAsFixed(0) : '',
    );
    _status = e?.status ?? 'planning';
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _address.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedImage = result.files.first);
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
      final architect = await auth.getUserData(uid);
      final now = DateTime.now();
      final id = widget.existing?.id ?? db.newDocId();
      final budget = double.tryParse(_budget.text.trim()) ?? 0;

      final project = ProjectModel(
        id: id,
        title: _title.text.trim(),
        description: _description.text.trim(),
        address: _address.text.trim(),
        budget: budget,
        imageUrl: widget.existing?.imageUrl ?? '',
        images: widget.existing?.images ?? const [],
        status: _status,
        architectId: uid,
        architectName: architect?.name ?? auth.currentUser?.email ?? 'Architect',
        diasporaId: widget.existing?.diasporaId,
        diasporaName: widget.existing?.diasporaName,
        model3dUrl: widget.existing?.model3dUrl,
        milestones: widget.existing?.milestones ?? const [],
        startDate: widget.existing?.startDate ?? now,
        endDate: widget.existing?.endDate,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.existing == null) {
        await db.createProject(project);
      } else {
        await db.updateProject(project);
      }

      if (_pickedImage != null) {
        await db.uploadProjectImage(id, _pickedImage!);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save project: $e')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Project' : 'New Project')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Project title'),
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
                decoration: const InputDecoration(labelText: 'Address / location'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budget,
                decoration: const InputDecoration(
                  labelText: 'Budget (KES)',
                  prefixText: 'KES ',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return 'Enter a valid budget';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: _statuses
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.replaceAll('_', ' ').toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? 'planning'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  _pickedImage == null ? 'Add cover image' : _pickedImage!.name,
                ),
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
                    : Text(editing ? 'Save changes' : 'Create project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
