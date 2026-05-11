import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'diut63biv';
  static const String uploadPreset = 'hc6sufp9';
  static const String apiKey = '157969599811352';
  static const String folder = 'portfolio/photography';
  static const String galleryTag = 'adriel_portfolio';

  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Primary fetch: folder-based using API key (no secret needed for GET)
  static Future<List<CloudinaryPhoto>> fetchPhotos() async {
    // Try 3 methods in order until one works
    final photos = await _fetchByFolder() ??
        await _fetchByTag() ??
        [];
    return photos;
  }

  /// Method 1: fetch by folder path using Admin API (read-only, API key only)
  static Future<List<CloudinaryPhoto>?> _fetchByFolder() async {
    try {
      final credentials = base64Encode(utf8.encode('$apiKey:'));
      // Use folder as prefix for resource listing
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/resources/image'
        '?asset_folder=$folder&max_results=100&type=upload',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Basic $credentials'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resources = data['resources'] as List<dynamic>? ?? [];
        if (resources.isNotEmpty) {
          final photos = resources
              .map((r) => CloudinaryPhoto.fromAdminJson(r))
              .toList();
          photos.sort((a, b) => (b.createdAt ?? DateTime(0))
              .compareTo(a.createdAt ?? DateTime(0)));
          return photos;
        }
      }

      // Also try with 'prefix' param (older Cloudinary accounts)
      final uri2 = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/resources/image'
        '?prefix=$folder&max_results=100&type=upload',
      );
      final response2 = await http.get(
        uri2,
        headers: {'Authorization': 'Basic $credentials'},
      );
      if (response2.statusCode == 200) {
        final data = jsonDecode(response2.body);
        final resources = data['resources'] as List<dynamic>? ?? [];
        if (resources.isNotEmpty) {
          final photos = resources
              .map((r) => CloudinaryPhoto.fromAdminJson(r))
              .toList();
          photos.sort((a, b) => (b.createdAt ?? DateTime(0))
              .compareTo(a.createdAt ?? DateTime(0)));
          return photos;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Method 2: fetch by tag (fallback)
  static Future<List<CloudinaryPhoto>?> _fetchByTag() async {
    try {
      final uri = Uri.parse(
        'https://res.cloudinary.com/$cloudName/image/list/$galleryTag.json',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resources = data['resources'] as List<dynamic>? ?? [];
        if (resources.isNotEmpty) {
          final photos = resources
              .map((r) => CloudinaryPhoto.fromListJson(r))
              .toList();
          photos.sort((a, b) => (b.createdAt ?? DateTime(0))
              .compareTo(a.createdAt ?? DateTime(0)));
          return photos;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Upload photo — tags it AND puts it in folder so both fetch methods work
  static Future<CloudinaryUploadResult> uploadPhoto({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final uri = Uri.parse(uploadUrl);
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      request.fields['tags'] = galleryTag;
      request.fields['resource_type'] = 'image';
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CloudinaryUploadResult(
          success: true,
          url: data['secure_url'],
          publicId: data['public_id'],
        );
      } else {
        String msg = 'Upload failed (${response.statusCode})';
        try {
          final err = jsonDecode(response.body);
          msg = err['error']?['message'] ?? msg;
        } catch (_) {}
        return CloudinaryUploadResult(success: false, error: msg);
      }
    } catch (e) {
      return CloudinaryUploadResult(success: false, error: e.toString());
    }
  }

  static String getThumbnailUrl(String publicId, {int width = 600}) {
    return 'https://res.cloudinary.com/$cloudName/image/upload'
        '/w_$width,c_limit,q_auto/$publicId';
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

  factory CloudinaryPhoto.fromAdminJson(Map<String, dynamic> json) {
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

  factory CloudinaryPhoto.fromListJson(Map<String, dynamic> json) {
    final publicId = json['public_id'] as String;
    return CloudinaryPhoto(
      publicId: publicId,
      url: CloudinaryService.getOriginalUrl(publicId),
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
