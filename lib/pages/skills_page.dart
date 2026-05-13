import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../widgets/animated_page_wrapper.dart';
import '../widgets/portfolio_icons.dart';

// Hardcoded defaults — Firestore additions merge on top
const _defaultSkills = <Map<String, String>>[
  {'name': 'JavaScript', 'category': 'Languages'},
  {'name': 'TypeScript', 'category': 'Languages'},
  {'name': 'Python', 'category': 'Languages'},
  {'name': 'HTML', 'category': 'Languages'},
  {'name': 'CSS', 'category': 'Languages'},
  {'name': 'Dart', 'category': 'Languages'},
  {'name': 'React', 'category': 'Frameworks & Libraries'},
  {'name': 'Flutter', 'category': 'Frameworks & Libraries'},
  {'name': 'Vercel', 'category': 'Tools & Platforms'},
  {'name': 'Git', 'category': 'Tools & Platforms'},
  {'name': 'VS Code', 'category': 'Tools & Platforms'},
  {'name': 'Firebase', 'category': 'Tools & Platforms'},
  {'name': 'Photography', 'category': 'Other Skills'},
  {'name': 'UI/UX Thinking', 'category': 'Other Skills'},
  {'name': 'Web Development', 'category': 'Other Skills'},
];

class SkillsPage extends StatelessWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return AnimatedPageWrapper(
      child: StreamBuilder<List<SkillEntry>>(
        stream: FirebaseService.skillsStream(),
        builder: (context, snap) {
          // Merge defaults + Firestore
          final firestoreSkills = snap.data ?? [];
          final allSkills = [
            ..._defaultSkills.map((s) => SkillEntry(name: s['name']!, category: s['category']!)),
            ...firestoreSkills.where((fs) =>
                !_defaultSkills.any((d) => d['name'] == fs.name)),
          ];

          // Group by category
          final grouped = <String, List<SkillEntry>>{};
          for (final s in allSkills) {
            grouped.putIfAbsent(s.category, () => []).add(s);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 28 : 80, vertical: 64,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(label: 'SKILLS', title: 'What I\nwork with.'),
                const SizedBox(height: 56),
                ...grouped.entries.toList().asMap().entries.map((outer) {
                  final gi = outer.key;
                  final entry = outer.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(entry.key.toUpperCase(), style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppTheme.grey, letterSpacing: 2,
                        )).animate().fadeIn(
                          delay: Duration(milliseconds: gi * 80), duration: 500.ms),
                        const SizedBox(width: 14),
                        const Expanded(child: Divider(color: AppTheme.border)),
                      ]),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10, runSpacing: 10,
                        children: entry.value.asMap().entries.map((e) =>
                          _SkillChip(
                            skill: e.value,
                            delay: Duration(milliseconds: (gi * 60) + (e.key * 45)),
                          ),
                        ).toList(),
                      ),
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

class _SkillChip extends StatefulWidget {
  final SkillEntry skill;
  final Duration delay;
  const _SkillChip({required this.skill, required this.delay});

  @override
  State<_SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<_SkillChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final icon = PortfolioIcons.forSkill(widget.skill.name);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: _hovered ? AppTheme.card : AppTheme.surface,
          border: Border.all(color: _hovered ? AppTheme.greyDark : AppTheme.border),
          borderRadius: BorderRadius.circular(4),
          boxShadow: _hovered ? [BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8, offset: const Offset(0, 4),
          )] : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16,
              color: _hovered ? AppTheme.white : AppTheme.grey),
          const SizedBox(width: 8),
          Text(widget.skill.name, style: TextStyle(
            fontFamily: 'SpaceGrotesk', fontSize: 14, fontWeight: FontWeight.w500,
            color: _hovered ? AppTheme.white : AppTheme.grey,
          )),
        ]),
      ),
    ).animate().fadeIn(delay: widget.delay, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }
}
