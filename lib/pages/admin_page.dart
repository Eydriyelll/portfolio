import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/cloudinary_service.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

const String _adminPassword = 'MidnightStar30';

// ═══════════════════════════════════════════════════════════════
// ENTRY
// ═══════════════════════════════════════════════════════════════
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override State<AdminPage> createState() => _AdminPageState();
}
class _AdminPageState extends State<AdminPage> {
  bool _authenticated = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.black,
    body: _authenticated
        ? _AdminShell(onLogout: () => setState(() => _authenticated = false))
        : _LoginScreen(onSuccess: () => setState(() => _authenticated = true)),
  );
}

// ═══════════════════════════════════════════════════════════════
// LOGIN
// ═══════════════════════════════════════════════════════════════
class _LoginScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const _LoginScreen({required this.onSuccess});
  @override State<_LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<_LoginScreen> {
  final _ctrl = TextEditingController();
  bool _obscure = true; String? _error;
  void _submit() {
    if (_ctrl.text == _adminPassword) { widget.onSuccess(); }
    else { setState(() => _error = 'Incorrect password.'); _ctrl.clear(); }
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 380, padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(color: AppTheme.surface, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(4)),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ADMIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.grey, letterSpacing: 3)),
        const SizedBox(height: 10),
        const Text('Portfolio Manager', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.white)),
        const SizedBox(height: 28),
        TextField(controller: _ctrl, obscureText: _obscure, style: const TextStyle(color: AppTheme.white, fontSize: 14), onSubmitted: (_) => _submit(),
          decoration: InputDecoration(hintText: 'Password', hintStyle: const TextStyle(color: AppTheme.greyDark), filled: true, fillColor: AppTheme.black,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppTheme.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppTheme.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppTheme.white)),
            suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppTheme.grey, size: 18), onPressed: () => setState(() => _obscure = !_obscure)),
          )),
        if (_error != null) ...[const SizedBox(height: 8), Text(_error!, style: const TextStyle(color: Color(0xFFFF5555), fontSize: 12))],
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: Material(color: AppTheme.white, borderRadius: BorderRadius.circular(4),
          child: InkWell(onTap: _submit, borderRadius: BorderRadius.circular(4),
            child: const Padding(padding: EdgeInsets.symmetric(vertical: 13),
              child: Center(child: Text('Enter', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.black))))))),
      ]),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1)),
  );
}

// ═══════════════════════════════════════════════════════════════
// SHELL
// ═══════════════════════════════════════════════════════════════
class _AdminShell extends StatefulWidget {
  final VoidCallback onLogout;
  const _AdminShell({required this.onLogout});
  @override State<_AdminShell> createState() => _AdminShellState();
}
class _AdminShellState extends State<_AdminShell> {
  int _tab = 0;
  final _tabs = ['Photos', 'Profile', 'Skills', 'Certs', 'Projects', 'Hobbies', 'Contact'];
  final _icons = [Icons.photo_library_outlined, Icons.person_outline, Icons.bolt_outlined, Icons.workspace_premium_outlined, Icons.code_outlined, Icons.favorite_outline, Icons.mail_outline];

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(children: [
      // Top bar
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('ADMIN', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.white)),
          Material(color: Colors.transparent, borderRadius: BorderRadius.circular(3),
            child: InkWell(onTap: widget.onLogout, borderRadius: BorderRadius.circular(3),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(3)),
                child: const Text('Logout', style: TextStyle(fontSize: 12, color: AppTheme.grey))))),
        ]),
      ),
      // Tab bar
      Container(height: 50,
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
        child: ListView.builder(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _tabs.length,
          itemBuilder: (_, i) => GestureDetector(onTap: () => setState(() => _tab = i),
            child: AnimatedContainer(duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _tab == i ? AppTheme.white : Colors.transparent,
                border: Border.all(color: _tab == i ? AppTheme.white : AppTheme.border),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_icons[i], size: 13, color: _tab == i ? AppTheme.black : AppTheme.grey),
                const SizedBox(width: 5),
                Text(_tabs[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _tab == i ? AppTheme.black : AppTheme.grey)),
              ]))),
        ),
      ),
      // Content
      Expanded(child: switch (_tab) {
        0 => const _PhotosTab(),
        1 => const _ProfileTab(),
        2 => const _SkillsTab(),
        3 => const _CertsTab(),
        4 => const _ProjectsTab(),
        5 => const _HobbiesTab(),
        6 => const _ContactTab(),
        _ => const SizedBox(),
      }),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════
// PHOTOS TAB
// ═══════════════════════════════════════════════════════════════
class _PhotosTab extends StatefulWidget {
  const _PhotosTab();
  @override State<_PhotosTab> createState() => _PhotosTabState();
}
class _PhotosTabState extends State<_PhotosTab> {
  List<_UploadTask> _tasks = []; bool _uploading = false;

