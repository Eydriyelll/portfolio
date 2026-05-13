import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'firebase_service.dart';

class CloudinaryService {
  static const String cloudName = 'diut63biv';
  static const String uploadPreset = 'hc6sufp9';
  static const String folder = 'portfolio/photography';

  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  static String getThumbnailUrl(String publicId, {int width = 600}) =>
      'https://res.cloudinary.com/$cloudName/image/upload'
      '/w_$width,c_limit,q_auto/$publicId';

  static String getOriginalUrl(String publicId) =>
      'https://res.cloudinary.com/$cloudName/image/upload/$publicId';

  /// Upload photo to Cloudinary, then save metadata to Firestore
  static Future<CloudinaryUploadResult> uploadPhoto({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      request.fields['resource_type'] = 'image';
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        String msg = 'Upload failed (${response.statusCode})';
        try {
          msg = jsonDecode(response.body)['error']?['message'] ?? msg;
        } catch (_) {}
        return CloudinaryUploadResult(success: false, error: msg);
      }

      final data = jsonDecode(response.body);
      final publicId = data['public_id'] as String;
      final url = data['secure_url'] as String;

      // Save to Firestore
      await FirebaseService.addPhoto(PhotoEntry(
        publicId: publicId,
        url: url,
        fileName: fileName,
        width: data['width'] as int?,
        height: data['height'] as int?,
        bytes: data['bytes'] as int?,
        uploadedAt: DateTime.now(),
      ));

      return CloudinaryUploadResult(
        success: true,
        url: url,
        publicId: publicId,
      );
    } catch (e) {
      return CloudinaryUploadResult(success: false, error: e.toString());
    }
  }
}

class CloudinaryUploadResult {
  final bool success;
  final String? url;
  final String? publicId;
  final String? error;

  CloudinaryUploadResult({
    required this.success,
    this.url,
    this.publicId,
    this.error,
  });
}
