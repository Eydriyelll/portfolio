import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cloudinary_service.dart';
import '../theme/app_theme.dart';

const String _adminPassword = 'MidnightStar30';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _authenticated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: _authenticated
          ? _AdminPanel(onLogout: () => setState(() => _authenticated = false))
          : _LoginScreen(onSuccess: () => setState(() => _authenticated = true)),
    );
  }
}

// ─── LOGIN ────────────────────────────────────────────────────
class _LoginScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const _LoginScreen({required this.onSuccess});

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  String? _error;

  void _submit() {
    if (_controller.text == _adminPassword) {
      widget.onSuccess();
    } else {
      setState(() => _error = 'Incorrect password.');
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ADMIN', style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: AppTheme.grey, letterSpacing: 3,
            )),
            const SizedBox(height: 10),
            const Text('Photo Upload Panel', style: TextStyle(
              fontFamily: 'SpaceGrotesk', fontSize: 22,
              fontWeight: FontWeight.w700, color: AppTheme.white,
            )),
            const SizedBox(height: 28),
            TextField(
              controller: _controller,
              obscureText: _obscure,
              style: const TextStyle(color: AppTheme.white, fontSize: 14),
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(color: AppTheme.greyDark),
                filled: true,
                fillColor: AppTheme.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppTheme.white),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.grey, size: 18,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(
                color: Color(0xFFFF5555), fontSize: 12,
              )),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _submit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text('Enter', style: TextStyle(
                      fontFamily: 'SpaceGrotesk', fontSize: 14,
                      fontWeight: FontWeight.w700, color: AppTheme.black,
                    )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms).scale(
        begin: const Offset(0.97, 0.97), end: const Offset(1, 1),
      ),
    );
  }
}

// ─── ADMIN PANEL ──────────────────────────────────────────────
class _AdminPanel extends StatefulWidget {
  final VoidCallback onLogout;
  const _AdminPanel({required this.onLogout});

  @override
  State<_AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<_AdminPanel> {
  List<_UploadTask> _tasks = [];
  List<CloudinaryPhoto> _existingPhotos = [];
  bool _uploading = false;
  bool _loadingPhotos = true;
  int _selectedTab = 0; // 0 = Upload, 1 = Manage

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _loadingPhotos = true);
    final photos = await CloudinaryService.fetchPhotos();
    if (mounted) setState(() { _existingPhotos = photos; _loadingPhotos = false; });
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'raf', 'RAF'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final files = result.files.take(10).toList();
    final oversized = files.where((f) => f.size > 10 * 1024 * 1024).toList();
    if (oversized.isNotEmpty) {
      _showSnack('${oversized.length} file(s) exceed 10MB and were skipped.', isError: true);
    }

    final valid = files.where((f) => f.size <= 10 * 1024 * 1024).toList();
    if (valid.isEmpty) return;

    setState(() {
      _tasks = valid.map((f) => _UploadTask(name: f.name, bytes: f.bytes!)).toList();
      _uploading = true;
    });

    for (int i = 0; i < _tasks.length; i++) {
      setState(() => _tasks[i] = _tasks[i].copyWith(status: _Status.uploading));

      final res = await CloudinaryService.uploadPhoto(
        bytes: _tasks[i].bytes,
        fileName: _tasks[i].name,
        mimeType: 'image/${_tasks[i].name.split('.').last.toLowerCase()}',
      );

      setState(() {
        _tasks[i] = _tasks[i].copyWith(
          status: res.success ? _Status.done : _Status.error,
          error: res.error,
        );
      });
    }