  Future<void> _pick() async {
    final r = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['jpg','jpeg','png','raf','RAF'], withData: true);
    if (r == null) return;
    final valid = r.files.take(10).where((f) => f.size <= 10*1024*1024).toList();
    if (valid.isEmpty) { _snack('All files exceed 10MB.', isError: true); return; }
    setState(() { _tasks = valid.map((f) => _UploadTask(name: f.name, bytes: f.bytes!)).toList(); _uploading = true; });
    for (int i = 0; i < _tasks.length; i++) {
      setState(() => _tasks[i] = _tasks[i].copyWith(status: _UStatus.uploading));
      final res = await CloudinaryService.uploadPhoto(bytes: _tasks[i].bytes, fileName: _tasks[i].name, mimeType: 'image/jpeg');
      setState(() => _tasks[i] = _tasks[i].copyWith(status: res.success ? _UStatus.done : _UStatus.error, error: res.error));
    }
    setState(() => _uploading = false);
    final done = _tasks.where((t) => t.status == _UStatus.done).length;
    if (done > 0) _snack('$done photo${done > 1 ? 's' : ''} uploaded!');
  }

  void _snack(String msg, {bool isError = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: AppTheme.white)), backgroundColor: AppTheme.surface, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: isError ? const Color(0xFFFF5555) : AppTheme.border))));

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 20 : 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionTitle(title: 'Upload Photos', sub: 'JPG · PNG · RAF  ·  Max 10 files  ·  Max 10MB each'),
      const SizedBox(height: 20),
      _DropZone(onTap: _uploading ? null : _pick),
      if (_tasks.isNotEmpty) ...[
        const SizedBox(height: 20),
        ..._tasks.asMap().entries.map((e) => _UploadRow(task: e.value, index: e.key)),
        if (!_uploading) TextButton(onPressed: () => setState(() => _tasks = []), child: const Text('Clear queue', style: TextStyle(color: AppTheme.greyDark, fontSize: 12))),
      ],
      const SizedBox(height: 40),
      const _SectionTitle(title: 'Manage Photos', sub: 'Hover a photo and click Remove'),
      const SizedBox(height: 20),
      StreamBuilder<List<PhotoEntry>>(
        stream: FirebaseService.photosStream(),
        builder: (_, snap) {
          final photos = snap.data ?? [];
          if (photos.isEmpty) return const _EmptyBox(label: 'No photos yet');
          return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isMobile ? 2 : 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1),
            itemCount: photos.length,
            itemBuilder: (_, i) => _ManagePhotoCard(photo: photos[i], onDelete: () async {
              final ok = await showDialog<bool>(context: context, builder: (_) => const _ConfirmDialog(message: 'Remove this photo?')) ?? false;
              if (ok) { await FirebaseService.removePhoto(photos[i].docId!); _snack('Removed.'); }
            }));
        }),
      const SizedBox(height: 60),
    ]));
  }
}

// ═══════════════════════════════════════════════════════════════
// PROFILE TAB
// ═══════════════════════════════════════════════════════════════
class _ProfileTab extends StatefulWidget {
  const _ProfileTab();
  @override State<_ProfileTab> createState() => _ProfileTabState();
}
class _ProfileTabState extends State<_ProfileTab> {
  bool _uploading = false; String? _status; double _cropY = -0.2;

  Future<void> _pickAndUpload() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.image, withData: true, allowMultiple: false);
    if (r == null || r.files.isEmpty) return;
    final file = r.files.first;
    if (file.bytes == null) { setState(() => _status = '✗ Could not read file.'); return; }
    if (file.size > 10*1024*1024) { setState(() => _status = '✗ File exceeds 10MB.'); return; }
    setState(() { _uploading = true; _status = 'Uploading…'; });
    try {
      final res = await CloudinaryService.uploadProfilePhoto(bytes: file.bytes!, fileName: file.name)
          .timeout(const Duration(seconds: 30), onTimeout: () => CloudinaryUploadResult(success: false, error: 'Timed out.'));
      if (!mounted) return;
      if (res.success && res.url != null) {
        await FirebaseService.setProfilePhoto(res.url!);
        setState(() { _uploading = false; _status = '✓ Profile photo updated!'; });
      } else { setState(() { _uploading = false; _status = '✗ ${res.error ?? 'Upload failed'}'; }); }
    } catch (e) { if (mounted) setState(() { _uploading = false; _status = '✗ ${e.toString()}'; }); }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 20 : 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionTitle(title: 'Profile Photo', sub: 'Upload a new photo and adjust the crop'),
      const SizedBox(height: 32),
      Center(child: Column(children: [
        StreamBuilder<String?>(
          stream: FirebaseService.profilePhotoStream(),
          builder: (_, snap) {
            final url = snap.data;
            return Container(width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.border, width: 1.5)),
              child: ClipOval(child: url != null
                  ? Image.network(url, fit: BoxFit.cover, alignment: Alignment(0, _cropY))
                  : Image.asset('assets/images/profile.jpg', fit: BoxFit.cover, alignment: Alignment(0, _cropY))));
          }),
        const SizedBox(height: 8),
        const Text('Live preview', style: TextStyle(fontSize: 11, color: AppTheme.greyDark, letterSpacing: 1)),
        const SizedBox(height: 28),
        const Text('VERTICAL CROP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.grey, letterSpacing: 2)),
        const SizedBox(height: 8),
        SizedBox(width: 280, child: Row(children: [
          const Text('Top', style: TextStyle(fontSize: 11, color: AppTheme.greyDark)),
          Expanded(child: SliderTheme(
            data: SliderTheme.of(context).copyWith(activeTrackColor: AppTheme.white, inactiveTrackColor: AppTheme.border, thumbColor: AppTheme.white, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6), overlayShape: SliderComponentShape.noOverlay),
            child: Slider(value: _cropY, min: -1.0, max: 1.0, onChanged: (v) => setState(() => _cropY = v)))),
          const Text('Bottom', style: TextStyle(fontSize: 11, color: AppTheme.greyDark)),
        ])),
        const SizedBox(height: 28),
        Material(color: _uploading ? AppTheme.border : AppTheme.white, borderRadius: BorderRadius.circular(4),
          child: InkWell(onTap: _uploading ? null : _pickAndUpload, borderRadius: BorderRadius.circular(4),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (_uploading) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.grey))
                else const Icon(Icons.upload_outlined, size: 16, color: AppTheme.black),
                const SizedBox(width: 8),
                Text(_uploading ? 'Uploading…' : 'Choose & Upload Photo',
                  style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 13, fontWeight: FontWeight.w600, color: _uploading ? AppTheme.grey : AppTheme.black)),
              ])))),
        if (_status != null) ...[
          const SizedBox(height: 14),
          Text(_status!, style: TextStyle(fontSize: 13, color: _status!.startsWith('✓') ? const Color(0xFF4ADE80) : const Color(0xFFFF5555))),
        ],
        const SizedBox(height: 12),
        const Text('JPG or PNG · Max 10MB\nChanges apply live across your portfolio.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppTheme.greyDark, height: 1.6)),
      ])),
      const SizedBox(height: 60),
    ]));
  }
}

