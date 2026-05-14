import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cloudinary_service.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

const String _adminPassword = 'MidnightStar30';

// ─── ENTRY ───────────────────────────────────────────────────────
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
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

// ─── LOGIN ────────────────────────────────────────────────────────
class _LoginScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const _LoginScreen({required this.onSuccess});
  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  final _ctrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  void _submit() {
    if (_ctrl.text == _adminPassword) {
      widget.onSuccess();
    } else {
      setState(() => _error = 'Incorrect password.');
      _ctrl.clear();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 380, padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(color: AppTheme.surface,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(4)),
      child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ADMIN', style: TextStyle(fontSize: 10,
            fontWeight: FontWeight.w700, color: AppTheme.grey, letterSpacing: 3)),
        const SizedBox(height: 10),
        const Text('Portfolio Manager', style: TextStyle(
            fontFamily: 'SpaceGrotesk', fontSize: 22,
            fontWeight: FontWeight.w700, color: AppTheme.white)),
        const SizedBox(height: 28),
        TextField(
          controller: _ctrl, obscureText: _obscure,
          style: const TextStyle(color: AppTheme.white, fontSize: 14),
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: const TextStyle(color: AppTheme.greyDark),
            filled: true, fillColor: AppTheme.black,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppTheme.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppTheme.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppTheme.white)),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.grey, size: 18),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Color(0xFFFF5555), fontSize: 12)),
        ],
        const SizedBox(height: 16),
        SizedBox(width: double.infinity,
          child: GestureDetector(onTap: _submit,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(color: AppTheme.white,
                  borderRadius: BorderRadius.circular(4)),
              child: const Center(child: Text('Enter', style: TextStyle(
                fontFamily: 'SpaceGrotesk', fontSize: 14,
                fontWeight: FontWeight.w700, color: AppTheme.black))),
            ),
          ),
        ),
      ]),
    ).animate().fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1)),
  );
}

// ─── MAIN SHELL ──────────────────────────────────────────────────
class _AdminShell extends StatefulWidget {
  final VoidCallback onLogout;
  const _AdminShell({required this.onLogout});
  @override
  State<_AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<_AdminShell> {
  int _tab = 0;
  final _tabs = ['Photos', 'Profile', 'Skills', 'Certificates', 'Projects', 'Contact'];
  final _icons = [
    Icons.photo_library_outlined, Icons.person_outline, Icons.bolt_outlined,
    Icons.workspace_premium_outlined, Icons.code_outlined, Icons.mail_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SafeArea(
      child: Column(children: [
        // Top bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('ADMIN', style: TextStyle(fontFamily: 'SpaceGrotesk',
                fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.white)),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(3),
              child: InkWell(
                onTap: widget.onLogout,
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(3)),
                  child: const Text('Logout', style: TextStyle(fontSize: 12, color: AppTheme.grey)),
                ),
              ),
            ),
          ]),
        ),

        // Tab bar
        Container(
          height: 48,
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border))),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _tabs.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _tab == i ? AppTheme.white : Colors.transparent,
                  border: Border.all(color: _tab == i ? AppTheme.white : AppTheme.border),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_icons[i], size: 14,
                      color: _tab == i ? AppTheme.black : AppTheme.grey),
                  const SizedBox(width: 6),
                  Text(_tabs[i], style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: _tab == i ? AppTheme.black : AppTheme.grey,
                  )),
                ]),
              ),
            ),
          ),
        ),

        // Tab content
        Expanded(child: switch (_tab) {
          0 => const _PhotosTab(),
          1 => const _ProfileTab(),
          2 => const _SkillsTab(),
          3 => const _CertsTab(),
          4 => const _ProjectsTab(),
          5 => const _ContactTab(),
          _ => const SizedBox(),
        }),
      ]),
    );
  }
}

