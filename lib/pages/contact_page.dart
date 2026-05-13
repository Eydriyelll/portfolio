import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../widgets/animated_page_wrapper.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return AnimatedPageWrapper(
      child: StreamBuilder<ContactData>(
        stream: FirebaseService.contactStream(),
        builder: (context, snap) {
          final c = snap.data ?? ContactData();
          final items = [
            {'label': 'EMAIL', 'value': c.email,
              'action': 'mailto:${c.email}', 'icon': Icons.mail_outline, 'copyable': true},
            {'label': 'PHONE', 'value': c.phone,
              'action': 'tel:${c.phone}', 'icon': Icons.phone_outlined, 'copyable': true},
            {'label': 'LOCATION', 'value': c.address,
              'action': null, 'icon': Icons.location_on_outlined, 'copyable': false},
            {'label': 'INSTAGRAM', 'value': '@iitzme_eydriyel',
              'action': c.instagram, 'icon': Icons.camera_alt_outlined, 'copyable': false},
            {'label': 'FACEBOOK', 'value': 'adriel.araos.2024',
              'action': c.facebook, 'icon': Icons.people_outline, 'copyable': false},
          ];

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 28 : 80, vertical: 64,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(
                  label: 'CONTACT',
                  title: 'Let\'s work\ntogether.',
                  subtitle: 'Have a project in mind, or just want to say hi? Reach out anytime.',
                ),
                const SizedBox(height: 56),
                isMobile
                    ? Column(children: items.asMap().entries
                        .map((e) => _ContactCard(item: e.value, index: e.key))
                        .toList())
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12, crossAxisSpacing: 12,
                          childAspectRatio: 3.2,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, i) =>
                            _ContactCard(item: items[i], index: i),
                      ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
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
  bool _hovered = false, _copied = false;

  Future<void> _handleTap() async {
    final action = widget.item['action'] as String?;
    if (action == null) return;
    if (widget.item['copyable'] == true) {
      await Clipboard.setData(ClipboardData(text: widget.item['value']));
      setState(() => _copied = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _copied = false);
    }
    await launchUrl(Uri.parse(action));
  }

  @override
  Widget build(BuildContext context) {
    final hasAction = widget.item['action'] != null;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: hasAction ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: hasAction ? _handleTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          transform: Matrix4.translationValues(0, _hovered && hasAction ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: _hovered && hasAction ? AppTheme.card : AppTheme.surface,
            border: Border.all(
                color: _hovered && hasAction ? AppTheme.greyDark : AppTheme.border),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _hovered && hasAction ? [BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8, offset: const Offset(0, 3),
            )] : [],
          ),
          child: Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.border, borderRadius: BorderRadius.circular(4)),
              child: Icon(widget.item['icon'] as IconData,
                  size: 16, color: _hovered ? AppTheme.white : AppTheme.grey),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.item['label'] as String, style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: AppTheme.greyDark, letterSpacing: 2,
                )),
                const SizedBox(height: 2),
                Text(widget.item['value'] as String, style: const TextStyle(
                  fontFamily: 'SpaceGrotesk', fontSize: 14,
                  color: AppTheme.white, height: 1.4,
                )),
              ],
            )),
            if (hasAction)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _copied
                    ? const Icon(Icons.check, key: ValueKey('c'),
                        size: 16, color: Color(0xFF4ADE80))
                    : Icon(
                        widget.item['copyable'] == true
                            ? Icons.copy_outlined : Icons.arrow_outward,
                        key: const ValueKey('a'), size: 16,
                        color: _hovered ? AppTheme.white : AppTheme.greyDark),
              ),
          ]),
        ),
      ),
    ).animate()
        .fadeIn(delay: Duration(milliseconds: 80 * widget.index), duration: 400.ms)
        .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
  }
}