// ═══════════════════════════════════════════════════════════════
// SKILLS TAB
// ═══════════════════════════════════════════════════════════════
class _SkillsTab extends StatefulWidget {
  const _SkillsTab();
  @override State<_SkillsTab> createState() => _SkillsTabState();
}
class _SkillsTabState extends State<_SkillsTab> {
  final _nameCtrl = TextEditingController();
  String _category = 'Languages';
  final _cats = ['Languages', 'Frameworks & Libraries', 'Tools & Platforms', 'Other Skills'];
  SkillEntry? _editing;

  void _snack(String msg, {bool isError = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: AppTheme.white)), backgroundColor: AppTheme.surface, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: isError ? const Color(0xFFFF5555) : AppTheme.border))));

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) { _snack('Enter a skill name.', isError: true); return; }
    if (_editing != null) {
      final err = await FirebaseService.updateSkill(_editing!.docId!, SkillEntry(name: name, category: _category));
      if (err != null) { _snack('Error: $err', isError: true); return; }
      setState(() => _editing = null);
      _snack('Skill updated!');
    } else {
      final err = await FirebaseService.addSkill(SkillEntry(name: name, category: _category));
      if (err != null) { _snack('Error: $err', isError: true); return; }
      _snack('Skill added!');
    }
    _nameCtrl.clear();
  }

  void _startEdit(SkillEntry s) {
    setState(() { _editing = s; _category = s.category; });
    _nameCtrl.text = s.name;
  }

  @override void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 20 : 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle(title: _editing != null ? 'Edit Skill' : 'Add Skill', sub: 'Changes appear live on the Skills page'),
      if (_editing != null) _EditingBanner(label: 'Editing: ${_editing!.name}', onCancel: () { setState(() => _editing = null); _nameCtrl.clear(); }),
      const SizedBox(height: 16),
      const _FieldLabel('Skill Name'),
      _StyledTextField(controller: _nameCtrl, hint: 'e.g. Node.js'),
      const SizedBox(height: 12),
      const _FieldLabel('Category'),
      Wrap(spacing: 8, runSpacing: 8, children: _cats.map((c) => _ChoiceChip(label: c, selected: _category == c, onTap: () => setState(() => _category = c))).toList()),
      const SizedBox(height: 20),
      _SaveButton(label: _editing != null ? 'Update Skill' : 'Add Skill', onTap: _save),
      const SizedBox(height: 40),
      const _SectionTitle(title: 'All Skills', sub: 'Tap the edit icon to modify any skill'),
      const SizedBox(height: 16),
      StreamBuilder<List<SkillEntry>>(
        stream: FirebaseService.skillsStream(),
        builder: (_, snap) {
          final items = snap.data ?? [];
          if (items.isEmpty) return const _EmptyBox(label: 'No skills yet');
          return Column(children: items.map((s) => _EditableRow(
            label: s.name, sublabel: s.category,
            onEdit: () => _startEdit(s),
            onDelete: () async {
              final ok = await showDialog<bool>(context: context, builder: (_) => _ConfirmDialog(message: 'Remove "${s.name}"?')) ?? false;
              if (ok) { await FirebaseService.removeSkill(s.docId!); _snack('Removed.'); }
            },
          )).toList());
        }),
      const SizedBox(height: 60),
    ]));
  }
}

// ═══════════════════════════════════════════════════════════════
// CERTS TAB
// ═══════════════════════════════════════════════════════════════
class _CertsTab extends StatefulWidget {
  const _CertsTab();
  @override State<_CertsTab> createState() => _CertsTabState();
}
class _CertsTabState extends State<_CertsTab> {
  final _nameCtrl = TextEditingController();
  String _issuer = 'MMCL';
  final _customCtrl = TextEditingController();
  Uint8List? _imgBytes; String? _imgFileName;
  bool _saving = false;
  CertEntry? _editing;

