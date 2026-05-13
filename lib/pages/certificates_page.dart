import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../widgets/animated_page_wrapper.dart';

const _defaultCerts = <Map<String, String>>[
  {'name': 'Special Award in Sports (E-sports)', 'issuer': 'MMCL'},
  {'name': 'Special Award in Campus Journalism', 'issuer': 'MMCL'},
  {'name': 'Service Award — Student Leadership', 'issuer': 'MMCL'},
  {'name': 'Discover the Art of Prompting', 'issuer': 'Coursera'},
  {'name': 'Reading and Comprehension of Text in English', 'issuer': 'Coursera'},
  {'name': 'Maximize Productivity with AI Tools', 'issuer': 'Coursera'},
  {'name': 'Use AI Responsibly', 'issuer': 'Coursera'},
  {'name': 'IELTS Reading Section Skills Mastery', 'issuer': 'Coursera'},
  {'name': 'Stay Ahead of the AI Curve', 'issuer': 'Coursera'},
  {'name': 'Foundations: Data, Data, Everywhere', 'issuer': 'Coursera'},
  {'name': 'Introduction to AI', 'issuer': 'Coursera'},
];

class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return AnimatedPageWrapper(
      child: StreamBuilder<List<CertEntry>>(
        stream: FirebaseService.certsStream(),
        builder: (context, snap) {
          final firestoreCerts = snap.data ?? [];
          final allCerts = [
            ..._defaultCerts.map((c) =>
                CertEntry(name: c['name']!, issuer: c['issuer']!)),
            ...firestoreCerts.where((fc) =>
                !_defaultCerts.any((d) => d['name'] == fc.name)),
          ];

          // Group by issuer
          final grouped = <String, List<CertEntry>>{};
          for (final c in allCerts) {
            grouped.putIfAbsent(c.issuer, () => []).add(c);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 28 : 80, vertical: 64,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(
                  label: 'CERTIFICATES',
                  title: 'Recognition &\nachievements.',
                ),
                const SizedBox(height: 56),
                ...grouped.entries.toList().asMap().entries.map((outer) {
                  final gi = outer.key;
                  final entry = outer.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            border: Border.all(color: AppTheme.border),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(entry.key.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700,
                                color: AppTheme.grey, letterSpacing: 2,
                              )),
                        ).animate().fadeIn(
                          delay: Duration(milliseconds: gi * 100),
                          duration: 500.ms,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(child: Divider(color: AppTheme.border)),
                      ]),
                      const SizedBox(height: 20),
                      ...entry.value.asMap().entries.map((e) => _CertCard(
                        cert: e.value,
                        delay: Duration(
                            milliseconds: (gi * 100) + (e.key * 60)),
                      )),
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

class _CertCard extends StatefulWidget {
  final CertEntry cert;
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
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: _hovered ? AppTheme.card : AppTheme.surface,
          border: Border.all(
              color: _hovered ? AppTheme.greyDark : AppTheme.border),
          borderRadius: BorderRadius.circular(4),
          boxShadow: _hovered
              ? [BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.workspace_premium_outlined,
                size: 16, color: AppTheme.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(widget.cert.name, style: const TextStyle(
              fontFamily: 'SpaceGrotesk', fontSize: 14,
              fontWeight: FontWeight.w500, color: AppTheme.white,
            )),
          ),
        ]),
      ),
    ).animate()
        .fadeIn(delay: widget.delay, duration: 400.ms)
        .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
  }
}
