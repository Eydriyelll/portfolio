import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

  static const Map<String, List<Map<String, String>>> _certs = {
    'MMCL — Mapúa Malayan Colleges Laguna': [
      {'name': 'Special Award in Sports (E-sports)'},
      {'name': 'Special Award in Campus Journalism'},
      {'name': 'Service Award — Student Leadership'},
    ],
    'Coursera': [
      {'name': 'Discover the Art of Prompting'},
      {'name': 'Reading and Comprehension of Text in English'},
      {'name': 'Maximize Productivity with AI Tools'},
      {'name': 'Use AI Responsibly'},
      {'name': 'IELTS Reading Section Skills Mastery'},
      {'name': 'Stay Ahead of the AI Curve'},
      {'name': 'Foundations: Data, Data, Everywhere'},
      {'name': 'Introduction to AI'},
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
            'CERTIFICATES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.grey,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Recognition &\nachievements.',
            style: Theme.of(context).textTheme.displaySmall,
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 56),
          ..._certs.entries.toList().asMap().entries.map((outer) {
            final groupIdx = outer.key;
            final entry = outer.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        entry.key.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.grey,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Divider(color: AppTheme.border)),
                  ],
                ),
                const SizedBox(height: 20),
                ...entry.value.asMap().entries.map((e) {
                  return _CertCard(
                    cert: e.value,
                    delay: Duration(
                      milliseconds: (groupIdx * 150) + (e.key * 70),
                    ),
                  );
                }),
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

class _CertCard extends StatefulWidget {
  final Map<String, String> cert;
  final Duration delay;

  const _CertCard({required this.cert, required this.delay});

  @override
  State<_CertCard> createState() => _CertCardState();
}

class _CertCardState extends State<_CertCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _hovered ? AppTheme.card : AppTheme.surface,
          border: Border.all(
            color: _hovered ? AppTheme.greyDark : AppTheme.border,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Icon(
                Icons.workspace_premium_outlined,
                size: 16,
                color: AppTheme.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.cert['name']!,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.white,
                ),
              ),
            ),
            Text(
              widget.cert['year']!,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.greyDark,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: widget.delay, duration: 400.ms)
        .slideX(begin: 0.05, end: 0);
  }
}