  void _snack(String msg, {bool isError = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: AppTheme.white)), backgroundColor: AppTheme.surface, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: isError ? const Color(0xFFFF5555) : AppTheme.border))));

  Future<void> _pickImage() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true, allowMultiple: false);
    if (r == null || r.files.isEmpty) return;
    final f = r.files.first;
    if (f.bytes == null) return;
    if (f.size > 10*1024*1024) { _snack('File exceeds 10MB.', isError: true); return; }
    setState(() { _imgBytes = f.bytes; _imgFileName = f.name; });
    _snack('Image selected: ${f.name}');
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) { _snack('Enter a certificate name.', isError: true); return; }
    setState(() => _saving = true);
    String? imageUrl = _editing?.imageUrl;
    if (_imgBytes != null && _imgFileName != null) {
      _snack('Uploading image…');
      final res = await CloudinaryService.uploadCertificateImage(bytes: _imgBytes!, fileName: _imgFileName!);
      if (!res.success) { setState(() => _saving = false); _snack('Image upload failed: ${res.error}', isError: true); return; }
      imageUrl = res.url;
    }
    final issuer = _issuer == 'New' ? (_customCtrl.text.trim().isEmpty ? 'Other' : _customCtrl.text.trim()) : _issuer;
    String? err;
    if (_editing != null) {
      err = await FirebaseService.updateCert(_editing!.docId!, CertEntry(name: name, issuer: issuer, imageUrl: imageUrl));
      if (err == null) { setState(() => _editing = null); _snack('Certificate updated!'); }
    } else {
      err = await FirebaseService.addCert(CertEntry(name: name, issuer: issuer, imageUrl: imageUrl));
      if (err == null) _snack('Certificate added!${imageUrl != null ? ' (with image)' : ''}');
    }
    if (err != null) _snack('Error: $err', isError: true);
    setState(() { _saving = false; _imgBytes = null; _imgFileName = null; });
    _nameCtrl.clear(); _customCtrl.clear();
  }

  void _startEdit(CertEntry c) {
    setState(() { _editing = c; _issuer = ['MMCL','Coursera'].contains(c.issuer) ? c.issuer : 'New'; });
    _nameCtrl.text = c.name;
    if (!['MMCL','Coursera'].contains(c.issuer)) _customCtrl.text = c.issuer;
  }

  @override void dispose() { _nameCtrl.dispose(); _customCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 20 : 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle(title: _editing != null ? 'Edit Certificate' : 'Add Certificate', sub: 'Upload a JPG/PNG image of your certificate to make it viewable'),
      if (_editing != null) _EditingBanner(label: 'Editing: ${_editing!.name}', onCancel: () { setState(() => _editing = null); _nameCtrl.clear(); _customCtrl.clear(); }),
      const SizedBox(height: 16),
      const _FieldLabel('Certificate Name'),
      _StyledTextField(controller: _nameCtrl, hint: 'e.g. Introduction to AI'),
      const SizedBox(height: 12),
      const _FieldLabel('Issuer / Section'),
      Wrap(spacing: 8, runSpacing: 8, children: ['MMCL','Coursera','New'].map((s) => _ChoiceChip(label: s == 'New' ? '+ New Section' : s, selected: _issuer == s, onTap: () => setState(() => _issuer = s))).toList()),
      if (_issuer == 'New') ...[const SizedBox(height: 10), _StyledTextField(controller: _customCtrl, hint: 'Section name (e.g. Google)')],
      const SizedBox(height: 14),
      const _FieldLabel('Certificate Image (Optional — JPG or PNG)'),
      Row(children: [
        Material(color: Colors.transparent, borderRadius: BorderRadius.circular(4),
          child: InkWell(onTap: _pickImage, borderRadius: BorderRadius.circular(4),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(border: Border.all(color: _imgBytes != null ? const Color(0xFF4ADE80) : AppTheme.border), borderRadius: BorderRadius.circular(4)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_imgBytes != null ? Icons.image_outlined : Icons.upload_file_outlined, size: 15, color: _imgBytes != null ? const Color(0xFF4ADE80) : AppTheme.grey),
                const SizedBox(width: 7),
                Text(_imgBytes != null ? (_imgFileName ?? 'Image selected') : 'Choose Image (JPG / PNG)', style: TextStyle(fontSize: 13, color: _imgBytes != null ? const Color(0xFF4ADE80) : AppTheme.grey)),
              ])))),
        if (_imgBytes != null) ...[const SizedBox(width: 8),
          IconButton(onPressed: () => setState(() { _imgBytes = null; _imgFileName = null; }), icon: const Icon(Icons.close, size: 16, color: AppTheme.greyDark))],
        if (_editing?.hasImage == true && _imgBytes == null) ...[const SizedBox(width: 8),
          const Text('Current image kept', style: TextStyle(fontSize: 11, color: Color(0xFF4ADE80)))],
      ]),
      const SizedBox(height: 6),
      const Text('Upload a photo or scan of your certificate. Stored in portfolio/certificates folder. Max 10MB.', style: TextStyle(fontSize: 11, color: AppTheme.greyDark)),
      const SizedBox(height: 20),
      _SaveButton(label: _editing != null ? 'Update Certificate' : 'Add Certificate', loading: _saving, onTap: _saving ? null : _save),
      const SizedBox(height: 40),
      const _SectionTitle(title: 'All Certificates', sub: 'Tap the edit icon to modify'),
      const SizedBox(height: 16),
      StreamBuilder<List<CertEntry>>(
        stream: FirebaseService.certsStream(),
        builder: (_, snap) {
          final items = snap.data ?? [];
          if (items.isEmpty) return const _EmptyBox(label: 'No certificates yet');
          return Column(children: items.map((c) => _EditableRow(
            label: c.name, sublabel: '${c.issuer}${c.hasImage ? '  ·  Has PDF' : ''}',
            onEdit: () => _startEdit(c),
            onDelete: () async {
              final ok = await showDialog<bool>(context: context, builder: (_) => _ConfirmDialog(message: 'Remove "${c.name}"?')) ?? false;
              if (ok) { await FirebaseService.removeCert(c.docId!); _snack('Removed.'); }
            },
          )).toList());
        }),
      const SizedBox(height: 60),
    ]));
  }
}

// ═══════════════════════════════════════════════════════════════
// PROJECTS TAB
// ═══════════════════════════════════════════════════════════════
class _ProjectsTab extends StatefulWidget {
  const _ProjectsTab();
  @override State<_ProjectsTab> createState() => _ProjectsTabState();
}
class _ProjectsTabState extends State<_ProjectsTab> {
  final _nameCtrl = TextEditingController(), _urlCtrl = TextEditingController(),
      _descCtrl = TextEditingController(), _tagsCtrl = TextEditingController();
  String _status = 'Live';
  ProjectEntry? _editing;

