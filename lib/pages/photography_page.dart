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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final photos = await CloudinaryService.fetchPhotos();
      setState(() {
        _photos = photos;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(isMobile ? 28 : 80, 48, isMobile ? 28 : 80, 32),
          child: Column(
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
              const SizedBox(height: 12),
              Text(
                'Through\nthe lens.',
                style: Theme.of(context).textTheme.displaySmall,
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              Text(
                'A visual journal — moments captured, stories told.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),

        // Gallery
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.white,
                    strokeWidth: 1,
                  ),
                )
              : _error != null
                  ? _ErrorState(onRetry: _loadPhotos)
                  : _photos.isEmpty
                      ? _EmptyState()
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
    final isMobile = MediaQuery.of(context).size.width < 768;
    final crossAxisCount = isMobile ? 2 : (MediaQuery.of(context).size.width < 1200 ? 3 : 4);

    return MasonryGridView.count(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 80,
        vertical: 8,
      ),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: photos.length,
      itemBuilder: (context, i) {
        return _PhotoCard(photo: photos[i], index: i)
            .animate()
            .fadeIn(delay: Duration(milliseconds: 50 * (i % 12)), duration: 500.ms);
      },
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
      child: GestureDetector(
        onTap: () => _showFullscreen(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            border: Border.all(
              color: _hovered ? AppTheme.greyDark : Colors.transparent,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
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
                      child: CircularProgressIndicator(
                        color: AppTheme.greyDark,
                        strokeWidth: 1,
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
                // Hover overlay
                AnimatedOpacity(
                  opacity: _hovered ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Icon(
                        Icons.zoom_in,
                        color: AppTheme.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullscreen(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (_) => _FullscreenViewer(photo: widget.photo),
    );
  }
}

class _FullscreenViewer extends StatelessWidget {
  final CloudinaryPhoto photo;

  const _FullscreenViewer({required this.photo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: photo.url,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const CircularProgressIndicator(
                    color: AppTheme.white,
                    strokeWidth: 1,
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
                  child: const Icon(Icons.close, color: AppTheme.white, size: 20),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              child: Text(
                photo.name,
                style: const TextStyle(
                  color: AppTheme.grey,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 48,
            color: AppTheme.greyDark,
          ),
          const SizedBox(height: 16),
          Text(
            'No photos yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your first photo from the admin panel.',
            style: TextStyle(fontSize: 14, color: AppTheme.grey),
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
          const Icon(Icons.wifi_off_outlined, size: 48, color: AppTheme.greyDark),
          const SizedBox(height: 16),
          const Text(
            'Could not load photos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: AppTheme.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
