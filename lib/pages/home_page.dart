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
          // Hero
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: size.height - 64),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 28 : 80,
              vertical: isMobile ? 64 : 100,
            ),
            child: isMobile ? _MobileHero() : _DesktopHero(),
          ),

          // Divider strip
          _SkillStrip(),

          // Quick links grid
          _QuickLinks(),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _DesktopHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: _HeroText(),
        ),
        const SizedBox(width: 80),
        Expanded(
          flex: 2,
          child: _HeroVisual(),
        ),
      ],
    );
  }
}

class _MobileHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroText(),
        const SizedBox(height: 48),
        Center(child: _HeroVisual()),
      ],
    );
  }
}

class _HeroText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'PORTFOLIO 2025',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey,
              letterSpacing: 3,
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 28),

        // Name
        Text(
          'Adriel\nAraos.',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: isMobile ? 56 : 80,
            fontWeight: FontWeight.w800,
            color: AppTheme.white,
            letterSpacing: -3,
            height: 0.92,
          ),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 700.ms)
            .slideY(begin: 0.3, end: 0),

        const SizedBox(height: 24),

        // Tagline
        Text(
          'Code. Capture. Create.',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w400,
            color: AppTheme.grey,
            letterSpacing: 1,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 700.ms)
            .slideY(begin: 0.3, end: 0),

        const SizedBox(height: 20),

        // Bio snippet
        Text(
          'Developer & Photographer based in\nSanta Rosa, Laguna, Philippines.',
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.greyDark,
            height: 1.7,
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 700.ms),

        const SizedBox(height: 48),

        // CTA buttons
        Wrap(
          spacing: 16,
          runSpacing: 16,
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
            .fadeIn(delay: 400.ms, duration: 700.ms)
            .slideY(begin: 0.2, end: 0),

        const SizedBox(height: 40),

        // Social links
        Row(
          children: [
            _SocialLink(
              label: 'Instagram',
              url: 'https://www.instagram.com/iitzme_eydriyel/',
            ),
            const SizedBox(width: 24),
            _SocialLink(
              label: 'Facebook',
              url: 'https://www.facebook.com/adriel.araos.2024',
            ),
          ],
        ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppTheme.border),
      ),
      child: Stack(
        children: [
          // Background grid
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: CustomPaint(
              painter: _GridPainter(),
              child: Container(color: AppTheme.surface),
            ),
          ),

          // Center monogram
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ALA',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.white.withOpacity(0.06),
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ADRIEL LEWIS ARAOS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.greyDark,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),

          // Corner decorations
          Positioned(
            top: 16,
            left: 16,
            child: _CornerDot(),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: _CornerDot(),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: _CornerDot(),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: _CornerDot(),
          ),

          // Status badge
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Open to opportunities',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 800.ms)
        .slideX(begin: 0.2, end: 0);
  }
}

class _CornerDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppTheme.greyDark,
        shape: BoxShape.circle,
      ),
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hovered ? AppTheme.accent : AppTheme.white)
                : Colors.transparent,
            border: Border.all(
              color: widget.filled
                  ? AppTheme.white
                  : (_hovered ? AppTheme.white : AppTheme.border),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.filled ? AppTheme.black : AppTheme.white,
              letterSpacing: 0.5,
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
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(widget.url)),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 13,
            color: _hovered ? AppTheme.white : AppTheme.grey,
            decoration:
                _hovered ? TextDecoration.underline : TextDecoration.none,
            decorationColor: AppTheme.white,
            letterSpacing: 0.5,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _SkillStrip extends StatelessWidget {
  final List<String> skills = const [
    'JavaScript',
    'TypeScript',
    'Flutter',
    'React',
    'Python',
    'HTML',
    'CSS',
    'Vercel',
    'Photography',
    'Web Dev',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppTheme.border),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: skills.length * 3,
        separatorBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text('·',
                style: TextStyle(color: AppTheme.greyDark, fontSize: 18)),
          ),
        ),
        itemBuilder: (_, i) => Center(
          child: Text(
            skills[i % skills.length],
            style: const TextStyle(
              fontSize: 12,
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
  final List<Map<String, dynamic>> links = const [
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
        vertical: 64,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXPLORE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.grey,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: isMobile ? 1.2 : 1.4,
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
      child: GestureDetector(
        onTap: () => GoRouter.of(context).go(widget.data['path']),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                widget.data['icon'] as IconData,
                color: _hovered ? AppTheme.white : AppTheme.grey,
                size: 22,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['label'],
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.data['sub'],
                    style: TextStyle(
                      fontSize: 12,
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.border.withOpacity(0.5)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

extension on Container {
  Container get min => this;
}
