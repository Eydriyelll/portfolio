import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class SkillsPage extends StatelessWidget {
  const SkillsPage({super.key});

  static const Map<String, List<Map<String, dynamic>>> _skillGroups = {
    'Languages': [
      {'name': 'JavaScript', 'icon': '⚡'},
      {'name': 'TypeScript', 'icon': '🔷'},
      {'name': 'Python', 'icon': '🐍'},
      {'name': 'HTML', 'icon': '🌐'},
      {'name': 'CSS', 'icon': '🎨'},
      {'name': 'Dart', 'icon': '🎯'},
    ],
    'Frameworks & Libraries': [
      {'name': 'React', 'icon': '⚛️'},
      {'name': 'Flutter', 'icon': '🦋'},
    ],
    'Tools & Platforms': [
      {'name': 'Vercel', 'icon': '▲'},
      {'name': 'Git', 'icon': '🌿'},
      {'name': 'VS Code', 'icon': '💻'},
    ],
    'Other Skills': [
      {'name': 'Photography', 'icon': '📷'},
      {'name': 'UI/UX Thinking', 'icon': '🎨'},
      {'name': 'Web Development', 'icon': '🌍'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 28 : 80,
        vertical: 64,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SKILLS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.grey,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'What I\nwork with.',
            style: Theme.of(context).textTheme.displaySmall,
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 56),

          ..._skillGroups.entries.toList().asMap().entries.map((outer) {
            final groupIndex = outer.key;
            final entry = outer.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.grey,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Divider(color: AppTheme.border)),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: entry.value.asMap().entries.map((e) {
                    return _SkillChip(
                      skill: e.value,
                      delay: Duration(
                        milliseconds: (groupIndex * 100) + (e.key * 60),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
              ],
            );
          }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SkillChip extends StatefulWidget {
  final Map<String, dynamic> skill;
  final Duration delay;

  const _SkillChip({required this.skill, required this.delay});

  @override
  State<_SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<_SkillChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _hovered ? AppTheme.card : AppTheme.surface,
          border: Border.all(
            color: _hovered ? AppTheme.greyDark : AppTheme.border,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.skill['icon'] as String, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              widget.skill['name'] as String,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _hovered ? AppTheme.white : AppTheme.grey,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: widget.delay, duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}
