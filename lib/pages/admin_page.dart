import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ADMIN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.grey,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Photo Upload Panel',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _controller,
              obscureText: _obscure,
              style: const TextStyle(color: AppTheme.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter password',
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
                    color: AppTheme.grey,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFFF5555), fontSize: 12),
              ),
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _submit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'Enter',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _AdminPanel extends StatefulWidget {
  final VoidCallback onLogout;
  const _AdminPanel({required this.onLogout});

  @override
  State<_AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<_AdminPanel> {
  List<_UploadTask> _tasks = [];
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'raf', 'RAF'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final files = result.files.take(10).toList();

    // Check file size (10MB = 10 * 1024 * 1024 bytes)
    final oversized = files.where((f) => (f.size) > 10 * 1024 * 1024).toList();
    if (oversized.isNotEmpty) {
      _showSnack(
        '${oversized.length} file(s) exceed 10MB limit and will be skipped.',
        isError: true,
      );
    }

    final validFiles = files.where((f) => f.size <= 10 * 1024 * 1024).toList();
    if (validFiles.isEmpty) return;

    setState(() {
      _tasks = validFiles
          .map((f) => _UploadTask(name: f.name, bytes: f.bytes!))
          .toList();
      _uploading = true;
    });

    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      setState(() => _tasks[i] = task.copyWith(status: _Status.uploading));

      final result = await CloudinaryService.uploadPhoto(
        bytes: task.bytes,
        fileName: task.name,
        mimeType: 'image/${task.name.split('.').last.toLowerCase()}',
      );

      setState(() {
        _tasks[i] = task.copyWith(
          status: result.success ? _Status.done : _Status.error,
          error: result.error,
        );
      });
    }

    setState(() => _uploading = false);

    final done = _tasks.where((t) => t.status == _Status.done).length;
    _showSnack('$done photo(s) uploaded successfully!');
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFF2A1A1A) : AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: isError ? const Color(0xFFFF5555) : AppTheme.border,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 80,
          vertical: 48,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ADMIN PANEL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.grey,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Photo Upload',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: widget.onLogout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Upload zone
            _DropZone(
              onTap: _uploading ? null : _pickAndUpload,
            ),

            const SizedBox(height: 12),
            const Text(
              'Accepts JPG, PNG, RAF · Max 10 files per batch · Max 10MB per file',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.greyDark,
                letterSpacing: 0.3,
              ),
            ),

            if (_tasks.isNotEmpty) ...[
              const SizedBox(height: 40),
              const Text(
                'UPLOAD QUEUE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.grey,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 16),
              ..._tasks.asMap().entries.map((e) => _UploadRow(
                    task: e.value,
                    index: e.key,
                  )),

              if (!_uploading) ...[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => setState(() => _tasks = []),
                  child: const Text(
                    'Clear queue',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.greyDark,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.greyDark,
                    ),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 80),
          ],
        ),
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.surface : AppTheme.black,
            border: Border.all(
              color: _hovered ? AppTheme.greyDark : AppTheme.border,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: _hovered ? AppTheme.white : AppTheme.greyDark,
              ),
              const SizedBox(height: 16),
              Text(
                widget.onTap == null ? 'Uploading...' : 'Click to select photos',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _hovered ? AppTheme.white : AppTheme.grey,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Up to 10 photos at once',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.greyDark,
                ),
              ),
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
      child: Row(
        children: [
          // Status icon
          SizedBox(
            width: 20,
            height: 20,
            child: switch (task.status) {
              _Status.pending => const Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppTheme.greyDark,
                ),
              _Status.uploading => const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppTheme.white,
                  ),
                ),
              _Status.done => const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Color(0xFF4ADE80),
                ),
              _Status.error => const Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Color(0xFFFF5555),
                ),
            },
          ),
          const SizedBox(width: 12),

          // File name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.error != null)
                  Text(
                    task.error!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFF5555),
                    ),
                  ),
              ],
            ),
          ),

          // Size
          Text(
            '${(task.bytes.length / 1024 / 1024).toStringAsFixed(1)} MB',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.greyDark,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: 300.ms,
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

  _UploadTask copyWith({_Status? status, String? error}) {
    return _UploadTask(
      name: name,
      bytes: bytes,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}