// ─── PHOTOS TAB ──────────────────────────────────────────────────
class _PhotosTab extends StatefulWidget {
  const _PhotosTab();
  @override
  State<_PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends State<_PhotosTab> {
  List<_UploadTask> _tasks = [];
  bool _uploading = false;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true, type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'raf', 'RAF'],
      withData: true,
    );
    if (result == null) return;
    final files = result.files.take(10).toList();
    final valid = files.where((f) => f.size <= 10 * 1024 * 1024).toList();
    if (valid.isEmpty) { _snack('All files exceed 10MB limit.', isError: true); return; }
    setState(() {
      _tasks = valid.map((f) => _UploadTask(name: f.name, bytes: f.bytes!)).toList();
      _uploading = true;
    });
    for (int i = 0; i < _tasks.length; i++) {
      setState(() => _tasks[i] = _tasks[i].copyWith(status: _UStatus.uploading));
      final res = await CloudinaryService.uploadPhoto(
        bytes: _tasks[i].bytes, fileName: _tasks[i].name, mimeType: 'image/jpeg');
      setState(() => _tasks[i] = _tasks[i].copyWith(
        status: res.success ? _UStatus.done : _UStatus.error, error: res.error));
    }
    setState(() => _uploading = false);
    final done = _tasks.where((t) => t.status == _UStatus.done).length;
    if (done > 0) _snack('$done photo${done > 1 ? 's' : ''} uploaded!');
  }

  Future<void> _delete(PhotoEntry p) async {
    final ok = await _confirm('Remove "${p.name}" from gallery?');
    if (ok) { await FirebaseService.removePhoto(p.docId!); _snack('Removed.'); }
  }

  void _snack(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(color: AppTheme.white)),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: isError ? const Color(0xFFFF5555) : AppTheme.border)),
      ));

  Future<bool> _confirm(String msg) async =>
      await showDialog<bool>(context: context,
        builder: (_) => _ConfirmDialog(message: msg)) ?? false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionTitle(title: 'Upload Photos',
            sub: 'JPG · PNG · RAF  ·  Max 10 files  ·  Max 10MB each'),
        const SizedBox(height: 20),
        _DropZone(onTap: _uploading ? null : _pick),
        if (_tasks.isNotEmpty) ...[
          const SizedBox(height: 24),
          ..._tasks.asMap().entries.map((e) => _UploadRow(task: e.value, index: e.key)),
          if (!_uploading)
            TextButton(onPressed: () => setState(() => _tasks = []),
              child: const Text('Clear queue',
                  style: TextStyle(color: AppTheme.greyDark, fontSize: 12))),
        ],
        const SizedBox(height: 40),
        _SectionTitle(title: 'Manage Photos', sub: 'Hover a photo and click Remove to delete'),
        const SizedBox(height: 20),
        StreamBuilder<List<PhotoEntry>>(
          stream: FirebaseService.photosStream(),
          builder: (_, snap) {
            final photos = snap.data ?? [];
            if (photos.isEmpty) return const _EmptyBox(label: 'No photos yet');
            return GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 4,
                mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1),
              itemCount: photos.length,
              itemBuilder: (_, i) => _ManagePhotoCard(
                photo: photos[i], onDelete: () => _delete(photos[i])),
            );
          },
        ),
        const SizedBox(height: 60),
      ]),
    );
  }
}

