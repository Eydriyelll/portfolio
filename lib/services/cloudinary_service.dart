import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'diut63biv';
  static const String uploadPreset = 'hc6sufp9';
  static const String folder = 'portfolio/photography';

  // JSONBin config — stores the photo list publicly
  static const String _binId = '6a01ae21c0954111d8082ac1';
  static const String _binApiKey = r'$2a$10$7LdDa9wHzSD2xHOZwv85yO5lJcpQJwBrkfCQNwWmwwevqjGKpt07q';
  static const String _binUrl = 'https://api.jsonbin.io/v3/b/$_binId';

  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  // ─── FETCH ───────────────────────────────────────────────
  static Future<List<CloudinaryPhoto>> fetchPhotos() async {
    try {
      final response = await http.get(
        Uri.parse('$_binUrl/latest'),
        headers: {
          'X-Master-Key': _binApiKey,
          'X-Bin-Meta': 'false',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final photos = (data['photos'] as List<dynamic>? ?? [])
            .map((p) => CloudinaryPhoto.fromJson(p))
            .toList();
        // Newest first
        photos.sort((a, b) =>
            (b.uploadedAt ?? DateTime(0)).compareTo(a.uploadedAt ?? DateTime(0)));
        return photos;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ─── UPLOAD ──────────────────────────────────────────────
  static Future<CloudinaryUploadResult> uploadPhoto({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      // 1. Upload to Cloudinary
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
          final err = jsonDecode(response.body);
          msg = err['error']?['message'] ?? msg;
        } catch (_) {}
        return CloudinaryUploadResult(success: false, error: msg);
      }

      final data = jsonDecode(response.body);
      final publicId = data['public_id'] as String;
      final secureUrl = data['secure_url'] as String;
      final width = data['width'] as int?;
      final height = data['height'] as int?;
      final bytes2 = data['bytes'] as int?;

      // 2. Save to JSONBin
      await _addPhotoToList(CloudinaryPhoto(
        publicId: publicId,
        url: secureUrl,
        width: width,
        height: height,
        bytes: bytes2,
        fileName: fileName,
        uploadedAt: DateTime.now(),
      ));

      return CloudinaryUploadResult(
        success: true,
        url: secureUrl,
        publicId: publicId,
      );
    } catch (e) {
      return CloudinaryUploadResult(success: false, error: e.toString());
    }
  }

  // ─── SAVE TO JSONBIN ─────────────────────────────────────
  static Future<void> _addPhotoToList(CloudinaryPhoto newPhoto) async {
    try {
      // Get current list
      final getRes = await http.get(
        Uri.parse('$_binUrl/latest'),
        headers: {
          'X-Master-Key': _binApiKey,
          'X-Bin-Meta': 'false',
        },
      );

      List<dynamic> currentPhotos = [];
      if (getRes.statusCode == 200) {
        final data = jsonDecode(getRes.body);
        currentPhotos = List<dynamic>.from(data['photos'] ?? []);
      }

      // Add new photo at the front
      currentPhotos.insert(0, newPhoto.toJson());

      // Update JSONBin
      await http.put(
        Uri.parse(_binUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Master-Key': _binApiKey,
        },
        body: jsonEncode({'photos': currentPhotos}),
      );
    } catch (_) {
      // Silent fail — photo is still on Cloudinary
    }
  }

  // ─── DELETE FROM JSONBIN ──────────────────────────────────
  static Future<void> removePhotoFromList(String publicId) async {
    try {
      final getRes = await http.get(
        Uri.parse('$_binUrl/latest'),
        headers: {
          'X-Master-Key': _binApiKey,
          'X-Bin-Meta': 'false',
        },
      );

      if (getRes.statusCode == 200) {
        final data = jsonDecode(getRes.body);
        final photos = List<dynamic>.from(data['photos'] ?? [])
          ..removeWhere((p) => p['publicId'] == publicId);

        await http.put(
          Uri.parse(_binUrl),
          headers: {
            'Content-Type': 'application/json',
            'X-Master-Key': _binApiKey,
          },
          body: jsonEncode({'photos': photos}),
        );
      }
    } catch (_) {}
  }

  // ─── HELPERS ─────────────────────────────────────────────
  static String getThumbnailUrl(String publicId, {int width = 600}) {
    return 'https://res.cloudinary.com/$cloudName/image/upload'
        '/w_$width,c_limit,q_auto/$publicId';
  }

  static String getOriginalUrl(String publicId) {
    return 'https://res.cloudinary.com/$cloudName/image/upload/$publicId';
  }
}

// ─── MODELS ──────────────────────────────────────────────────
class CloudinaryPhoto {
  final String publicId;
  final String url;
  final int? width;
  final int? height;
  final int? bytes;
  final String? fileName;
  final DateTime? uploadedAt;

  CloudinaryPhoto({
    required this.publicId,
    required this.url,
    this.width,
    this.height,
    this.bytes,
    this.fileName,
    this.uploadedAt,
  });

  factory CloudinaryPhoto.fromJson(Map<String, dynamic> json) {
    return CloudinaryPhoto(
      publicId: json['publicId'] as String,
      url: json['url'] as String,
      width: json['width'] as int?,
      height: json['height'] as int?,
      bytes: json['bytes'] as int?,
      fileName: json['fileName'] as String?,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'publicId': publicId,
        'url': url,
        'width': width,
        'height': height,
        'bytes': bytes,
        'fileName': fileName,
        'uploadedAt': uploadedAt?.toIso8601String(),
      };

  String get thumbnailUrl =>
      CloudinaryService.getThumbnailUrl(publicId, width: 600);

  String get name => fileName ?? publicId.split('/').last;
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
