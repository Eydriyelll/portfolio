import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_page_wrapper.dart';
import '../widgets/portfolio_icons.dart';

class HobbiesPage extends StatelessWidget {
  const HobbiesPage({super.key});

  static const List<Map<String, dynamic>> _hobbies = [
    {'name': 'Music', 'desc': 'A constant companion — discovering tracks and getting lost in sound.'},
    {'name': 'Bass Guitar', 'desc': 'Holding down the low end. Groove, rhythm, feel.'},
    {'name': 'Working Out', 'desc': 'Discipline in the gym mirrors discipline in code.'},
    {'name': 'Sports', 'desc': 'Competitive at heart. Sports keep me sharp and grounded.'},
    {'name': 'Reading', 'desc': 'Tech, fiction, or philosophy — always reading something.'},
    {'name': 'Gaming', 'desc': 'Games are interactive art — storytelling and strategy.'},
    {'name': 'Studying', 'desc': 'Always chasing the next concept, skill, or rabbit hole.'},
    {'name': 'Photography', 'desc': 'Capturing light and moments — my second visual language.'},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final w = MediaQuery.of(context).size.width;
    final cols = isMobile ? 2 : (w < 1100 ? 3 : 4);

    return AnimatedPageWrapper(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 28 : 80, vertical: 64,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(label: 'HOBBIES', title: 'Beyond\nthe screen.'),
            const SizedBox(height: 56),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 12, crossAxisSpacing: 12,
                childAspectRatio: isMobile ? 0.88 : 1.0,
              ),
              itemCount: _hobbies.length,
              itemBuilder: (_, i) => _HobbyCard(hobby: _hobbies[i], index: i),
            ),
            const SizedBox(height: 80),
          ],
        ),
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
    final icon = PortfolioIcons.forHobby(widget.hobby['name'] as String);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(22),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: _hovered ? AppTheme.card : AppTheme.surface,
          border: Border.all(
              color: _hovered ? AppTheme.greyDark : AppTheme.border),
          borderRadius: BorderRadius.circular(4),
          boxShadow: _hovered ? [BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12, offset: const Offset(0, 6),
          )] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vector icon badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _hovered
                    ? AppTheme.greyDark
                    : AppTheme.border,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20,
                  color: _hovered ? AppTheme.white : AppTheme.grey),
            ),
            const Spacer(),
            Text(widget.hobby['name'] as String, style: const TextStyle(
              fontFamily: 'SpaceGrotesk', fontSize: 16,
              fontWeight: FontWeight.w600, color: AppTheme.white,
            )),
            const SizedBox(height: 6),
            Text(widget.hobby['desc'] as String, style: const TextStyle(
              fontSize: 12, color: AppTheme.grey, height: 1.5,
            ), maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    ).animate()
        .fadeIn(delay: Duration(milliseconds: 60 * widget.index), duration: 500.ms)
        .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic);
  }
}
