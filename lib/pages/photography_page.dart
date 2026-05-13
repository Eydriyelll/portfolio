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
    return StreamBuilder<List<PhotoEntry>>(
      stream: FirebaseService.photosStream(),
      builder: (context, snap) {
        final loading = snap.connectionState == ConnectionState.waiting;
        final photos = snap.data ?? [];
        final isMobile = MediaQuery.of(context).size.width < 768;
        final hPad = isMobile ? 28.0 : 80.0;

        return CustomScrollView(
          slivers: [
            // Header — fully scrollable with the content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 48, hPad, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PHOTOGRAPHY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.grey,
                          letterSpacing: 3,
                        )).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: 12),
                    Text(
                      'Through\nthe lens.',
                      style: Theme.of(context).textTheme.displaySmall,
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 12),
                    const Text(
                      'A visual journal — moments captured, stories told.',
                      style: TextStyle(
                          fontSize: 14, color: AppTheme.grey, height: 1.6),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                    if (!loading && photos.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${photos.length} photo${photos.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.greyDark,
                          letterSpacing: 1,
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                    ],
                  ],
                ),
              ),
            ),

            // Loading state
            if (loading)
              const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(
                  color: AppTheme.white,
                  strokeWidth: 1,
                )),
              )
            else if (snap.hasError)
              SliverFillRemaining(
                  child: _ErrorState(error: snap.error.toString()))
            else if (photos.isEmpty)
              const SliverFillRemaining(child: _EmptyState())
            else
              _MasonrySliver(photos: photos, hPad: hPad),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }
}

class _MasonrySliver extends StatelessWidget {
  final List<PhotoEntry> photos;
  final double hPad;
  const _MasonrySliver({required this.photos, required this.hPad});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w < 768 ? 2 : (w < 1200 ? 3 : 4);

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 4),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: cols,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemBuilder: (context, i) => _PhotoCard(photo: photos[i], index: i),
        childCount: photos.length,
      ),
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
          barrierColor: Colors.black.withAlpha(245),
          builder: (_) => _FullscreenViewer(photo: widget.photo),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: _hovered ? AppTheme.greyDark : Colors.transparent,
            ),
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
                    height: 200,
                    color: AppTheme.surface,
                    child: const Center(
                        child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 1, color: AppTheme.greyDark),
                    )),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    color: AppTheme.surface,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: AppTheme.greyDark),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _hovered ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    color: Colors.black.withAlpha(102),
                    child: const Center(
                      child: Icon(Icons.zoom_in_rounded,
                          color: AppTheme.white, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 40 * (widget.index % 12)),
          duration: 500.ms,
        )
        .slideY(begin: 0.08, end: 0);
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
            top: 20,
            right: 20,
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
            bottom: 24,
            left: 24,
            child: Text(photo.name,
                style: const TextStyle(
                  color: AppTheme.grey,
                  fontSize: 11,
                  letterSpacing: 0.5,
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
          Text('No photos yet',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white)),
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
          const Icon(Icons.wifi_off_outlined,
              size: 44, color: AppTheme.greyDark),
          const SizedBox(height: 14),
          const Text('Could not load photos',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white)),
          const SizedBox(height: 8),
          Text(error,
              style: const TextStyle(fontSize: 11, color: AppTheme.greyDark)),
        ]),
      );
}