  void _snack(String msg, {bool isError = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: AppTheme.white)), backgroundColor: AppTheme.surface, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: isError ? const Color(0xFFFF5555) : AppTheme.border))));

  Future<void> _save() async {
    final name = _nameCtrl.text.trim(), url = _urlCtrl.text.trim();
    if (name.isEmpty) { _snack('Enter a project name.', isError: true); return; }
    if (url.isEmpty) { _snack('Enter a project URL.', isError: true); return; }
    final tags = _tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    final p = ProjectEntry(name: name, url: url, description: _descCtrl.text.trim(), status: _status, tags: tags);
    String? err;
    if (_editing != null) { err = await FirebaseService.updateProject(_editing!.docId!, p); if (err == null) { setState(() => _editing = null); _snack('Project updated!'); } }
    else { err = await FirebaseService.addProject(p); if (err == null) _snack('Project added!'); }
    if (err != null) { _snack('Error: $err', isError: true); return; }
    _nameCtrl.clear(); _urlCtrl.clear(); _descCtrl.clear(); _tagsCtrl.clear();
  }

  void _startEdit(ProjectEntry p) {
    setState(() { _editing = p; _status = p.status; });
    _nameCtrl.text = p.name; _urlCtrl.text = p.url;
    _descCtrl.text = p.description; _tagsCtrl.text = p.tags.join(', ');
  }

  @override void dispose() { _nameCtrl.dispose(); _urlCtrl.dispose(); _descCtrl.dispose(); _tagsCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 20 : 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle(title: _editing != null ? 'Edit Project' : 'Add Project', sub: 'Changes appear live on the Projects page'),
      if (_editing != null) _EditingBanner(label: 'Editing: ${_editing!.name}', onCancel: () { setState(() => _editing = null); _nameCtrl.clear(); _urlCtrl.clear(); _descCtrl.clear(); _tagsCtrl.clear(); }),
      const SizedBox(height: 16),
      const _FieldLabel('Project Name'),
      _StyledTextField(controller: _nameCtrl, hint: 'My Project'),
      const SizedBox(height: 10),
      const _FieldLabel('URL'),
      _StyledTextField(controller: _urlCtrl, hint: 'https://...'),
      const SizedBox(height: 10),
      const _FieldLabel('Description'),
      _StyledTextField(controller: _descCtrl, hint: 'Short description', maxLines: 3),
      const SizedBox(height: 10),
      const _FieldLabel('Tags (comma-separated)'),
      _StyledTextField(controller: _tagsCtrl, hint: 'React, Vercel, Web App'),
      const SizedBox(height: 12),
      const _FieldLabel('Status'),
      Wrap(spacing: 8, runSpacing: 8, children: ['Live','In Progress','Archived'].map((s) => _ChoiceChip(label: s, selected: _status == s, onTap: () => setState(() => _status = s))).toList()),
      const SizedBox(height: 20),
      _SaveButton(label: _editing != null ? 'Update Project' : 'Add Project', onTap: _save),
      const SizedBox(height: 40),
      const _SectionTitle(title: 'All Projects', sub: 'Tap the edit icon to modify'),
      const SizedBox(height: 16),
      StreamBuilder<List<ProjectEntry>>(
        stream: FirebaseService.projectsStream(),
        builder: (_, snap) {
          final items = snap.data ?? [];
          if (items.isEmpty) return const _EmptyBox(label: 'No projects yet');
          return Column(children: items.map((p) => _EditableRow(
            label: p.name, sublabel: p.url,
            onEdit: () => _startEdit(p),
            onDelete: () async {
              final ok = await showDialog<bool>(context: context, builder: (_) => _ConfirmDialog(message: 'Remove "${p.name}"?')) ?? false;
              if (ok) { await FirebaseService.removeProject(p.docId!); _snack('Removed.'); }
            },
          )).toList());
        }),
      const SizedBox(height: 60),
    ]));
  }
}

// ═══════════════════════════════════════════════════════════════
// HOBBIES TAB
// ═══════════════════════════════════════════════════════════════
class _HobbiesTab extends StatefulWidget {
  const _HobbiesTab();
  @override State<_HobbiesTab> createState() => _HobbiesTabState();
}
class _HobbiesTabState extends State<_HobbiesTab> {
  final _nameCtrl = TextEditingController(), _descCtrl = TextEditingController();
  HobbyEntry? _editing;

