import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'diut63biv';
  static const String uploadPreset = 'hc6sufp9';
  static const String apiKey = '157969599811352';
  static const String folder = 'portfolio/photography';

  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/auto/upload';

  static String get searchUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/resources/image';

  /// Fetch all photos from the portfolio/photography folder
  static Future<List<CloudinaryPhoto>> fetchPhotos() async {
    try {
      final uri = Uri.parse(
        'https://res.cloudinary.com/$cloudName/image/list/$folder.json',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resources = data['resources'] as List<dynamic>? ?? [];
        return resources.map((r) => CloudinaryPhoto.fromJson(r)).toList();
      }

      // Fallback: use search API without signature (public resources)
      return await _fetchViaTag();
    } catch (e) {
      return await _fetchViaTag();
    }
  }

  static Future<List<CloudinaryPhoto>> _fetchViaTag() async {
    try {
      // Use the Cloudinary search expression via URL-based listing
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/resources/search'
        '?expression=folder%3A$folder&max_results=100',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resources = data['resources'] as List<dynamic>? ?? [];
        return resources.map((r) => CloudinaryPhoto.fromSearchJson(r)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Upload a single photo (bytes) to Cloudinary
  static Future<CloudinaryUploadResult> uploadPhoto({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final uri = Uri.parse(uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      request.fields['resource_type'] = 'auto';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CloudinaryUploadResult(
          success: true,
          url: data['secure_url'],
          publicId: data['public_id'],
        );
      } else {
        final error = jsonDecode(response.body);
        return CloudinaryUploadResult(
          success: false,
          error: error['error']?['message'] ?? 'Upload failed',
        );
      }
    } catch (e) {
      return CloudinaryUploadResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Delete a photo by public_id (requires signed request — handled server-side)
  /// For now we mark it as not directly deletable from frontend
  static String getThumbnailUrl(String publicId, {int width = 400}) {
    return 'https://res.cloudinary.com/$cloudName/image/upload'
        '/w_$width,q_auto/$publicId';
  }

  static String getOriginalUrl(String publicId) {
    return 'https://res.cloudinary.com/$cloudName/image/upload/$publicId';
  }
}

class CloudinaryPhoto {
  final String publicId;
  final String url;
  final String? displayName;
  final int? width;
  final int? height;
  final int? bytes;
  final DateTime? createdAt;

  CloudinaryPhoto({
    required this.publicId,
    required this.url,
    this.displayName,
    this.width,
    this.height,
    this.bytes,
    this.createdAt,
  });

  factory CloudinaryPhoto.fromJson(Map<String, dynamic> json) {
    final publicId = json['public_id'] as String;
    return CloudinaryPhoto(
      publicId: publicId,
      url: CloudinaryService.getOriginalUrl(publicId),
      displayName: json['display_name'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      bytes: json['bytes'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  factory CloudinaryPhoto.fromSearchJson(Map<String, dynamic> json) {
    final publicId = json['public_id'] as String;
    return CloudinaryPhoto(
      publicId: publicId,
      url: json['secure_url'] ?? CloudinaryService.getOriginalUrl(publicId),
      width: json['width'] as int?,
      height: json['height'] as int?,
      bytes: json['bytes'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  String get thumbnailUrl =>
      CloudinaryService.getThumbnailUrl(publicId, width: 600);

  String get name => displayName ?? publicId.split('/').last;
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
