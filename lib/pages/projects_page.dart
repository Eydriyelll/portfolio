import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  static const List<Map<String, dynamic>> _projects = [
    {
      'name': 'ToGo',
      'desc': 'A scheduling web application built for streamlined task and appointment management.',
      'url': 'https://togo-scheduling.vercel.app/',
      'tags': ['Web App', 'Scheduling', 'Vercel'],
      'status': 'Live',
    },
    {
      'name': 'Games of the General',
      'desc': 'A web-based strategy game inspired by the classic Filipino board game.',
      'url': 'https://games-of-the-general.vercel.app/',
      'tags': ['Game', 'Web', 'Vercel'],
      'status': 'Live',
    },
    {
      'name': 'MakiPrint',
      'desc': 'An ongoing printing service platform designed to streamline print orders online.',
      'url': 'https://maki-print.vercel.app/',
      'tags': ['Web App', 'E-commerce', 'Ongoing'],
      'status': 'In Progress',
    },
  ];

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
            'PROJECTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.grey,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Things I\'ve\nbuilt.',
            style: Theme.of(context).textTheme.displaySmall,
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 56),

          ..._projects.asMap().entries.map(
                (e) => _ProjectCard(project: e.value, index: e.key),
              ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Map<String, dynamic> project;
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
    final isOngoing = widget.project['status'] == 'In Progress';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(widget.project['url'])),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.card : AppTheme.surface,
            border: Border.all(
              color: _hovered ? AppTheme.greyDark : AppTheme.border,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: isMobile
              ? _MobileContent(project: widget.project, hovered: _hovered)
              : _DesktopContent(project: widget.project, hovered: _hovered),
        ),
      )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: 100 * widget.index),
            duration: 600.ms,
          )
          .slideY(begin: 0.1, end: 0),
    );
  }
}

class _DesktopContent extends StatelessWidget {
  final Map<String, dynamic> project;
  final bool hovered;

  const _DesktopContent({required this.project, required this.hovered});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    project['name'],
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(status: project['status']),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                project['desc'],
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.grey,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: (project['tags'] as List<String>)
                    .map((t) => _Tag(label: t))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Icon(
          Icons.arrow_outward,
          color: hovered ? AppTheme.white : AppTheme.greyDark,
          size: 20,
        ),
      ],
    );
  }
}

class _MobileContent extends StatelessWidget {
  final Map<String, dynamic> project;
  final bool hovered;

  const _MobileContent({required this.project, required this.hovered});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatusBadge(status: project['status']),
            Icon(
              Icons.arrow_outward,
              color: hovered ? AppTheme.white : AppTheme.greyDark,
              size: 18,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          project['name'],
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          project['desc'],
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.grey,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: (project['tags'] as List<String>)
              .map((t) => _Tag(label: t))
              .toList(),
        ),
      ],
    );
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
        border: Border.all(
          color: isLive
              ? const Color(0xFF4ADE80).withOpacity(0.3)
              : const Color(0xFFFBBF24).withOpacity(0.3),
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isLive ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
