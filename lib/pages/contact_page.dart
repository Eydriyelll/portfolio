import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const _contactItems = [
    {
      'label': 'EMAIL',
      'value': 'araos.adriel06@gmail.com',
      'action': 'mailto:araos.adriel06@gmail.com',
      'icon': Icons.mail_outline,
      'copyable': true,
    },
    {
      'label': 'PHONE',
      'value': '09493441883',
      'action': 'tel:09493441883',
      'icon': Icons.phone_outlined,
      'copyable': true,
    },
    {
      'label': 'LOCATION',
      'value': 'Santa Rosa, Laguna\nPhilippines',
      'action': null,
      'icon': Icons.location_on_outlined,
      'copyable': false,
    },
    {
      'label': 'INSTAGRAM',
      'value': '@iitzme_eydriyel',
      'action': 'https://www.instagram.com/iitzme_eydriyel/',
      'icon': Icons.camera_alt_outlined,
      'copyable': false,
    },
    {
      'label': 'FACEBOOK',
      'value': 'adriel.araos.2024',
      'action': 'https://www.facebook.com/adriel.araos.2024',
      'icon': Icons.people_outline,
      'copyable': false,
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
            'CONTACT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.grey,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Let\'s work\ntogether.',
            style: Theme.of(context).textTheme.displaySmall,
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),
          Text(
            'Have a project in mind, or just want to say hi? Reach out anytime.',
            style: Theme.of(context).textTheme.bodyLarge,
          ).animate().fadeIn(delay: 100.ms, duration: 600.ms),

          const SizedBox(height: 56),

          isMobile
              ? Column(
                  children: _contactItems.asMap().entries
                      .map((e) => _ContactCard(item: e.value, index: e.key))
                      .toList(),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3,
                  ),
                  itemCount: _contactItems.length,
                  itemBuilder: (context, i) =>
                      _ContactCard(item: _contactItems[i], index: i),
                ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ContactCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;

  const _ContactCard({required this.item, required this.index});

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _hovered = false;
  bool _copied = false;

  Future<void> _handleTap(BuildContext context) async {
    final action = widget.item['action'] as String?;
    if (action == null) return;

    if (action.startsWith('mailto:') || action.startsWith('tel:')) {
      if (widget.item['copyable'] == true) {
        await Clipboard.setData(ClipboardData(text: widget.item['value']));
        setState(() => _copied = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _copied = false);
      }
      await launchUrl(Uri.parse(action));
    } else {
      await launchUrl(Uri.parse(action));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAction = widget.item['action'] != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: hasAction ? () => _handleTap(context) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: _hovered && hasAction ? AppTheme.card : AppTheme.surface,
            border: Border.all(
              color: _hovered && hasAction ? AppTheme.greyDark : AppTheme.border,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Icon(
                  widget.item['icon'] as IconData,
                  size: 16,
                  color: _hovered ? AppTheme.white : AppTheme.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.item['label'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.greyDark,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.item['value'] as String,
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 14,
                        color: AppTheme.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasAction)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _copied
                      ? const Icon(
                          Icons.check,
                          key: ValueKey('check'),
                          size: 16,
                          color: Color(0xFF4ADE80),
                        )
                      : Icon(
                          widget.item['copyable'] == true
                              ? Icons.copy_outlined
                              : Icons.arrow_outward,
                          key: ValueKey('arrow'),
                          size: 16,
                          color: _hovered ? AppTheme.white : AppTheme.greyDark,
                        ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 80 * widget.index), duration: 400.ms)
        .slideX(begin: 0.05, end: 0);
  }
}
