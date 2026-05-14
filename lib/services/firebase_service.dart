import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ─── PHOTOS ──────────────────────────────────────────────────
  static Stream<List<PhotoEntry>> photosStream() => _db
      .collection('photos')
      .orderBy('uploadedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(PhotoEntry.fromDoc).toList());

  static Future<void> addPhoto(PhotoEntry p) async =>
      await _db.collection('photos').add(p.toMap());

  static Future<void> removePhoto(String id) async =>
      await _db.collection('photos').doc(id).delete();

  // ─── PROFILE ─────────────────────────────────────────────────
  static Stream<String?> profilePhotoStream() => _db
      .collection('settings')
      .doc('profile')
      .snapshots()
      .map((s) => s.data()?['photoUrl'] as String?);

  static Future<void> setProfilePhoto(String url) async =>
      await _db.collection('settings').doc('profile').set({'photoUrl': url});

  // ─── SKILLS ──────────────────────────────────────────────────
  static Stream<List<SkillEntry>> skillsStream() => _db
      .collection('skills')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((s) => s.docs.map(SkillEntry.fromDoc).toList());

  static Future<void> addSkill(SkillEntry s) async =>
      await _db.collection('skills').add(s.toMap());

  static Future<void> removeSkill(String id) async =>
      await _db.collection('skills').doc(id).delete();

  // ─── CERTIFICATES ─────────────────────────────────────────────
  static Stream<List<CertEntry>> certsStream() => _db
      .collection('certificates')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((s) => s.docs.map(CertEntry.fromDoc).toList());

  static Future<void> addCert(CertEntry c) async =>
      await _db.collection('certificates').add(c.toMap());

  static Future<void> removeCert(String id) async =>
      await _db.collection('certificates').doc(id).delete();

  // ─── PROJECTS ────────────────────────────────────────────────
  static Stream<List<ProjectEntry>> projectsStream() => _db
      .collection('projects')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((s) => s.docs.map(ProjectEntry.fromDoc).toList());

  static Future<void> addProject(ProjectEntry p) async =>
      await _db.collection('projects').add(p.toMap());

  static Future<void> removeProject(String id) async =>
      await _db.collection('projects').doc(id).delete();

  // ─── CONTACT ─────────────────────────────────────────────────
  static Stream<ContactData> contactStream() => _db
      .collection('settings')
      .doc('contact')
      .snapshots()
      .map((s) {
        if (!s.exists || s.data() == null) return ContactData();
        return ContactData.fromMap(s.data()!);
      });

  static Future<void> updateContact(ContactData c) async =>
      await _db.collection('settings').doc('contact').set(c.toMap());
}

// ─── MODELS ──────────────────────────────────────────────────────

class PhotoEntry {
  final String? docId;
  final String publicId, url;
  final String? fileName;
  final int? width, height, bytes;
  final DateTime? uploadedAt;

  PhotoEntry({this.docId, required this.publicId, required this.url,
      this.fileName, this.width, this.height, this.bytes, this.uploadedAt});

  factory PhotoEntry.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return PhotoEntry(
      docId: d.id, publicId: m['publicId'] ?? '',
      url: m['url'] ?? '', fileName: m['fileName'],
      width: m['width'], height: m['height'], bytes: m['bytes'],
      uploadedAt: (m['uploadedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'publicId': publicId, 'url': url, 'fileName': fileName,
    'width': width, 'height': height, 'bytes': bytes,
    'uploadedAt': uploadedAt != null
        ? Timestamp.fromDate(uploadedAt!) : FieldValue.serverTimestamp(),
  };

  String get thumbnailUrl =>
      'https://res.cloudinary.com/diut63biv/image/upload/w_600,c_limit,q_auto/$publicId';
  String get name => fileName ?? publicId.split('/').last;
}

class SkillEntry {
  final String? docId;
  final String name, category;

  SkillEntry({this.docId, required this.name, required this.category});

  factory SkillEntry.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return SkillEntry(docId: d.id, name: m['name'] ?? '', category: m['category'] ?? 'Other Skills');
  }

  Map<String, dynamic> toMap() => {
    'name': name, 'category': category,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

class CertEntry {
  final String? docId;
  final String name, issuer;

  CertEntry({this.docId, required this.name, required this.issuer});

  factory CertEntry.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return CertEntry(docId: d.id, name: m['name'] ?? '', issuer: m['issuer'] ?? 'Other');
  }

  Map<String, dynamic> toMap() => {
    'name': name, 'issuer': issuer,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

class ProjectEntry {
  final String? docId;
  final String name, url, description, status;
  final List<String> tags;

  ProjectEntry({this.docId, required this.name, required this.url,
      required this.description, this.status = 'Live', this.tags = const []});

  factory ProjectEntry.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return ProjectEntry(
      docId: d.id, name: m['name'] ?? '', url: m['url'] ?? '',
      description: m['description'] ?? '', status: m['status'] ?? 'Live',
      tags: List<String>.from(m['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name, 'url': url, 'description': description,
    'status': status, 'tags': tags,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

class ContactData {
  final String email, phone, address, instagram, facebook;

  ContactData({
    this.email = 'araos.adriel06@gmail.com',
    this.phone = '09493441883',
    this.address = 'Santa Rosa, Laguna, Philippines',
    this.instagram = 'https://www.instagram.com/iitzme_eydriyel/',
    this.facebook = 'https://www.facebook.com/adriel.araos.2024',
  });

  factory ContactData.fromMap(Map<String, dynamic> m) => ContactData(
    email: m['email'] ?? 'araos.adriel06@gmail.com',
    phone: m['phone'] ?? '09493441883',
    address: m['address'] ?? 'Santa Rosa, Laguna, Philippines',
    instagram: m['instagram'] ?? 'https://www.instagram.com/iitzme_eydriyel/',
    facebook: m['facebook'] ?? 'https://www.facebook.com/adriel.araos.2024',
  );

  Map<String, dynamic> toMap() => {
    'email': email, 'phone': phone, 'address': address,
    'instagram': instagram, 'facebook': facebook,
  };
}