// ─── PROFILE TAB ─────────────────────────────────────────────────
class _ProfileTab extends StatefulWidget {
  const _ProfileTab();
  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  bool _uploading = false;
  String? _status;
  double _cropY = -0.2; // alignment Y (-1 top, 0 center, 1 bottom)

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image, withData: true, allowMultiple: false);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) {
      setState(() { _status = '✗ Could not read file bytes.'; });
      return;
    }
    if (file.size > 10 * 1024 * 1024) {
      setState(() { _status = '✗ File exceeds 10MB limit.'; });
      return;
    }
    setState(() { _uploading = true; _status = 'Uploading…'; });

    try {
      final res = await CloudinaryService.uploadProfilePhoto(
        bytes: file.bytes!, fileName: file.name,
      ).timeout(const Duration(seconds: 30), onTimeout: () =>
          CloudinaryUploadResult(success: false, error: 'Upload timed out. Try a smaller file.'));

      if (!mounted) return;

      if (res.success && res.url != null) {
        await FirebaseService.setProfilePhoto(res.url!);
        setState(() { _uploading = false; _status = '✓ Profile photo updated!'; });
      } else {
        setState(() { _uploading = false; _status = '✗ ${res.error ?? 'Upload failed'}'; });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _uploading = false; _status = '✗ ${e.toString()}'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle(title: 'Profile Photo',
            sub: 'Upload a new photo and adjust the crop position'),
        const SizedBox(height: 32),

        Center(child: Column(children: [
          // Live preview from Firestore
          StreamBuilder<String?>(
            stream: FirebaseService.profilePhotoStream(),
            builder: (_, snap) {
              final url = snap.data;
              return Column(children: [
                // Preview circle
                Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.border, width: 1.5),
                  ),
                  child: ClipOval(
                    child: url != null
                        ? Image.network(url, fit: BoxFit.cover,
                            alignment: Alignment(0, _cropY))
                        : Image.asset('assets/images/profile.jpg',
                            fit: BoxFit.cover,
                            alignment: Alignment(0, _cropY)),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Live preview', style: const TextStyle(
                  fontSize: 11, color: AppTheme.greyDark, letterSpacing: 1)),
              ]);
            },
          ),

          const SizedBox(height: 32),

          // Crop Y slider
          const Text('VERTICAL CROP', style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: AppTheme.grey, letterSpacing: 2)),
          const SizedBox(height: 8),
          SizedBox(
            width: 280,
            child: Row(children: [
              const Text('Top', style: TextStyle(fontSize: 11, color: AppTheme.greyDark)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.white,
                    inactiveTrackColor: AppTheme.border,
                    thumbColor: AppTheme.white,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: _cropY,
                    min: -1.0, max: 1.0,
                    onChanged: (v) => setState(() => _cropY = v),
                  ),
                ),
              ),
              const Text('Bottom', style: TextStyle(fontSize: 11, color: AppTheme.greyDark)),
            ]),
          ),

          const SizedBox(height: 32),

          // Upload button
          Material(
            color: _uploading ? AppTheme.border : AppTheme.white,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: _uploading ? null : _pickAndUpload,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (_uploading)
                    const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: AppTheme.grey))
                  else
                    const Icon(Icons.upload_outlined, size: 16, color: AppTheme.black),
                  const SizedBox(width: 8),
                  Text(_uploading ? 'Uploading…' : 'Choose & Upload Photo',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk', fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _uploading ? AppTheme.grey : AppTheme.black)),
                ]),
              ),
            ),
          ),

          if (_status != null) ...[
            const SizedBox(height: 16),
            Text(_status!, style: TextStyle(
              fontSize: 13,
              color: _status!.startsWith('✓')
                  ? const Color(0xFF4ADE80) : const Color(0xFFFF5555),
            )),
          ],

          const SizedBox(height: 16),
          const Text(
            'JPG or PNG · Max 10MB\nChanges apply live across your portfolio.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppTheme.greyDark, height: 1.6),
          ),
        ])),
        const SizedBox(height: 60),
      ]),
    );
  }
}

// ─── SKILLS TAB ──────────────────────────────────────────────────
class _SkillsTab extends StatefulWidget {
  const _SkillsTab();
  @override
  State<_SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends State<_SkillsTab> {
  final _nameCtrl = TextEditingController();
  String _category = 'Languages';
  final _cats = ['Languages', 'Frameworks & Libraries', 'Tools & Platforms', 'Other Skills'];

  Future<void> _add() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) { _snack('Please enter a skill name.', isError: true); return; }
    final err = await FirebaseService.addSkill(SkillEntry(name: name, category: _category));
    if (err != null) { _snack('Error: $err', isError: true); return; }
    _nameCtrl.clear();
    _snack('Skill added!');
  }

  void _snack(String msg, {bool isError = false}) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg, style: const TextStyle(color: AppTheme.white)),
      backgroundColor: AppTheme.surface, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: isError ? const Color(0xFFFF5555) : AppTheme.border))));

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle(title: 'Add Skill', sub: 'New skills appear live on the Skills page'),
        const SizedBox(height: 24),
        _InputRow(
          controller: _nameCtrl,
          hint: 'Skill name (e.g. Node.js)',
          onSubmit: _add,
          trailing: DropdownButton<String>(
            value: _category,
            dropdownColor: AppTheme.card,
            style: const TextStyle(color: AppTheme.white, fontSize: 13),
            underline: const SizedBox(),
            items: _cats.map((c) => DropdownMenuItem(value: c,
              child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          buttonLabel: 'Add',
          onTap: _add,
        ),
        const SizedBox(height: 40),
        const _SectionTitle(title: 'Added Skills', sub: 'These are Firestore-only additions'),
        const SizedBox(height: 16),
        StreamBuilder<List<SkillEntry>>(
          stream: FirebaseService.skillsStream(),
          builder: (_, snap) {
            final skills = snap.data ?? [];
            if (skills.isEmpty) return const _EmptyBox(label: 'No skills added yet');
            return Column(children: skills.map((s) => _ListRow(
              label: s.name, sublabel: s.category,
              onDelete: () async {
                final ok = await showDialog<bool>(context: context,
                  builder: (_) => _ConfirmDialog(message: 'Remove skill "${s.name}"?')) ?? false;
                if (ok) { await FirebaseService.removeSkill(s.docId!); _snack('Skill removed.'); }
              },
            )).toList());
          },
        ),
        const SizedBox(height: 60),
      ]),
    );
  }
}

