import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class HobbiesPage extends StatelessWidget {
  const HobbiesPage({super.key});

  static const List<Map<String, dynamic>> _hobbies = [
    {
      'name': 'Music',
      'desc': 'Music is a constant companion — from discovering new tracks to getting lost in sound.',
      'icon': Icons.music_note_outlined,
      'emoji': '🎵',
    },
    {
      'name': 'Bass Guitar',
      'desc': 'Holding down the low end. The bass is my instrument of choice — groove and rhythm.',
      'icon': Icons.queue_music_outlined,
      'emoji': '🎸',
    },
    {
      'name': 'Working Out',
      'desc': 'Discipline in the gym mirrors discipline in code. Consistency is everything.',
      'icon': Icons.fitness_center_outlined,
      'emoji': '💪',
    },
    {
      'name': 'Sports',
      'desc': 'Competitive at heart. Sports keep me sharp, social, and grounded.',
      'icon': Icons.sports_outlined,
      'emoji': '🏆',
    },
    {
      'name': 'Reading',
      'desc': 'Books expand the mind. Whether it\'s tech, fiction, or philosophy — always reading.',
      'icon': Icons.menu_book_outlined,
      'emoji': '📚',
    },
    {
      'name': 'Gaming',
      'desc': 'Games are interactive art. Storytelling, strategy, and community all in one.',
      'icon': Icons.sports_esports_outlined,
      'emoji': '🎮',
    },
    {
      'name': 'Studying',
      'desc': 'Lifelong learner. Always chasing the next concept, skill, or rabbit hole.',
      'icon': Icons.school_outlined,
      'emoji': '📖',
    },
    {
      'name': 'Photography',
      'desc': 'Capturing light, mood, and moments. Photography is my second visual language.',
      'icon': Icons.camera_alt_outlined,
      'emoji': '📷',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final crossAxisCount = isMobile ? 2 : (MediaQuery.of(context).size.width < 1100 ? 3 : 4);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 28 : 80,
        vertical: 64,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOBBIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.grey,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Beyond\nthe screen.',
            style: Theme.of(context).textTheme.displaySmall,
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 56),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: isMobile ? 0.9 : 1.0,
            ),
            itemCount: _hobbies.length,
            itemBuilder: (context, i) {
              return _HobbyCard(hobby: _hobbies[i], index: i);
            },
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _HobbyCard extends StatefulWidget {
  final Map<String, dynamic> hobby;
  final int index;

  const _HobbyCard({required this.hobby, required this.index});

  @override
  State<_HobbyCard> createState() => _HobbyCardState();
}

class _HobbyCardState extends State<_HobbyCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _hovered ? AppTheme.card : AppTheme.surface,
          border: Border.all(
            color: _hovered ? AppTheme.greyDark : AppTheme.border,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.hobby['emoji'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
                Icon(
                  widget.hobby['icon'] as IconData,
                  size: 18,
                  color: _hovered ? AppTheme.grey : AppTheme.greyDark,
                ),
              ],
            ),
            const Spacer(),
            Text(
              widget.hobby['name'] as String,
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.hobby['desc'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.grey,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 60 * widget.index),
          duration: 500.ms,
        )
        .slideY(begin: 0.1, end: 0);
  }
}
