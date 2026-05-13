import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../widgets/animated_page_wrapper.dart';

const _defaultProjects = <Map<String, dynamic>>[
  {
    'name': 'ToGo',
    'description': 'A scheduling web application built for streamlined task and appointment management.',
    'url': 'https://togo-scheduling.vercel.app/',
    'tags': ['Web App', 'Scheduling', 'Vercel'],
    'status': 'Live',
  },
  {
    'name': 'Games of the General',
    'description': 'A web-based strategy game inspired by the classic Filipino board game.',
    'url': 'https://games-of-the-general.vercel.app/',
    'tags': ['Game', 'Web', 'Vercel'],
    'status': 'Live',
  },
  {
    'name': 'MakiPrint',
    'description': 'An ongoing printing service platform designed to streamline print orders online.',
    'url': 'https://maki-print.vercel.app/',
    'tags': ['Web App', 'E-commerce', 'Ongoing'],
    'status': 'In Progress',
  },
];

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return AnimatedPageWrapper(
      child: StreamBuilder<List<ProjectEntry>>(
        stream: FirebaseService.projectsStream(),
        builder: (context, snap) {
          final firestoreProjects = snap.data ?? [];
          final allProjects = [
            ..._defaultProjects.map((p) => ProjectEntry(
              name: p['name'], url: p['url'],
              description: p['description'], status: p['status'],
              tags: List<String>.from(p['tags']),
            )),
            ...firestoreProjects.where((fp) =>
                !_defaultProjects.any((d) => d['name'] == fp.name)),
          ];

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 28 : 80, vertical: 64,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(label: 'PROJECTS', title: 'Things I\'ve\nbuilt.'),
                const SizedBox(height: 56),
                ...allProjects.asMap().entries.map(
                  (e) => _ProjectCard(project: e.value, index: e.key),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final ProjectEntry project;
  final int index;
  const _ProjectCard({required this.project, required this.index});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(widget.project.url)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(28),
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.card : AppTheme.surface,
            border: Border.all(
                color: _hovered ? AppTheme.greyDark : AppTheme.border),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _hovered ? [BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 14, offset: const Offset(0, 6),
            )] : [],
          ),
          child: isMobile
              ? _MobileContent(project: widget.project, hovered: _hovered)
              : _DesktopContent(project: widget.project, hovered: _hovered),
        ),
      ),
    ).animate()
        .fadeIn(delay: Duration(milliseconds: 120 * widget.index), duration: 600.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}

class _DesktopContent extends StatelessWidget {
  final ProjectEntry project;
  final bool hovered;
  const _DesktopContent({required this.project, required this.hovered});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(project.name, style: const TextStyle(
            fontFamily: 'SpaceGrotesk', fontSize: 22,
            fontWeight: FontWeight.w700, color: AppTheme.white,
          )),
          const SizedBox(width: 12),
          _StatusBadge(status: project.status),
        ]),
        const SizedBox(height: 10),
        Text(project.description, style: const TextStyle(
          fontSize: 15, color: AppTheme.grey, height: 1.6,
        )),
        const SizedBox(height: 16),
        Wrap(spacing: 8,
          children: project.tags.map((t) => _Tag(label: t)).toList()),
      ])),
      const SizedBox(width: 24),
      AnimatedRotation(
        turns: hovered ? 0.125 : 0,
        duration: const Duration(milliseconds: 220),
        child: Icon(Icons.arrow_outward,
            color: hovered ? AppTheme.white : AppTheme.greyDark, size: 20),
      ),
    ]);
  }
}

class _MobileContent extends StatelessWidget {
  final ProjectEntry project;
  final bool hovered;
  const _MobileContent({required this.project, required this.hovered});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _StatusBadge(status: project.status),
        AnimatedRotation(
          turns: hovered ? 0.125 : 0,
          duration: const Duration(milliseconds: 220),
          child: Icon(Icons.arrow_outward,
              color: hovered ? AppTheme.white : AppTheme.greyDark, size: 18),
        ),
      ]),
      const SizedBox(height: 10),
      Text(project.name, style: const TextStyle(
        fontFamily: 'SpaceGrotesk', fontSize: 20,
        fontWeight: FontWeight.w700, color: AppTheme.white,
      )),
      const SizedBox(height: 8),
      Text(project.description, style: const TextStyle(
        fontSize: 14, color: AppTheme.grey, height: 1.6,
      )),
      const SizedBox(height: 14),
      Wrap(spacing: 8,
        children: project.tags.map((t) => _Tag(label: t)).toList()),
    ]);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final isLive = status == 'Live';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isLive
            ? const Color(0xFF4ADE80).withOpacity(0.1)
            : const Color(0xFFFBBF24).withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: isLive
            ? const Color(0xFF4ADE80).withOpacity(0.3)
            : const Color(0xFFFBBF24).withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5,
          decoration: BoxDecoration(
            color: isLive ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
            shape: BoxShape.circle,
          )),
        const SizedBox(width: 5),
        Text(status.toUpperCase(), style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1,
          color: isLive ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
        )),
      ]),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: AppTheme.border),
      borderRadius: BorderRadius.circular(2),
    ),
    child: Text(label, style: const TextStyle(
      fontSize: 11, color: AppTheme.grey, letterSpacing: 0.5,
    )),
  );
}