// ─── CERTS TAB ───────────────────────────────────────────────────
class _CertsTab extends StatefulWidget {
  const _CertsTab();
  @override
  State<_CertsTab> createState() => _CertsTabState();
}

class _CertsTabState extends State<_CertsTab> {
  final _nameCtrl = TextEditingController();
  String _issuer = 'MMCL';
  final _issuers = ['MMCL', 'Coursera', 'New Section'];
  String? _customIssuer;
  final _customCtrl = TextEditingController();

  Future<void> _add() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) { _snack('Please enter a certificate name.', isError: true); return; }
    final issuer = _issuer == 'New Section'
        ? (_customCtrl.text.trim().isEmpty ? 'Other' : _customCtrl.text.trim())
        : _issuer;
    final err = await FirebaseService.addCert(CertEntry(name: name, issuer: issuer));
    if (err != null) { _snack('Error: $err', isError: true); return; }
    _nameCtrl.clear(); _customCtrl.clear();
    _snack('Certificate added!');
  }

  void _snack(String msg, {bool isError = false}) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg, style: const TextStyle(color: AppTheme.white)),
      backgroundColor: AppTheme.surface, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: isError ? const Color(0xFFFF5555) : AppTheme.border))));

  @override
  void dispose() { _nameCtrl.dispose(); _customCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle(title: 'Add Certificate',
            sub: 'Choose an existing section or create a new one'),
        const SizedBox(height: 24),
        _InputRow(
          controller: _nameCtrl,
          hint: 'Certificate name',
          onSubmit: _add,
          trailing: DropdownButton<String>(
            value: _issuer, dropdownColor: AppTheme.card,
            style: const TextStyle(color: AppTheme.white, fontSize: 13),
            underline: const SizedBox(),
            items: _issuers.map((c) => DropdownMenuItem(value: c,
              child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) => setState(() => _issuer = v!),
          ),
          buttonLabel: 'Add', onTap: _add,
        ),
        if (_issuer == 'New Section') ...[
          const SizedBox(height: 12),
          _StyledTextField(controller: _customCtrl,
              hint: 'New section name (e.g. Google, LinkedIn)'),
        ],
        const SizedBox(height: 40),
        const _SectionTitle(title: 'Added Certificates',
            sub: 'Firestore-only additions (defaults are hardcoded)'),
        const SizedBox(height: 16),
        StreamBuilder<List<CertEntry>>(
          stream: FirebaseService.certsStream(),
          builder: (_, snap) {
            final certs = snap.data ?? [];
            if (certs.isEmpty) return const _EmptyBox(label: 'No certificates added yet');
            return Column(children: certs.map((c) => _ListRow(
              label: c.name, sublabel: c.issuer,
              onDelete: () async {
                final ok = await showDialog<bool>(context: context,
                  builder: (_) => _ConfirmDialog(message: 'Remove certificate "${c.name}"?')) ?? false;
                if (ok) { await FirebaseService.removeCert(c.docId!); _snack('Certificate removed.'); }
              },
            )).toList());
          },
        ),
        const SizedBox(height: 60),
      ]),
    );
  }
}

