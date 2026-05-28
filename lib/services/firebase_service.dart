import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  // PHOTOS
  static Stream<List<PhotoEntry>> photosStream() => _db.collection('photos').orderBy('uploadedAt', descending: true).snapshots().map((s) => s.docs.map(PhotoEntry.fromDoc).toList());
  static Future<String?> addPhoto(PhotoEntry p) async { try { await _db.collection('photos').add(p.toMap()); return null; } catch (e) { return e.toString(); } }
  static Future<String?> removePhoto(String id) async { try { await _db.collection('photos').doc(id).delete(); return null; } catch (e) { return e.toString(); } }

  // PROFILE
  static Stream<String?> profilePhotoStream() => _db.collection('settings').doc('profile').snapshots().map((s) => s.data()?['photoUrl'] as String?);
  static Future<String?> setProfilePhoto(String url) async { try { await _db.collection('settings').doc('profile').set({'photoUrl': url}); return null; } catch (e) { return e.toString(); } }

  // SKILLS
  static Stream<List<SkillEntry>> skillsStream() => _db.collection('skills').orderBy('createdAt', descending: false).snapshots().map((s) => s.docs.map(SkillEntry.fromDoc).toList());
  static Future<String?> addSkill(SkillEntry s) async { try { await _db.collection('skills').add(s.toMap()); return null; } catch (e) { return e.toString(); } }
  static Future<String?> updateSkill(String id, SkillEntry s) async { try { await _db.collection('skills').doc(id).update({'name': s.name, 'category': s.category}); return null; } catch (e) { return e.toString(); } }
  static Future<String?> removeSkill(String id) async { try { await _db.collection('skills').doc(id).delete(); return null; } catch (e) { return e.toString(); } }

  // CERTIFICATES
  static Stream<List<CertEntry>> certsStream() => _db.collection('certificates').orderBy('createdAt', descending: false).snapshots().map((s) => s.docs.map(CertEntry.fromDoc).toList());
  static Future<String?> addCert(CertEntry c) async { try { await _db.collection('certificates').add(c.toMap()); return null; } catch (e) { return e.toString(); } }
  static Future<String?> updateCert(String id, CertEntry c) async { try { await _db.collection('certificates').doc(id).update({'name': c.name, 'issuer': c.issuer, 'imageUrl': c.imageUrl}); return null; } catch (e) { return e.toString(); } }
  static Future<String?> removeCert(String id) async { try { await _db.collection('certificates').doc(id).delete(); return null; } catch (e) { return e.toString(); } }

  // PROJECTS
  static Stream<List<ProjectEntry>> projectsStream() => _db.collection('projects').orderBy('createdAt', descending: false).snapshots().map((s) => s.docs.map(ProjectEntry.fromDoc).toList());
  static Future<String?> addProject(ProjectEntry p) async { try { await _db.collection('projects').add(p.toMap()); return null; } catch (e) { return e.toString(); } }
  static Future<String?> updateProject(String id, ProjectEntry p) async { try { await _db.collection('projects').doc(id).update({'name': p.name, 'url': p.url, 'description': p.description, 'status': p.status, 'tags': p.tags}); return null; } catch (e) { return e.toString(); } }
  static Future<String?> removeProject(String id) async { try { await _db.collection('projects').doc(id).delete(); return null; } catch (e) { return e.toString(); } }

  // HOBBIES
  static Stream<List<HobbyEntry>> hobbiesStream() => _db.collection('hobbies').orderBy('order', descending: false).snapshots().map((s) => s.docs.map(HobbyEntry.fromDoc).toList());
  static Future<String?> addHobby(HobbyEntry h) async { try { await _db.collection('hobbies').add(h.toMap()); return null; } catch (e) { return e.toString(); } }
  static Future<String?> updateHobby(String id, HobbyEntry h) async { try { await _db.collection('hobbies').doc(id).update({'name': h.name, 'desc': h.desc}); return null; } catch (e) { return e.toString(); } }
  static Future<String?> removeHobby(String id) async { try { await _db.collection('hobbies').doc(id).delete(); return null; } catch (e) { return e.toString(); } }

  // CONTACT
  static Stream<ContactData> contactStream() => _db.collection('settings').doc('contact').snapshots().map((s) => (!s.exists || s.data() == null) ? ContactData() : ContactData.fromMap(s.data()!));
  static Future<String?> updateContact(ContactData c) async { try { await _db.collection('settings').doc('contact').set(c.toMap()); return null; } catch (e) { return e.toString(); } }

  // MESSAGES
  static Future<String?> sendMessage(MessageEntry m) async { try { await _db.collection('messages').add(m.toMap()); return null; } catch (e) { return e.toString(); } }
  static Stream<List<MessageEntry>> messagesStream() => _db.collection('messages').orderBy('sentAt', descending: true).snapshots().map((s) => s.docs.map(MessageEntry.fromDoc).toList());
  static Future<String?> deleteMessage(String id) async { try { await _db.collection('messages').doc(id).delete(); return null; } catch (e) { return e.toString(); } }
  static Future<String?> markMessageRead(String id) async { try { await _db.collection('messages').doc(id).update({'read': true}); return null; } catch (e) { return e.toString(); } }
}

