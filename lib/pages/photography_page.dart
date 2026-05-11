import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/cloudinary_service.dart';
import '../theme/app_theme.dart';

class PhotographyPage extends StatefulWidget {
  const PhotographyPage({super.key});

  @override
  State<PhotographyPage> createState() => _PhotographyPageState();
}

class _PhotographyPageState extends State<PhotographyPage> {
  List<CloudinaryPhoto> _photos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() { _loading = true; _error = null; });
    try {
      final photos = await CloudinaryService.fetchPhotos();
      if (mounted) setState(() { _photos = photos; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              isMobile ? 28 : 80, 48, isMobile ? 28 : 80, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PHOTOGRAPHY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.grey,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Through\nthe lens.',
                        style: Theme.of(context).textTheme.displaySmall,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                    ],
                  ),
                  // Refresh button
                  if (!_loading)
                    GestureDetector(
                      onTap: _loadPhotos,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.border),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.refresh,
                          color: AppTheme.grey,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'A visual journal — moments captured, stories told.',
                style: TextStyle(fontSize: 14, color: AppTheme.grey, height: 1.6),
              ),
              if (!_loading && _photos.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${_photos.length} photo${_photos.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 12, color: AppTheme.greyDark, letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
        ),

        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.white, strokeWidth: 1,
                  ),
                )
              : _error != null
                  ? _ErrorState(onRetry: _loadPhotos)
                  : _photos.isEmpty
                      ? const _EmptyState()
                      : _MasonryGallery(photos: _photos),
        ),
      ],
    );
  }
}

class _MasonryGallery extends StatelessWidget {
  final List<CloudinaryPhoto> photos;
  const _MasonryGallery({required this.photos});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;
    final crossAxisCount = isMobile ? 2 : (w < 1200 ? 3 : 4);

    return MasonryGridView.count(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 80, vertical: 4,
      ),
      crossAxisCount: crossAxisCount,
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
  final CloudinaryPhoto photo;
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
        onTap: () => _showFullscreen(context),
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
                        color: AppTheme.greyDark, strokeWidth: 1,
                      ),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 200,
                  color: AppTheme.surface,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppTheme.greyDark,
                  ),
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

  void _showFullscreen(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.96),
      builder: (_) => _FullscreenViewer(photo: widget.photo),
    );
  }
}

class _FullscreenViewer extends StatelessWidget {
  final CloudinaryPhoto photo;
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
                    color: AppTheme.white, strokeWidth: 1,
                  ),
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
            child: Text(
              photo.name,
              style: const TextStyle(
                color: AppTheme.grey, fontSize: 11, letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 44, color: AppTheme.greyDark),
          const SizedBox(height: 14),
          const Text(
            'No photos yet',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload from the admin panel — yoursite.com/#/admin',
            style: TextStyle(fontSize: 13, color: AppTheme.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_outlined, size: 44, color: AppTheme.greyDark),
          const SizedBox(height: 14),
          const Text(
            'Could not load photos',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.white),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Retry', style: TextStyle(color: AppTheme.white, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