// ─── PROJECTS TAB ────────────────────────────────────────────────
class _ProjectsTab extends StatefulWidget {
  const _ProjectsTab();
  @override
  State<_ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<_ProjectsTab> {
  final _nameCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  String _status = 'Live';

  Future<void> _add() async {
    final name = _nameCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    if (name.isEmpty) { _snack('Please enter a project name.', isError: true); return; }
    if (url.isEmpty) { _snack('Please enter a project URL.', isError: true); return; }
    final tags = _tagsCtrl.text.split(',')
        .map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    final err = await FirebaseService.addProject(ProjectEntry(
      name: name, url: url,
      description: _descCtrl.text.trim(),
      status: _status, tags: tags,
    ));
    if (err != null) { _snack('Error: $err', isError: true); return; }
    _nameCtrl.clear(); _urlCtrl.clear();
    _descCtrl.clear(); _tagsCtrl.clear();
    _snack('Project added!');
  }

  void _snack(String msg, {bool isError = false}) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg, style: const TextStyle(color: AppTheme.white)),
      backgroundColor: AppTheme.surface, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: isError ? const Color(0xFFFF5555) : AppTheme.border))));

  @override
  void dispose() {
    _nameCtrl.dispose(); _urlCtrl.dispose();
    _descCtrl.dispose(); _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle(title: 'Add Project', sub: 'New projects appear live on the Projects page'),
        const SizedBox(height: 24),
        _StyledTextField(controller: _nameCtrl, hint: 'Project name'),
        const SizedBox(height: 10),
        _StyledTextField(controller: _urlCtrl, hint: 'Project URL (https://...)'),
        const SizedBox(height: 10),
        _StyledTextField(controller: _descCtrl, hint: 'Short description', maxLines: 3),
        const SizedBox(height: 10),
        _StyledTextField(controller: _tagsCtrl, hint: 'Tags, comma-separated (e.g. React, Vercel)'),
        const SizedBox(height: 12),
        Row(children: [
          const Text('Status:', style: TextStyle(fontSize: 13, color: AppTheme.grey)),
          const SizedBox(width: 12),
          ...['Live', 'In Progress', 'Archived'].map((s) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: _status == s ? AppTheme.white : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
              child: InkWell(
                onTap: () => setState(() => _status = s),
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: _status == s ? AppTheme.white : AppTheme.border),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(s, style: TextStyle(fontSize: 12,
                      color: _status == s ? AppTheme.black : AppTheme.grey)),
                ),
              ),
            ),
          )),
        ]),
        const SizedBox(height: 16),
        _AddButton(label: 'Add Project', onTap: _add),
        const SizedBox(height: 40),
        const _SectionTitle(title: 'Added Projects', sub: 'Firestore additions only'),
        const SizedBox(height: 16),
        StreamBuilder<List<ProjectEntry>>(
          stream: FirebaseService.projectsStream(),
          builder: (_, snap) {
            final projects = snap.data ?? [];
            if (projects.isEmpty) return const _EmptyBox(label: 'No projects added yet');
            return Column(children: projects.map((p) => _ListRow(
              label: p.name, sublabel: p.url,
              onDelete: () async {
                final ok = await showDialog<bool>(context: context,
                  builder: (_) => _ConfirmDialog(message: 'Remove project "${p.name}"?')) ?? false;
                if (ok) { await FirebaseService.removeProject(p.docId!); _snack('Project removed.'); }
              },
            )).toList());
          },
        ),
        const SizedBox(height: 60),
      ]),
    );
  }
}