  void _snack(String msg, {bool isError = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: AppTheme.white)), backgroundColor: AppTheme.surface, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: isError ? const Color(0xFFFF5555) : AppTheme.border))));

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) { _snack('Enter a hobby name.', isError: true); return; }
    String? err;
    if (_editing != null) {
      err = await FirebaseService.updateHobby(_editing!.docId!, HobbyEntry(name: name, desc: _descCtrl.text.trim(), order: _editing!.order));
      if (err == null) { setState(() => _editing = null); _snack('Hobby updated!'); }
    } else {
      err = await FirebaseService.addHobby(HobbyEntry(name: name, desc: _descCtrl.text.trim()));
      if (err == null) _snack('Hobby added!');
    }
    if (err != null) { _snack('Error: $err', isError: true); return; }
    _nameCtrl.clear(); _descCtrl.clear();
  }

  void _startEdit(HobbyEntry h) {
    setState(() => _editing = h);
    _nameCtrl.text = h.name; _descCtrl.text = h.desc;
  }

  @override void dispose() { _nameCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 20 : 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle(title: _editing != null ? 'Edit Hobby' : 'Add Hobby', sub: 'Changes appear live on the Hobbies page'),
      if (_editing != null) _EditingBanner(label: 'Editing: ${_editing!.name}', onCancel: () { setState(() => _editing = null); _nameCtrl.clear(); _descCtrl.clear(); }),
      const SizedBox(height: 16),
      const _FieldLabel('Hobby Name'),
      _StyledTextField(controller: _nameCtrl, hint: 'e.g. Hiking'),
      const SizedBox(height: 10),
      const _FieldLabel('Description'),
      _StyledTextField(controller: _descCtrl, hint: 'Short description', maxLines: 3),
      const SizedBox(height: 20),
      _SaveButton(label: _editing != null ? 'Update Hobby' : 'Add Hobby', onTap: _save),
      const SizedBox(height: 40),
      const _SectionTitle(title: 'All Hobbies', sub: 'Tap the edit icon to modify'),
      const SizedBox(height: 16),
      StreamBuilder<List<HobbyEntry>>(
        stream: FirebaseService.hobbiesStream(),
        builder: (_, snap) {
          final items = snap.data ?? [];
          if (items.isEmpty) return const _EmptyBox(label: 'No hobbies yet');
          return Column(children: items.map((h) => _EditableRow(
            label: h.name, sublabel: h.desc,
            onEdit: () => _startEdit(h),
            onDelete: () async {
              final ok = await showDialog<bool>(context: context, builder: (_) => _ConfirmDialog(message: 'Remove "${h.name}"?')) ?? false;
              if (ok) { await FirebaseService.removeHobby(h.docId!); _snack('Removed.'); }
            },
          )).toList());
        }),
      const SizedBox(height: 60),
    ]));
  }
}

// ═══════════════════════════════════════════════════════════════
// CONTACT TAB
// ═══════════════════════════════════════════════════════════════
class _ContactTab extends StatefulWidget {
  const _ContactTab();
  @override State<_ContactTab> createState() => _ContactTabState();
}
class _ContactTabState extends State<_ContactTab> {
  final _emailCtrl = TextEditingController(), _phoneCtrl = TextEditingController(),
      _addressCtrl = TextEditingController(), _igCtrl = TextEditingController(), _fbCtrl = TextEditingController();
  bool _loaded = false, _saving = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final c = await FirebaseService.contactStream().first.timeout(const Duration(seconds: 6), onTimeout: () => ContactData());
      if (!mounted) return;
      _emailCtrl.text = c.email; _phoneCtrl.text = c.phone; _addressCtrl.text = c.address;
      _igCtrl.text = c.instagram; _fbCtrl.text = c.facebook;
    } catch (_) {
      if (!mounted) return;
      final c = ContactData();
      _emailCtrl.text = c.email; _phoneCtrl.text = c.phone; _addressCtrl.text = c.address;
      _igCtrl.text = c.instagram; _fbCtrl.text = c.facebook;
    }
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final err = await FirebaseService.updateContact(ContactData(email: _emailCtrl.text.trim(), phone: _phoneCtrl.text.trim(), address: _addressCtrl.text.trim(), instagram: _igCtrl.text.trim(), facebook: _fbCtrl.text.trim()));
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err != null ? 'Error: $err' : 'Contact info saved!', style: const TextStyle(color: AppTheme.white)),
      backgroundColor: AppTheme.surface, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: err != null ? const Color(0xFFFF5555) : AppTheme.border))));
  }

  @override void dispose() { _emailCtrl.dispose(); _phoneCtrl.dispose(); _addressCtrl.dispose(); _igCtrl.dispose(); _fbCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    if (!_loaded) return const Center(child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 1));
    return SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 20 : 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionTitle(title: 'Update Contact Info', sub: 'Changes apply live on the Contact page'),
      const SizedBox(height: 24),
      const _FieldLabel('Email'), _StyledTextField(controller: _emailCtrl, hint: 'your@email.com'),
      const SizedBox(height: 12),
      const _FieldLabel('Phone'), _StyledTextField(controller: _phoneCtrl, hint: '09XXXXXXXXX'),
      const SizedBox(height: 12),
      const _FieldLabel('Address'), _StyledTextField(controller: _addressCtrl, hint: 'City, Province, Country'),
      const SizedBox(height: 12),
      const _FieldLabel('Instagram URL'), _StyledTextField(controller: _igCtrl, hint: 'https://instagram.com/...'),
      const SizedBox(height: 12),
      const _FieldLabel('Facebook URL'), _StyledTextField(controller: _fbCtrl, hint: 'https://facebook.com/...'),
      const SizedBox(height: 24),
      _SaveButton(label: 'Save Changes', loading: _saving, onTap: _saving ? null : _save),
      const SizedBox(height: 60),
    ]));
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String title, sub;
  const _SectionTitle({required this.title, required this.sub});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.white)),
    const SizedBox(height: 3),
    Text(sub, style: const TextStyle(fontSize: 12, color: AppTheme.greyDark)),
  ]);
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 6),
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.grey, letterSpacing: 1)));
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller; final String hint; final int maxLines;
  const _StyledTextField({required this.controller, required this.hint, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => TextField(controller: controller, maxLines: maxLines,
    style: const TextStyle(color: AppTheme.white, fontSize: 14),
    decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppTheme.greyDark),
      filled: true, fillColor: AppTheme.surface, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppTheme.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppTheme.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppTheme.white))));
}

