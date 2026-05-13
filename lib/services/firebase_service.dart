import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static const String _collection = 'photos';

  /// Fetch all photos ordered by uploadedAt descending
  static Future<List<PhotoEntry>> fetchPhotos() async {
    try {
      final snap = await _db
          .collection(_collection)
          .orderBy('uploadedAt', descending: true)
          .get();
      return snap.docs.map((d) => PhotoEntry.fromDoc(d)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a photo entry after successful Cloudinary upload
  static Future<void> addPhoto(PhotoEntry photo) async {
    try {
      await _db.collection(_collection).add(photo.toMap());
    } catch (_) {}
  }

  /// Remove a photo entry by Firestore document ID
  static Future<void> removePhoto(String docId) async {
    try {
      await _db.collection(_collection).doc(docId).delete();
    } catch (_) {}
  }

  /// Real-time stream of photos for live gallery updates
  static Stream<List<PhotoEntry>> photosStream() {
    return _db
        .collection(_collection)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PhotoEntry.fromDoc(d)).toList());
  }
}

class PhotoEntry {
  final String? docId;
  final String publicId;
  final String url;
  final String? fileName;
  final int? width;
  final int? height;
  final int? bytes;
  final DateTime? uploadedAt;

  PhotoEntry({
    this.docId,
    required this.publicId,
    required this.url,
    this.fileName,
    this.width,
    this.height,
    this.bytes,
    this.uploadedAt,
  });

  factory PhotoEntry.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PhotoEntry(
      docId: doc.id,
      publicId: d['publicId'] ?? '',
      url: d['url'] ?? '',
      fileName: d['fileName'],
      width: d['width'],
      height: d['height'],
      bytes: d['bytes'],
      uploadedAt: (d['uploadedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'publicId': publicId,
        'url': url,
        'fileName': fileName,
        'width': width,
        'height': height,
        'bytes': bytes,
        'uploadedAt': uploadedAt != null
            ? Timestamp.fromDate(uploadedAt!)
            : FieldValue.serverTimestamp(),
      };

  String get thumbnailUrl =>
      'https://res.cloudinary.com/diut63biv/image/upload/w_600,c_limit,q_auto/$publicId';

  String get name => fileName ?? publicId.split('/').last;
}