// ─── CONTACT TAB ─────────────────────────────────────────────────
class _ContactTab extends StatefulWidget {
  const _ContactTab();
  @override
  State<_ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<_ContactTab> {
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _igCtrl = TextEditingController();
  final _fbCtrl = TextEditingController();
  bool _loaded = false, _saving = false;

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  Future<void> _loadContact() async {
    try {
      final c = await FirebaseService.contactStream()
          .first
          .timeout(const Duration(seconds: 5), onTimeout: () => ContactData());
      if (!mounted) return;
      _emailCtrl.text = c.email;
      _phoneCtrl.text = c.phone;
      _addressCtrl.text = c.address;
      _igCtrl.text = c.instagram;
      _fbCtrl.text = c.facebook;
    } catch (_) {
      if (!mounted) return;
      // Use defaults if Firestore fails
      final c = ContactData();
      _emailCtrl.text = c.email;
      _phoneCtrl.text = c.phone;
      _addressCtrl.text = c.address;
      _igCtrl.text = c.instagram;
      _fbCtrl.text = c.facebook;
    }
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final err = await FirebaseService.updateContact(ContactData(
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      instagram: _igCtrl.text.trim(),
      facebook: _fbCtrl.text.trim(),
    ));
    setState(() => _saving = false);
    final msg = err != null ? 'Error: $err' : 'Contact info updated!';
    final isErr = err != null;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: AppTheme.white)),
      backgroundColor: AppTheme.surface, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: isErr ? const Color(0xFFFF5555) : AppTheme.border))));
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _phoneCtrl.dispose(); _addressCtrl.dispose();
    _igCtrl.dispose(); _fbCtrl.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    if (!_loaded) return const Center(child: CircularProgressIndicator(
        color: AppTheme.white, strokeWidth: 1));
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle(title: 'Update Contact Info',
            sub: 'Changes apply live on the Contact page'),
        const SizedBox(height: 24),
        _FieldLabel('Email'),
        _StyledTextField(controller: _emailCtrl, hint: 'your@email.com'),
        const SizedBox(height: 14),
        _FieldLabel('Phone Number'),
        _StyledTextField(controller: _phoneCtrl, hint: '09XXXXXXXXX'),
        const SizedBox(height: 14),
        _FieldLabel('Address'),
        _StyledTextField(controller: _addressCtrl, hint: 'City, Province, Country'),
        const SizedBox(height: 14),
        _FieldLabel('Instagram URL'),
        _StyledTextField(controller: _igCtrl, hint: 'https://instagram.com/...'),
        const SizedBox(height: 14),
        _FieldLabel('Facebook URL'),
        _StyledTextField(controller: _fbCtrl, hint: 'https://facebook.com/...'),
        const SizedBox(height: 28),
        Material(
          color: _saving ? AppTheme.border : AppTheme.white,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: _saving ? null : _save,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (_saving)
                  const SizedBox(width: 14, height: 14,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.grey))
                else
                  const Icon(Icons.save_outlined, size: 16, color: AppTheme.black),
                const SizedBox(width: 8),
                Text(_saving ? 'Saving…' : 'Save Changes', style: TextStyle(
                  fontFamily: 'SpaceGrotesk', fontSize: 14, fontWeight: FontWeight.w600,
                  color: _saving ? AppTheme.grey : AppTheme.black)),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 60),
      ]),
    );
  }
}

// ─── SHARED UI HELPERS ────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title, sub;
  const _SectionTitle({required this.title, required this.sub});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontFamily: 'SpaceGrotesk',
          fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.white)),
      const SizedBox(height: 4),
      Text(sub, style: const TextStyle(fontSize: 12, color: AppTheme.greyDark)),
    ],
  );
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(label, style: const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w600,
      color: AppTheme.grey, letterSpacing: 1)),
  );
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _StyledTextField({
    required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, maxLines: maxLines,
    style: const TextStyle(color: AppTheme.white, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint, hintStyle: const TextStyle(color: AppTheme.greyDark),
      filled: true, fillColor: AppTheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppTheme.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppTheme.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppTheme.white)),
    ),
  );
}

class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final String hint, buttonLabel;
  final VoidCallback onTap, onSubmit;
  final Widget trailing;

  const _InputRow({required this.controller, required this.hint,
      required this.buttonLabel, required this.onTap,
      required this.onSubmit, required this.trailing});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: TextField(
      controller: controller, onSubmitted: (_) => onSubmit(),
      style: const TextStyle(color: AppTheme.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: AppTheme.greyDark),
        filled: true, fillColor: AppTheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppTheme.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppTheme.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppTheme.white)),
      ),
    )),
    const SizedBox(width: 10),
    trailing,
    const SizedBox(width: 10),
    _AddButton(label: buttonLabel, onTap: onTap),
  ]);
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: AppTheme.white,
    borderRadius: BorderRadius.circular(4),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Text(label, style: const TextStyle(fontFamily: 'SpaceGrotesk',
            fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.black)),
      ),
    ),
  );
}

class _ListRow extends StatelessWidget {
  final String label, sublabel;
  final VoidCallback onDelete;
  const _ListRow({required this.label, required this.sublabel, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4)),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.white,
            fontWeight: FontWeight.w500)),
        Text(sublabel, style: const TextStyle(fontSize: 11, color: AppTheme.greyDark)),
      ])),
      Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(3),
        child: InkWell(
          onTap: onDelete,
          borderRadius: BorderRadius.circular(3),
          child: Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(3)),
            child: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFFF5555)),
          ),
        ),
      ),
    ]),
  );
}

class _EmptyBox extends StatelessWidget {
  final String label;
  const _EmptyBox({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4)),
    child: Center(child: Text(label, style: const TextStyle(
        fontSize: 13, color: AppTheme.greyDark))),
  );
}