class _ChoiceChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _ChoiceChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppTheme.white : Colors.transparent,
    borderRadius: BorderRadius.circular(3),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(3),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(border: Border.all(color: selected ? AppTheme.white : AppTheme.border), borderRadius: BorderRadius.circular(3)),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? AppTheme.black : AppTheme.grey)))));
}

class _SaveButton extends StatelessWidget {
  final String label; final VoidCallback? onTap; final bool loading;
  const _SaveButton({required this.label, required this.onTap, this.loading = false});
  @override
  Widget build(BuildContext context) => Material(
    color: loading || onTap == null ? AppTheme.border : AppTheme.white,
    borderRadius: BorderRadius.circular(4),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(4),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (loading) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.grey))
          else const Icon(Icons.check, size: 15, color: AppTheme.black),
          const SizedBox(width: 7),
          Text(loading ? 'Saving…' : label, style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 13, fontWeight: FontWeight.w700, color: loading ? AppTheme.grey : AppTheme.black)),
        ]))));
}

class _EditingBanner extends StatelessWidget {
  final String label; final VoidCallback onCancel;
  const _EditingBanner({required this.label, required this.onCancel});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 10, bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: BoxDecoration(color: const Color(0xFFFBBF24).withOpacity(0.1), border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.4)), borderRadius: BorderRadius.circular(4)),
    child: Row(children: [
      const Icon(Icons.edit_outlined, size: 14, color: Color(0xFFFBBF24)),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFFBBF24)))),
      Material(color: Colors.transparent,
        child: InkWell(onTap: onCancel, child: const Padding(padding: EdgeInsets.all(4), child: Text('Cancel', style: TextStyle(fontSize: 11, color: Color(0xFFFBBF24), decoration: TextDecoration.underline))))),
    ]),
  );
}

class _EditableRow extends StatelessWidget {
  final String label, sublabel; final VoidCallback onEdit, onDelete;
  const _EditableRow({required this.label, required this.sublabel, required this.onEdit, required this.onDelete});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(color: AppTheme.surface, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(4)),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.white, fontWeight: FontWeight.w500)),
        Text(sublabel, style: const TextStyle(fontSize: 11, color: AppTheme.greyDark), maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
      Material(color: Colors.transparent, borderRadius: BorderRadius.circular(3),
        child: InkWell(onTap: onEdit, borderRadius: BorderRadius.circular(3),
          child: Container(padding: const EdgeInsets.all(6), child: const Icon(Icons.edit_outlined, size: 14, color: AppTheme.grey)))),
      const SizedBox(width: 4),
      Material(color: Colors.transparent, borderRadius: BorderRadius.circular(3),
        child: InkWell(onTap: onDelete, borderRadius: BorderRadius.circular(3),
          child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(3)),
            child: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFFF5555))))),
    ]),
  );
}

class _EmptyBox extends StatelessWidget {
  final String label;
  const _EmptyBox({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(4)),
    child: Center(child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.greyDark))));
}

class _ConfirmDialog extends StatelessWidget {
  final String message;
  const _ConfirmDialog({required this.message});
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppTheme.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: AppTheme.border)),
    content: Text(message, style: const TextStyle(color: AppTheme.grey, fontSize: 13)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.grey))),
      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove', style: TextStyle(color: Color(0xFFFF5555)))),
    ]);
}

class _ManagePhotoCard extends StatefulWidget {
  final PhotoEntry photo; final VoidCallback onDelete;
  const _ManagePhotoCard({required this.photo, required this.onDelete});
  @override State<_ManagePhotoCard> createState() => _ManagePhotoCardState();
}
class _ManagePhotoCardState extends State<_ManagePhotoCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: ClipRRect(borderRadius: BorderRadius.circular(3),
      child: Stack(fit: StackFit.expand, children: [
        CachedNetworkImage(imageUrl: widget.photo.thumbnailUrl, fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppTheme.surface, child: const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1, color: AppTheme.greyDark)))),
          errorWidget: (_, __, ___) => Container(color: AppTheme.surface, child: const Icon(Icons.broken_image_outlined, color: AppTheme.greyDark))),
        AnimatedOpacity(opacity: _hovered ? 1 : 0, duration: const Duration(milliseconds: 180),
          child: Container(color: Colors.black.withOpacity(0.6),
            child: Center(child: Material(color: const Color(0xFFFF5555).withOpacity(0.9), borderRadius: BorderRadius.circular(3),
              child: InkWell(onTap: widget.onDelete, borderRadius: BorderRadius.circular(3),
                child: const Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.delete_outline, color: Colors.white, size: 13),
                    SizedBox(width: 4),
                    Text('Remove', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ]))))))),
      ])));
}

class _DropZone extends StatefulWidget {
  final VoidCallback? onTap;
  const _DropZone({this.onTap});
  @override State<_DropZone> createState() => _DropZoneState();
}
class _DropZoneState extends State<_DropZone> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(onTap: widget.onTap,
      child: AnimatedContainer(duration: const Duration(milliseconds: 180),
        width: double.infinity, height: 180,
        decoration: BoxDecoration(color: _hovered ? AppTheme.surface : AppTheme.black, border: Border.all(color: _hovered ? AppTheme.greyDark : AppTheme.border), borderRadius: BorderRadius.circular(4)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.cloud_upload_outlined, size: 32, color: _hovered ? AppTheme.white : AppTheme.greyDark),
          const SizedBox(height: 12),
          Text(widget.onTap == null ? 'Uploading…' : 'Click to select photos', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, fontWeight: FontWeight.w600, color: _hovered ? AppTheme.white : AppTheme.grey)),
          const SizedBox(height: 4),
          const Text('Up to 10 photos', style: TextStyle(fontSize: 11, color: AppTheme.greyDark)),
        ]))));
}