// ─── MODELS ──────────────────────────────────────────────────────

class PhotoEntry {
  final String? docId; final String publicId, url; final String? fileName; final int? width, height, bytes; final DateTime? uploadedAt;
  PhotoEntry({this.docId, required this.publicId, required this.url, this.fileName, this.width, this.height, this.bytes, this.uploadedAt});
  factory PhotoEntry.fromDoc(DocumentSnapshot d) { final m = d.data() as Map<String, dynamic>; return PhotoEntry(docId: d.id, publicId: m['publicId']??'', url: m['url']??'', fileName: m['fileName'], width: m['width'], height: m['height'], bytes: m['bytes'], uploadedAt: (m['uploadedAt'] as Timestamp?)?.toDate()); }
  Map<String, dynamic> toMap() => {'publicId': publicId, 'url': url, 'fileName': fileName, 'width': width, 'height': height, 'bytes': bytes, 'uploadedAt': uploadedAt != null ? Timestamp.fromDate(uploadedAt!) : FieldValue.serverTimestamp()};
  String get thumbnailUrl => 'https://res.cloudinary.com/diut63biv/image/upload/w_600,c_limit,q_auto/$publicId';
  String get name => fileName ?? publicId.split('/').last;
}

class SkillEntry {
  final String? docId; final String name, category;
  SkillEntry({this.docId, required this.name, required this.category});
  factory SkillEntry.fromDoc(DocumentSnapshot d) { final m = d.data() as Map<String, dynamic>; return SkillEntry(docId: d.id, name: m['name']??'', category: m['category']??'Other Skills'); }
  Map<String, dynamic> toMap() => {'name': name, 'category': category, 'createdAt': FieldValue.serverTimestamp()};
}

class CertEntry {
  final String? docId; final String name, issuer; final String? imageUrl;
  CertEntry({this.docId, required this.name, required this.issuer, this.imageUrl});
  factory CertEntry.fromDoc(DocumentSnapshot d) { final m = d.data() as Map<String, dynamic>; return CertEntry(docId: d.id, name: m['name']??'', issuer: m['issuer']??'Other', imageUrl: m['imageUrl'] as String?); }
  Map<String, dynamic> toMap() => {'name': name, 'issuer': issuer, 'imageUrl': imageUrl, 'createdAt': FieldValue.serverTimestamp()};
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}

class ProjectEntry {
  final String? docId; final String name, url, description, status; final List<String> tags;
  ProjectEntry({this.docId, required this.name, required this.url, required this.description, this.status='Live', this.tags=const[]});
  factory ProjectEntry.fromDoc(DocumentSnapshot d) { final m = d.data() as Map<String, dynamic>; return ProjectEntry(docId: d.id, name: m['name']??'', url: m['url']??'', description: m['description']??'', status: m['status']??'Live', tags: List<String>.from(m['tags']??[])); }
  Map<String, dynamic> toMap() => {'name': name, 'url': url, 'description': description, 'status': status, 'tags': tags, 'createdAt': FieldValue.serverTimestamp()};
}

class HobbyEntry {
  final String? docId; final String name, desc; final int order;
  HobbyEntry({this.docId, required this.name, required this.desc, this.order=99});
  factory HobbyEntry.fromDoc(DocumentSnapshot d) { final m = d.data() as Map<String, dynamic>; return HobbyEntry(docId: d.id, name: m['name']??'', desc: m['desc']??'', order: m['order']??99); }
  Map<String, dynamic> toMap() => {'name': name, 'desc': desc, 'order': order, 'createdAt': FieldValue.serverTimestamp()};
}

class ContactData {
  final String email, phone, address, instagram, facebook;
  ContactData({this.email='araos.adriel06@gmail.com', this.phone='09493441883', this.address='Santa Rosa, Laguna, Philippines', this.instagram='https://www.instagram.com/iitzme_eydriyel/', this.facebook='https://www.facebook.com/adriel.araos.2024'});
  factory ContactData.fromMap(Map<String, dynamic> m) => ContactData(email: m['email']??'araos.adriel06@gmail.com', phone: m['phone']??'09493441883', address: m['address']??'Santa Rosa, Laguna, Philippines', instagram: m['instagram']??'https://www.instagram.com/iitzme_eydriyel/', facebook: m['facebook']??'https://www.facebook.com/adriel.araos.2024');
  Map<String, dynamic> toMap() => {'email': email, 'phone': phone, 'address': address, 'instagram': instagram, 'facebook': facebook};
}

class MessageEntry {
  final String? docId;
  final String name, email, service, message;
  final DateTime? sentAt;
  final bool read;

  MessageEntry({this.docId, required this.name, required this.email, required this.service, required this.message, this.sentAt, this.read = false});

  factory MessageEntry.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return MessageEntry(
      docId: d.id,
      name: m['name'] ?? '',
      email: m['email'] ?? '',
      service: m['service'] ?? '',
      message: m['message'] ?? '',
      sentAt: (m['sentAt'] as Timestamp?)?.toDate(),
      read: m['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name, 'email': email, 'service': service,
    'message': message, 'read': read,
    'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : FieldValue.serverTimestamp(),
  };
}