class _ConfirmDialog extends StatelessWidget {
  final String message;
  const _ConfirmDialog({required this.message});
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppTheme.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppTheme.border)),
    content: Text(message, style: const TextStyle(color: AppTheme.grey, fontSize: 13)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel', style: TextStyle(color: AppTheme.grey))),
      TextButton(onPressed: () => Navigator.pop(context, true),
        child: const Text('Remove', style: TextStyle(color: Color(0xFFFF5555)))),
    ],
  );
}

// ─── PHOTO CARD (manage grid) ─────────────────────────────────────
class _ManagePhotoCard extends StatefulWidget {
  final PhotoEntry photo;
  final VoidCallback onDelete;
  const _ManagePhotoCard({required this.photo, required this.onDelete});
  @override
  State<_ManagePhotoCard> createState() => _ManagePhotoCardState();
}

class _ManagePhotoCardState extends State<_ManagePhotoCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Stack(fit: StackFit.expand, children: [
        CachedNetworkImage(imageUrl: widget.photo.thumbnailUrl, fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppTheme.surface,
            child: const Center(child: SizedBox(width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 1, color: AppTheme.greyDark)))),
          errorWidget: (_, __, ___) => Container(color: AppTheme.surface,
            child: const Icon(Icons.broken_image_outlined, color: AppTheme.greyDark)),
        ),
        AnimatedOpacity(opacity: _hovered ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: Container(color: Colors.black.withOpacity(0.6),
            child: Center(child: GestureDetector(onTap: widget.onDelete,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5555).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(3)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.delete_outline, color: Colors.white, size: 13),
                  SizedBox(width: 4),
                  Text('Remove', style: TextStyle(color: Colors.white,
                      fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
              ),
            )),
          ),
        ),
      ]),
    ),
  );
}

// ─── DROP ZONE ───────────────────────────────────────────────────
class _DropZone extends StatefulWidget {
  final VoidCallback? onTap;
  const _DropZone({this.onTap});
  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity, height: 180,
        decoration: BoxDecoration(
          color: _hovered ? AppTheme.surface : AppTheme.black,
          border: Border.all(color: _hovered ? AppTheme.greyDark : AppTheme.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.cloud_upload_outlined, size: 32,
              color: _hovered ? AppTheme.white : AppTheme.greyDark),
          const SizedBox(height: 12),
          Text(widget.onTap == null ? 'Uploading…' : 'Click to select photos',
            style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _hovered ? AppTheme.white : AppTheme.grey)),
          const SizedBox(height: 4),
          const Text('Up to 10 photos', style: TextStyle(fontSize: 11, color: AppTheme.greyDark)),
        ]),
      ),
    ),
  );
}

// ─── UPLOAD TASK ─────────────────────────────────────────────────
enum _UStatus { pending, uploading, done, error }

class _UploadTask {
  final String name;
  final Uint8List bytes;
  final _UStatus status;
  final String? error;
  const _UploadTask({required this.name, required this.bytes,
      this.status = _UStatus.pending, this.error});
  _UploadTask copyWith({_UStatus? status, String? error}) =>
      _UploadTask(name: name, bytes: bytes,
          status: status ?? this.status, error: error ?? this.error);
}

class _UploadRow extends StatelessWidget {
  final _UploadTask task;
  final int index;
  const _UploadRow({required this.task, required this.index});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4)),
    child: Row(children: [
      SizedBox(width: 20, height: 20, child: switch (task.status) {
        _UStatus.pending   => const Icon(Icons.schedule, size: 15, color: AppTheme.greyDark),
        _UStatus.uploading => const SizedBox(width: 15, height: 15,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.white)),
        _UStatus.done      => const Icon(Icons.check_circle_outline, size: 15, color: Color(0xFF4ADE80)),
        _UStatus.error     => const Icon(Icons.error_outline, size: 15, color: Color(0xFFFF5555)),
      }),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(task.name, style: const TextStyle(fontSize: 13, color: AppTheme.white),
            overflow: TextOverflow.ellipsis),
        if (task.error != null)
          Text(task.error!, style: const TextStyle(fontSize: 11, color: Color(0xFFFF5555))),
      ])),
      Text('${(task.bytes.length / 1024 / 1024).toStringAsFixed(1)} MB',
          style: const TextStyle(fontSize: 11, color: AppTheme.greyDark)),
    ]),
  ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms);
}
