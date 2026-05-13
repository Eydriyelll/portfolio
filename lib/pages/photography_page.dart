import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class PhotographyPage extends StatelessWidget {
  const PhotographyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              isMobile ? 28 : 80, 48, isMobile ? 28 : 80, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PHOTOGRAPHY', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: AppTheme.grey, letterSpacing: 3,
              )),
              const SizedBox(height: 10),
              Text('Through\nthe lens.',
                style: Theme.of(context).textTheme.displaySmall,
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 10),
              const Text(
                'A visual journal — moments captured, stories told.',
                style: TextStyle(fontSize: 14, color: AppTheme.grey, height: 1.6),
              ),
            ],
          ),
        ),

        // StreamBuilder for live updates
        Expanded(
          child: StreamBuilder<List<PhotoEntry>>(
            stream: FirebaseService.photosStream(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(
                  color: AppTheme.white, strokeWidth: 1,
                ));
              }
              if (snap.hasError) {
                return _ErrorState(error: snap.error.toString());
              }
              final photos = snap.data ?? [];
              if (photos.isEmpty) return const _EmptyState();
              return _MasonryGallery(photos: photos);
            },
          ),
        ),
      ],
    );
  }
}

class _MasonryGallery extends StatelessWidget {
  final List<PhotoEntry> photos;
  const _MasonryGallery({required this.photos});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;
    final cols = isMobile ? 2 : (w < 1200 ? 3 : 4);

    return MasonryGridView.count(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 80, vertical: 4),
      crossAxisCount: cols,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: photos.length,
      itemBuilder: (context, i) => _PhotoCard(photo: photos[i], index: i)
          .animate()
          .fadeIn(delay: Duration(milliseconds: 40 * (i % 12)), duration: 500.ms),
    );
  }
}

class _PhotoCard extends StatefulWidget {
  final PhotoEntry photo;
  final int index;
  const _PhotoCard({required this.photo, required this.index});

  @override
  State<_PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<_PhotoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.96),
          builder: (_) => _FullscreenViewer(photo: widget.photo),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: widget.photo.thumbnailUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) => Container(
                  height: 200, color: AppTheme.surface,
                  child: const Center(child: SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 1, color: AppTheme.greyDark),
                  )),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 200, color: AppTheme.surface,
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: AppTheme.greyDark),
                ),
              ),
              AnimatedOpacity(
                opacity: _hovered ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                  child: const Center(
                    child: Icon(Icons.zoom_in, color: AppTheme.white, size: 26),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullscreenViewer extends StatelessWidget {
  final PhotoEntry photo;
  const _FullscreenViewer({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),
          Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: photo.url,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.white, strokeWidth: 1),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20, right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.close, color: AppTheme.white, size: 18),
              ),
            ),
          ),
          Positioned(
            bottom: 24, left: 24,
            child: Text(photo.name, style: const TextStyle(
              color: AppTheme.grey, fontSize: 11, letterSpacing: 0.5,
            )),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.camera_alt_outlined, size: 44, color: AppTheme.greyDark),
      SizedBox(height: 14),
      Text('No photos yet', style: TextStyle(
        fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.white)),
      SizedBox(height: 6),
      Text('Upload from yoursite.com/#/admin',
          style: TextStyle(fontSize: 13, color: AppTheme.grey)),
    ]),
  );
}

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.wifi_off_outlined, size: 44, color: AppTheme.greyDark),
      const SizedBox(height: 14),
      const Text('Could not load photos', style: TextStyle(
        fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.white)),
      const SizedBox(height: 8),
      Text(error, style: const TextStyle(fontSize: 11, color: AppTheme.greyDark)),
    ]),
  );
}
