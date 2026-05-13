import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Wraps any page with a consistent entry animation
class AnimatedPageWrapper extends StatelessWidget {
  final Widget child;
  const AnimatedPageWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic);
  }
}

/// Animated section heading with a reveal line
class SectionHeading extends StatelessWidget {
  final String label;
  final String title;
  final String? subtitle;
  final int delay;

  const SectionHeading({
    super.key,
    required this.label,
    required this.title,
    this.subtitle,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with animated underline
        Row(children: [
          Text(label, style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: AppTheme.grey, letterSpacing: 3,
          )).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 500.ms),
          const SizedBox(width: 12),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: v,
                child: const Divider(color: AppTheme.border, height: 1),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        // Title with clip reveal
        ClipRect(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: isMobile ? 36 : 48,
              fontWeight: FontWeight.w800,
              color: AppTheme.white,
              letterSpacing: -2,
              height: 1.0,
            ),
          ).animate().fadeIn(
            delay: Duration(milliseconds: delay + 100), duration: 700.ms,
          ).slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(subtitle!, style: const TextStyle(
            fontSize: 15, color: AppTheme.grey, height: 1.7,
          )).animate().fadeIn(
            delay: Duration(milliseconds: delay + 200), duration: 600.ms,
          ),
        ],
      ],
    );
  }
}

/// Hover card with smooth lift effect
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double elevation;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(24),
    this.elevation = 8,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: widget.padding,
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.card : AppTheme.surface,
            border: Border.all(
              color: _hovered ? AppTheme.greyDark : AppTheme.border,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _hovered
                ? [BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: widget.elevation,
                    offset: const Offset(0, 4),
                  )]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Animated counter number
class AnimatedCounter extends StatelessWidget {
  final int value;
  final String suffix;
  final TextStyle? style;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.suffix = '',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(
        '$v$suffix',
        style: style ?? const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppTheme.white,
        ),
      ),
    );
  }
}

/// Staggered list item reveal
class StaggeredItem extends StatelessWidget {
  final Widget child;
  final int index;
  final int baseDelayMs;

  const StaggeredItem({
    super.key,
    required this.child,
    required this.index,
    this.baseDelayMs = 80,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: baseDelayMs * index),
          duration: 500.ms,
        )
        .slideX(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
  }
}