enum _UStatus { pending, uploading, done, error }
class _UploadTask {
  final String name; final Uint8List bytes; final _UStatus status; final String? error;
  const _UploadTask({required this.name, required this.bytes, this.status = _UStatus.pending, this.error});
  _UploadTask copyWith({_UStatus? status, String? error}) => _UploadTask(name: name, bytes: bytes, status: status ?? this.status, error: error ?? this.error);
}

class _UploadRow extends StatelessWidget {
  final _UploadTask task; final int index;
  const _UploadRow({required this.task, required this.index});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(color: AppTheme.surface, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(4)),
    child: Row(children: [
      SizedBox(width: 20, height: 20, child: switch (task.status) {
        _UStatus.pending => const Icon(Icons.schedule, size: 15, color: AppTheme.greyDark),
        _UStatus.uploading => const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.white)),
        _UStatus.done => const Icon(Icons.check_circle_outline, size: 15, color: Color(0xFF4ADE80)),
        _UStatus.error => const Icon(Icons.error_outline, size: 15, color: Color(0xFFFF5555)),
      }),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(task.name, style: const TextStyle(fontSize: 13, color: AppTheme.white), overflow: TextOverflow.ellipsis),
        if (task.error != null) Text(task.error!, style: const TextStyle(fontSize: 11, color: Color(0xFFFF5555))),
      ])),
      Text('${(task.bytes.length / 1024 / 1024).toStringAsFixed(1)} MB', style: const TextStyle(fontSize: 11, color: AppTheme.greyDark)),
    ])).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms);
}

// ═══════════════════════════════════════════════════════════════
// MESSAGES TAB
// ═══════════════════════════════════════════════════════════════
class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return StreamBuilder<List<MessageEntry>>(
      stream: FirebaseService.messagesStream(),
      builder: (context, snap) {
        final messages = snap.data ?? [];
        final unread = messages.where((m) => !m.read).length;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const _SectionTitle(
                title: 'Inbox',
                sub: 'Messages sent via the contact form',
              ),
              if (unread > 0) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.4)),
                  ),
                  child: Text(
                    '$unread new',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: Color(0xFF4ADE80), letterSpacing: 0.5),
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 24),

            if (snap.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 1))
            else if (messages.isEmpty)
              const _EmptyBox(label: 'No messages yet — they\'ll appear here when someone contacts you.')
            else
              ...messages.map((m) => _MessageCard(message: m, context: context)),

            const SizedBox(height: 60),
          ]),
        );
      },
    );
  }
}

class _MessageCard extends StatefulWidget {
  final MessageEntry message;
  final BuildContext context;
  const _MessageCard({required this.message, required this.context});

  @override
  State<_MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<_MessageCard> {
  bool _expanded = false;

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    final isUnread = !m.read;

    return GestureDetector(
      onTap: () async {
        setState(() => _expanded = !_expanded);
        if (isUnread && m.docId != null) {
          await FirebaseService.markMessageRead(m.docId!);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isUnread ? AppTheme.surface : AppTheme.black,
          border: Border.all(
            color: isUnread ? AppTheme.greyDark : AppTheme.border,
            width: isUnread ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              // Unread dot
              if (isUnread)
                Container(
                  width: 7, height: 7,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ADE80), shape: BoxShape.circle),
                ),
              // Avatar circle
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.border, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppTheme.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(m.name, style: TextStyle(
                    fontSize: 14, fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                    color: AppTheme.white,
                  )),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
                    child: Text(m.service, style: const TextStyle(
                      fontSize: 10, color: AppTheme.grey, letterSpacing: 0.3)),
                  ),
                ]),
                const SizedBox(height: 2),
                Text(m.email, style: const TextStyle(fontSize: 11, color: AppTheme.greyDark)),
              ])),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_timeAgo(m.sentAt), style: const TextStyle(
                  fontSize: 11, color: AppTheme.greyDark)),
                const SizedBox(height: 4),
                Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 16, color: AppTheme.greyDark),
              ]),
            ]),
          ),

          // Message preview (collapsed)
          if (!_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(m.message,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppTheme.greyDark)),
            ),

          // Expanded message
          if (_expanded) ...[
            const Divider(color: AppTheme.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.message, style: const TextStyle(
                  fontSize: 14, color: AppTheme.grey, height: 1.7)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  // Reply by email
                  Material(color: AppTheme.white, borderRadius: BorderRadius.circular(3),
                    child: InkWell(
                      onTap: () async {
                        final uri = Uri(scheme: 'mailto', path: m.email,
                          queryParameters: {'subject': 'Re: Your message via portfolio'});
                        await launchUrl(uri);
                      },
                      borderRadius: BorderRadius.circular(3),
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(mainAxisSize: MainAxisSize.min, children: const [
                          Icon(Icons.reply_outlined, size: 14, color: AppTheme.black),
                          SizedBox(width: 6),
                          Text('Reply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.black)),
                        ])),
                    )),
                  const SizedBox(width: 8),
                  // Delete
                  Material(color: Colors.transparent, borderRadius: BorderRadius.circular(3),
                    child: InkWell(
                      onTap: () async {
                        final ok = await showDialog<bool>(context: context,
                          builder: (_) => const _ConfirmDialog(message: 'Delete this message?')) ?? false;
                        if (ok && m.docId != null) {
                          await FirebaseService.deleteMessage(m.docId!);
                        }
                      },
                      borderRadius: BorderRadius.circular(3),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.border),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFFF5555)),
                      ),
                    )),
                ]),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