    setState(() => _uploading = false);
    final done = _tasks.where((t) => t.status == _Status.done).length;
    if (done > 0) {
      _showSnack('$done photo${done == 1 ? '' : 's'} uploaded successfully! ✓');
      await _loadExisting();
    }
  }

  Future<void> _deletePhoto(CloudinaryPhoto photo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text('Remove photo?', style: TextStyle(
          color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.w600,
        )),
        content: Text(
          'This removes "${photo.name}" from your gallery list.\n(File stays on Cloudinary)',
          style: const TextStyle(color: AppTheme.grey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Color(0xFFFF5555))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await CloudinaryService.removePhotoFromList(photo.publicId);
      _showSnack('Photo removed from gallery.');
      await _loadExisting();
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: AppTheme.white, fontSize: 13)),
      backgroundColor: AppTheme.surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: isError ? const Color(0xFFFF5555) : AppTheme.border),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 80, vertical: 48,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('ADMIN PANEL', style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: AppTheme.grey, letterSpacing: 3,
                  )),
                  const SizedBox(height: 8),
                  const Text('Photo Manager', style: TextStyle(
                    fontFamily: 'SpaceGrotesk', fontSize: 26,
                    fontWeight: FontWeight.w700, color: AppTheme.white,
                  )),
                ]),
                GestureDetector(
                  onTap: widget.onLogout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Logout', style: TextStyle(
                      fontSize: 12, color: AppTheme.grey,
                    )),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tabs
            Row(
              children: [
                _Tab(label: 'Upload', active: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0)),
                const SizedBox(width: 8),
                _Tab(
                  label: 'Manage (${_existingPhotos.length})',
                  active: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ],
            ),

            const SizedBox(height: 28),

            if (_selectedTab == 0) ...[
              // Upload zone
              _DropZone(onTap: _uploading ? null : _pickAndUpload),
              const SizedBox(height: 10),
              const Text(
                'JPG · PNG · RAF   ·   Max 10 files   ·   Max 10MB each',
                style: TextStyle(fontSize: 11, color: AppTheme.greyDark, letterSpacing: 0.5),
              ),

              if (_tasks.isNotEmpty) ...[
                const SizedBox(height: 36),
                const Text('UPLOAD QUEUE', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: AppTheme.grey, letterSpacing: 3,
                )),
                const SizedBox(height: 14),
                ..._tasks.asMap().entries.map(
                  (e) => _UploadRow(task: e.value, index: e.key),
                ),
                if (!_uploading) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => setState(() => _tasks = []),
                    child: const Text('Clear queue', style: TextStyle(
                      fontSize: 12, color: AppTheme.greyDark,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.greyDark,
                    )),
                  ),
                ],
              ],
            ] else ...[
              // Manage tab
              if (_loadingPhotos)
                const Center(child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 1),
                ))
              else if (_existingPhotos.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Column(children: [
                    Icon(Icons.photo_library_outlined, size: 36, color: AppTheme.greyDark),
                    SizedBox(height: 12),
                    Text('No photos uploaded yet', style: TextStyle(
                      color: AppTheme.grey, fontSize: 14,
                    )),
                  ]),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 2 : 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _existingPhotos.length,
                  itemBuilder: (_, i) => _ManagePhotoCard(
                    photo: _existingPhotos[i],
                    onDelete: () => _deletePhoto(_existingPhotos[i]),
                  ),
                ),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.white : Colors.transparent,
          border: Border.all(color: active ? AppTheme.white : AppTheme.border),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: active ? AppTheme.black : AppTheme.grey,
        )),
      ),
    );
  }
}

class _DropZone extends StatefulWidget {
  final VoidCallback? onTap;
  const _DropZone({this.onTap});

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.surface : AppTheme.black,
            border: Border.all(
              color: _hovered ? AppTheme.greyDark : AppTheme.border,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined,
                  size: 36,
                  color: _hovered ? AppTheme.white : AppTheme.greyDark),
              const SizedBox(height: 14),
              Text(
                widget.onTap == null ? 'Uploading...' : 'Click to select photos',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk', fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _hovered ? AppTheme.white : AppTheme.grey,
                ),
              ),
              const SizedBox(height: 4),
              const Text('Up to 10 photos at once',
                  style: TextStyle(fontSize: 12, color: AppTheme.greyDark)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadRow extends StatelessWidget {
  final _UploadTask task;
  final int index;
  const _UploadRow({required this.task, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        SizedBox(
          width: 20, height: 20,
          child: switch (task.status) {
            _Status.pending   => const Icon(Icons.schedule, size: 16, color: AppTheme.greyDark),
            _Status.uploading => const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.white)),
            _Status.done      => const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF4ADE80)),
            _Status.error     => const Icon(Icons.error_outline, size: 16, color: Color(0xFFFF5555)),
          },
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task.name,
              style: const TextStyle(fontSize: 13, color: AppTheme.white),
              overflow: TextOverflow.ellipsis),
          if (task.error != null)
            Text(task.error!, style: const TextStyle(fontSize: 11, color: Color(0xFFFF5555))),
        ])),
        Text(
          '${(task.bytes.length / 1024 / 1024).toStringAsFixed(1)} MB',
          style: const TextStyle(fontSize: 11, color: AppTheme.greyDark),
        ),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index), duration: 300.ms);
  }
}

class _ManagePhotoCard extends StatefulWidget {
  final CloudinaryPhoto photo;
  final VoidCallback onDelete;
  const _ManagePhotoCard({required this.photo, required this.onDelete});

  @override
  State<_ManagePhotoCard> createState() => _ManagePhotoCardState();
}

class _ManagePhotoCardState extends State<_ManagePhotoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: widget.photo.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppTheme.surface,
                child: const Center(child: SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 1, color: AppTheme.greyDark)))),
              errorWidget: (_, __, ___) => Container(color: AppTheme.surface,
                child: const Icon(Icons.broken_image_outlined, color: AppTheme.greyDark)),
            ),
            AnimatedOpacity(
              opacity: _hovered ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5555).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.delete_outline, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Remove', style: TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600,
                        )),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Status { pending, uploading, done, error }

class _UploadTask {
  final String name;
  final Uint8List bytes;
  final _Status status;
  final String? error;

  const _UploadTask({
    required this.name,
    required this.bytes,
    this.status = _Status.pending,
    this.error,
  });

  _UploadTask copyWith({_Status? status, String? error}) => _UploadTask(
    name: name, bytes: bytes,
    status: status ?? this.status,
    error: error ?? this.error,
  );
}
