import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';

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
          const _ServicesSection(),
          const _ReviewSection(),
          const _QuickLinks(),
          const _FooterCredits(),
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

    return StreamBuilder<String?>(
      stream: FirebaseService.profilePhotoStream(),
      builder: (context, snap) {
        final remoteUrl = snap.data;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border, width: 1.5),
              ),
              child: ClipOval(
                child: remoteUrl != null
                    ? Image.network(
                        remoteUrl,
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -0.2),
                      )
                    : Image.asset(
                        'assets/images/profile.jpg',
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -0.2),
                      ),
              ),
            ),
            const SizedBox(height: 24),
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
                        color: Color(0xFF4ADE80), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  const Text('Open to opportunities',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.grey,
                          letterSpacing: 0.3)),
                ],
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 800.ms)
            .slideX(begin: 0.15, end: 0);
      },
    );
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
            'PORTFOLIO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey,
              letterSpacing: 3,
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
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
        ).animate().fadeIn(delay: 280.ms, duration: 600.ms),
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
            const Text('·',
                style: TextStyle(color: AppTheme.greyDark, fontSize: 16)),
            const SizedBox(width: 4),
            _SocialLink(
              label: 'Facebook',
              url: 'https://www.facebook.com/adriel.araos.2024',
            ),
          ],
        ).animate().fadeIn(delay: 450.ms, duration: 600.ms),
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
            decoration:
                _hovered ? TextDecoration.underline : TextDecoration.none,
            decorationColor: AppTheme.white,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  static const List<Map<String, String>> services = [
    {
      'title': 'Web Development',
      'text':
          'Responsive websites, landing pages, and portfolio experiences built for speed and clarity.'
    },
    {
      'title': 'UI / UX Design',
      'text':
          'Clean layouts, strong hierarchy, and visual polish that make every interaction feel intentional.'
    },
    {
      'title': 'Photography',
      'text':
          'Creative captures and visual storytelling for personal branding, content, and memorable moments.'
    },
    {
      'title': 'Digital Content',
      'text':
          'Creative assets and polished presentation pieces to help your brand stand out online.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 56),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('WHAT I OFFER',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.grey,
                letterSpacing: 3)),
        const SizedBox(height: 18),
        Text('Services shaped around design, code, and storytelling.',
            style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: isMobile ? 26 : 36,
                fontWeight: FontWeight.w700,
                color: AppTheme.white)),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: isMobile ? 1.2 : 1.35),
          itemCount: services.length,
          itemBuilder: (context, i) => Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(services[i]['title']!,
                    style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.white)),
                const SizedBox(height: 8),
                Text(services[i]['text']!,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.grey, height: 1.6)),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _ReviewSection extends StatefulWidget {
  const _ReviewSection();

  @override
  State<_ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<_ReviewSection> {
  final _nameCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  int _rating = 5;
  bool _sending = false;

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final comment = _commentCtrl.text.trim();
    if (name.isEmpty || comment.isEmpty) return;
    setState(() => _sending = true);
    final err = await FirebaseService.addReview(
        ReviewEntry(name: name, comment: comment, rating: _rating));
    setState(() => _sending = false);
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Review could not be saved: $err',
              style: const TextStyle(color: AppTheme.white)),
          backgroundColor: AppTheme.surface));
      return;
    }
    _nameCtrl.clear();
    _commentCtrl.clear();
    setState(() => _rating = 5);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Thanks for your review!',
            style: TextStyle(color: AppTheme.white)),
        backgroundColor: AppTheme.surface));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CLIENT REVIEWS',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.grey,
                letterSpacing: 3)),
        const SizedBox(height: 18),
        Text('Leave a quick review and rating.',
            style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.w700,
                color: AppTheme.white)),
        const SizedBox(height: 18),
        StreamBuilder<List<ReviewEntry>>(
          stream: FirebaseService.reviewsStream(),
          builder: (context, snap) {
            final reviews = snap.data ?? const <ReviewEntry>[];
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: AppTheme.surface,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(4)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Share your experience',
                              style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.white)),
                          const SizedBox(height: 12),
                          TextField(
                              controller: _nameCtrl,
                              style: const TextStyle(color: AppTheme.white),
                              decoration: const InputDecoration(
                                  hintText: 'Your name',
                                  hintStyle:
                                      TextStyle(color: AppTheme.greyDark),
                                  filled: true,
                                  fillColor: AppTheme.black,
                                  border: OutlineInputBorder())),
                          const SizedBox(height: 10),
                          TextField(
                              controller: _commentCtrl,
                              maxLines: 3,
                              style: const TextStyle(color: AppTheme.white),
                              decoration: const InputDecoration(
                                  hintText: 'Write a short comment',
                                  hintStyle:
                                      TextStyle(color: AppTheme.greyDark),
                                  filled: true,
                                  fillColor: AppTheme.black,
                                  border: OutlineInputBorder())),
                          const SizedBox(height: 12),
                          Row(children: [
                            const Text('Rating:',
                                style: TextStyle(
                                    color: AppTheme.grey, fontSize: 12)),
                            const SizedBox(width: 8),
                            ...List.generate(
                                5,
                                (i) => GestureDetector(
                                    onTap: () =>
                                        setState(() => _rating = i + 1),
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 4),
                                        child: Icon(
                                            i < _rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: const Color(0xFFFFD166),
                                            size: 20)))),
                          ]),
                          const SizedBox(height: 14),
                          Material(
                              color:
                                  _sending ? AppTheme.border : AppTheme.white,
                              borderRadius: BorderRadius.circular(4),
                              child: InkWell(
                                  onTap: _sending ? null : _submit,
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Text(
                                          _sending
                                              ? 'Posting…'
                                              : 'Submit Review',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: _sending
                                                  ? AppTheme.grey
                                                  : AppTheme.black))))),
                        ]),
                  ),
                  const SizedBox(height: 16),
                  Text('Recent feedback',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.grey,
                          letterSpacing: 2)),
                  const SizedBox(height: 8),
                  if (reviews.isEmpty)
                    const Text(
                        'No reviews yet — your first client review will appear here.',
                        style:
                            TextStyle(color: AppTheme.greyDark, fontSize: 12))
                  else
                    ...reviews.take(4).map((review) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: AppTheme.surface,
                              border: Border.all(color: AppTheme.border),
                              borderRadius: BorderRadius.circular(4)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Text(review.name,
                                        style: const TextStyle(
                                            color: AppTheme.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13))),
                                Row(
                                    children: List.generate(
                                        5,
                                        (i) => Icon(
                                            i < review.rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: const Color(0xFFFFD166),
                                            size: 14))),
                              ]),
                              const SizedBox(height: 6),
                              Text(review.comment,
                                  style: const TextStyle(
                                      color: AppTheme.grey,
                                      fontSize: 12,
                                      height: 1.5)),
                            ],
                          ),
                        )),
                ]);
          },
        ),
      ]),
    );
  }
}

class _SkillStrip extends StatelessWidget {
  const _SkillStrip();

  static const List<String> skills = [
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

class _FooterCredits extends StatelessWidget {
  const _FooterCredits();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 6),
      child: Text(
        '© 2026 Adriel Araos. Built with Flutter, Firebase, and creative web design. All rights reserved.',
        style: TextStyle(
            fontSize: 11, color: AppTheme.greyDark, letterSpacing: 0.4),
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
