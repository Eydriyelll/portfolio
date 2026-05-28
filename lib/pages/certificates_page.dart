import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../widgets/animated_page_wrapper.dart';

class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return AnimatedPageWrapper(
      child: StreamBuilder<List<CertEntry>>(
        stream: FirebaseService.certsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
                color: AppTheme.white, strokeWidth: 1));
          }
          final certs = snap.data ?? [];

          // Group by issuer
          final grouped = <String, List<CertEntry>>{};
          for (final c in certs) {
            grouped.putIfAbsent(c.issuer, () => []).add(c);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 28 : 80, vertical: 64,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(
                  label: 'CERTIFICATES',
                  title: 'Recognition &\nachievements.',
                ),
                const SizedBox(height: 8),
                Text(
                  certs.any((c) => c.hasImage)
                      ? 'Click any certificate with a preview to view it.'
                      : '',
                  style: const TextStyle(fontSize: 13, color: AppTheme.greyDark),
                ),
                const SizedBox(height: 48),

                if (certs.isEmpty)
                  const Center(
                    child: Text('No certificates added yet.',
                        style: TextStyle(color: AppTheme.greyDark)))
                else
                  ...grouped.entries.toList().asMap().entries.map((outer) {
                    final gi = outer.key;
                    final entry = outer.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              border: Border.all(color: AppTheme.border),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(entry.key.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  color: AppTheme.grey, letterSpacing: 2,
                                )),
                          ).animate().fadeIn(
                            delay: Duration(milliseconds: gi * 100),
                            duration: 500.ms),
                          const SizedBox(width: 14),
                          const Expanded(child: Divider(color: AppTheme.border)),
                        ]),
                        const SizedBox(height: 20),
                        ...entry.value.asMap().entries.map((e) => _CertCard(
                          cert: e.value,
                          delay: Duration(
                              milliseconds: (gi * 100) + (e.key * 60)),
                        )),
                        const SizedBox(height: 40),
                      ],
                    );
                  }),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CertCard extends StatefulWidget {
  final CertEntry cert;
  final Duration delay;
  const _CertCard({required this.cert, required this.delay});

  @override
  State<_CertCard> createState() => _CertCardState();
}

class _CertCardState extends State<_CertCard> {
  bool _hovered = false;

  void _openViewer() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.97),
      builder: (_) => _CertViewer(cert: widget.cert),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clickable = widget.cert.hasImage;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: clickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: clickable ? _openViewer : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          transform: Matrix4.translationValues(
              0, _hovered && clickable ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: _hovered && clickable ? AppTheme.card : AppTheme.surface,
            border: Border.all(
              color: _hovered && clickable
                  ? AppTheme.greyDark : AppTheme.border,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _hovered && clickable
                ? [BoxShadow(color: Colors.black.withOpacity(0.2),
                    blurRadius: 8, offset: const Offset(0, 3))]
                : [],
          ),
          child: Row(children: [
            // Icon
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: clickable && _hovered
                    ? AppTheme.greyDark : AppTheme.border,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                clickable
                    ? Icons.image_outlined
                    : Icons.workspace_premium_outlined,
                size: 16,
                color: clickable && _hovered
                    ? AppTheme.white : AppTheme.grey,
              ),
            ),
            const SizedBox(width: 16),

            // Name
            Expanded(
              child: Text(widget.cert.name, style: const TextStyle(
                fontFamily: 'SpaceGrotesk', fontSize: 14,
                fontWeight: FontWeight.w500, color: AppTheme.white,
              )),
            ),

            // View badge
            if (clickable)
              AnimatedOpacity(
                opacity: _hovered ? 1 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.greyDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text('View', style: TextStyle(
                    fontSize: 10, color: AppTheme.grey,
                    fontWeight: FontWeight.w600, letterSpacing: 1,
                  )),
                ),
              ),
          ]),
        ),
      ),
    ).animate()
        .fadeIn(delay: widget.delay, duration: 400.ms)
        .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
  }
}

// ─── FULLSCREEN VIEWER ────────────────────────────────────────────
class _CertViewer extends StatefulWidget {
  final CertEntry cert;
  const _CertViewer({required this.cert});

  @override
  State<_CertViewer> createState() => _CertViewerState();
}

class _CertViewerState extends State<_CertViewer> {
  bool _imageLoaded = false;
  bool _imageError = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismiss on tap background
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.black.withOpacity(0.96)),
          ),

          // Center content
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 900,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 20 : 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image
                    Flexible(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: CachedNetworkImage(
                            imageUrl: widget.cert.imageUrl!,
                            fit: BoxFit.contain,
                            fadeInDuration: const Duration(milliseconds: 300),
                            imageBuilder: (_, imageProvider) {
                              if (!_imageLoaded) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) setState(() => _imageLoaded = true);
                                });
                              }
                              return Image(image: imageProvider, fit: BoxFit.contain);
                            },
                            placeholder: (_, __) => Container(
                              width: double.infinity,
                              height: isMobile ? 300 : 500,
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                      color: AppTheme.white, strokeWidth: 1),
                                  SizedBox(height: 16),
                                  Text('Loading certificate…',
                                      style: TextStyle(
                                          color: AppTheme.grey, fontSize: 13)),
                                ],
                              ),
                            ),
                            errorWidget: (_, url, error) => Container(
                              width: double.infinity,
                              height: isMobile ? 200 : 300,
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image_outlined,
                                      size: 40, color: AppTheme.greyDark),
                                  const SizedBox(height: 12),
                                  const Text('Could not load image.',
                                      style: TextStyle(
                                          color: AppTheme.grey, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Text(url,
                                      style: const TextStyle(
                                          color: AppTheme.greyDark,
                                          fontSize: 10),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.workspace_premium_outlined,
                              size: 15, color: AppTheme.grey),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(widget.cert.name,
                                style: const TextStyle(
                                  fontFamily: 'SpaceGrotesk', fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.white,
                                )),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.border),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(widget.cert.issuer,
                                style: const TextStyle(
                                  fontSize: 10, color: AppTheme.grey,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 16, right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.close,
                    color: AppTheme.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
