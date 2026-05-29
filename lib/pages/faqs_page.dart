import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_page_wrapper.dart';

class FaqsPage extends StatelessWidget {
  const FaqsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return AnimatedPageWrapper(
      child: StreamBuilder<List<FaqEntry>>(
        stream: FirebaseService.faqsStream(),
        builder: (context, snap) {
          final faqs = snap.data ?? const <FaqEntry>[];
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80, vertical: 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(
                    label: 'FAQS', title: 'Questions I hear most often.'),
                const SizedBox(height: 24),
                if (faqs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                        'Add FAQs from the admin panel to populate this page.',
                        style: TextStyle(color: AppTheme.grey, fontSize: 13)),
                  )
                else
                  ...faqs.asMap().entries.map(
                      (entry) => _FaqCard(faq: entry.value, index: entry.key)),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  final FaqEntry faq;
  final int index;

  const _FaqCard({required this.faq, required this.index});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 14),
          iconColor: AppTheme.white,
          collapsedIconColor: AppTheme.grey,
          title: Text(
            faq.question,
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.white,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                faq.answer,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.grey, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 80 * index), duration: 400.ms)
        .slideY(begin: 0.06, end: 0);
  }
}
