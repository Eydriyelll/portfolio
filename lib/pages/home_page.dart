import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return SingleChildScrollView(
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height - 64),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 28 : 80,
                vertical: isMobile ? 64 : 100,
              ),
              child: isMobile ? const _MobileHero() : const _DesktopHero(),
            ),
          ),
          const _SkillStrip(),
          const _QuickLinks(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _DesktopHero extends StatelessWidget {
  const _DesktopHero();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(flex: 3, child: _HeroText()),
        const SizedBox(width: 72),
        Expanded(flex: 2, child: _HeroPhotoCard()),
      ],
    );
  }
}

class _MobileHero extends StatelessWidget {
  const _MobileHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroPhotoCard(height: 280),
        const SizedBox(height: 40),
        const _HeroText(),
      ],
    );
  }
}

class _HeroPhotoCard extends StatelessWidget {
  final double? height;
  const _HeroPhotoCard({this.height});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final avatarSize = isMobile ? 200.0 : 260.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circle avatar with border
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.border, width: 1.5),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile.jpg',
              fit: BoxFit.cover,
              // Show face — slightly center-up crop
              alignment: const Alignment(0, -0.2),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Status badge below avatar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Open to opportunities',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.grey,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 800.ms)
        .slideX(begin: 0.15, end: 0);
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Text(
            'PORTFOLIO 2025',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey,
              letterSpacing: 3,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, end: 0),

        const SizedBox(height: 24),

        Text(
          'Adriel\nAraos.',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: isMobile ? 54 : 76,
            fontWeight: FontWeight.w800,
            color: AppTheme.white,
            letterSpacing: -3,
            height: 0.93,
          ),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 700.ms)
            .slideY(begin: 0.3, end: 0),

        const SizedBox(height: 20),

        const Text(
          'Code. Capture. Create.',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: AppTheme.grey,
            letterSpacing: 0.5,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 700.ms)
            .slideY(begin: 0.2, end: 0),

        const SizedBox(height: 14),

        const Text(
          'Developer & Photographer\nSanta Rosa, Laguna, Philippines.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.greyDark,
            height: 1.7,
          ),
        )
            .animate()
            .fadeIn(delay: 280.ms, duration: 600.ms),

        const SizedBox(height: 40),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _CTAButton(
              label: 'View Projects',
              onTap: () => GoRouter.of(context).go('/projects'),
              filled: true,
            ),
            _CTAButton(
              label: 'Photography',
              onTap: () => GoRouter.of(context).go('/photography'),
              filled: false,
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 350.ms, duration: 600.ms)
            .slideY(begin: 0.15, end: 0),

        const SizedBox(height: 32),

        Row(
          children: [
            _SocialLink(
              label: 'Instagram',
              url: 'https://www.instagram.com/iitzme_eydriyel/',
            ),
            const SizedBox(width: 4),
            const Text('·', style: TextStyle(color: AppTheme.greyDark, fontSize: 16)),
            const SizedBox(width: 4),
            _SocialLink(
              label: 'Facebook',
              url: 'https://www.facebook.com/adriel.araos.2024',
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 450.ms, duration: 600.ms),
      ],
    );
  }
}

class _CTAButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _CTAButton({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hovered ? AppTheme.accent : AppTheme.white)
                : Colors.transparent,
            border: Border.all(
              color: widget.filled
                  ? AppTheme.white
                  : (_hovered ? AppTheme.white : AppTheme.border),
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.filled ? AppTheme.black : AppTheme.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLink extends StatefulWidget {
  final String label;
  final String url;
  const _SocialLink({required this.label, required this.url});

  @override
  State<_SocialLink> createState() => _SocialLinkState();
}

class _SocialLinkState extends State<_SocialLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(widget.url)),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 13,
            color: _hovered ? AppTheme.white : AppTheme.grey,
            decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
            decorationColor: AppTheme.white,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _SkillStrip extends StatelessWidget {
  const _SkillStrip();

  static const List<String> skills = [
    'JavaScript', 'TypeScript', 'Flutter', 'React',
    'Python', 'HTML', 'CSS', 'Vercel', 'Photography', 'Web Dev',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppTheme.border),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: skills.length * 4,
        separatorBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: Text(
              '·',
              style: TextStyle(color: AppTheme.greyDark, fontSize: 16),
            ),
          ),
        ),
        itemBuilder: (_, i) => Center(
          child: Text(
            skills[i % skills.length],
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.greyDark,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks();

  static const List<Map<String, dynamic>> links = [
    {
      'label': 'Photography',
      'sub': 'Visual storytelling',
      'path': '/photography',
      'icon': Icons.camera_alt_outlined,
    },
    {
      'label': 'Projects',
      'sub': 'Code & builds',
      'path': '/projects',
      'icon': Icons.code_outlined,
    },
    {
      'label': 'About',
      'sub': 'Who I am',
      'path': '/about',
      'icon': Icons.person_outline,
    },
    {
      'label': 'Contact',
      'sub': 'Get in touch',
      'path': '/contact',
      'icon': Icons.mail_outline,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 56,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EXPLORE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.grey,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: isMobile ? 1.15 : 1.4,
            ),
            itemCount: links.length,
            itemBuilder: (context, i) => _QuickLinkCard(data: links[i]),
          ),
        ],
      ),
    );
  }
}

class _QuickLinkCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _QuickLinkCard({required this.data});

  @override
  State<_QuickLinkCard> createState() => _QuickLinkCardState();
}

class _QuickLinkCardState extends State<_QuickLinkCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => GoRouter.of(context).go(widget.data['path']),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.card : AppTheme.surface,
            border: Border.all(
              color: _hovered ? AppTheme.greyDark : AppTheme.border,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                widget.data['icon'] as IconData,
                color: _hovered ? AppTheme.white : AppTheme.grey,
                size: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['label'],
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.data['sub'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
