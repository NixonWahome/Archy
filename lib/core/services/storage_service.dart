import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../storage_config.dart';

/// Thrown when an upload can't proceed so callers can show a clear message.
class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  @override
  String toString() => message;
}

/// Free, no-credit-card file storage backed by Cloudinary unsigned uploads.
///
/// Replaces Firebase Storage (which now requires the paid Blaze plan to even
/// create a bucket). Returns a public HTTPS URL that can be stored in Firestore
/// and loaded directly by model_viewer_plus / Android Scene Viewer / Unity.
///
/// Config lives in [StorageConfig]; no secrets are embedded in the app.
class StorageService {
  /// Uploads raw bytes and returns the public `secure_url`.
  ///
  /// [folder] groups files (e.g. `ar_models/<projectId>`). [resourceType] is
  /// `auto` (Cloudinary detects), `image`, or `raw` (for .glb/.gltf models).
  Future<String> uploadBytes(
    List<int> bytes, {
    required String filename,
    String folder = 'archy',
    String resourceType = 'auto',
  }) async {
    if (!StorageConfig.isConfigured) {
      throw StorageException(
        'File hosting is not set up yet. Add your Cloudinary cloud name and '
        'unsigned upload preset in lib/core/storage_config.dart (free, no card).',
      );
    }
    if (bytes.isEmpty) {
      throw StorageException('The selected file is empty.');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${StorageConfig.cloudName}/$resourceType/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = StorageConfig.uploadPreset
      ..fields['folder'] = folder
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200 && streamed.statusCode != 201) {
      throw StorageException(
        'Upload failed (${streamed.statusCode}). $body',
      );
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    final url = data['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw StorageException('Upload succeeded but no URL was returned.');
    }
    return url;
  }

  /// Convenience for a picked file. Uses `raw` for 3D models so glb/gltf are
  /// served with a stable extension, `image` otherwise.
  Future<String> uploadPickedFile(
    PlatformFile file, {
    required String folder,
  }) async {
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw StorageException('Could not read the selected file.');
    }
    final ext = (file.extension ?? '').toLowerCase();
    final isModel = ext == 'glb' || ext == 'gltf';
    return uploadBytes(
      bytes,
      filename: file.name,
      folder: folder,
      resourceType: isModel ? 'raw' : 'image',
    );
  }
}
