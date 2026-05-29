import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../services/email_service_stub.dart'
    if (dart.library.js_interop) '../services/email_service.dart';
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
          final contactItems = [
            {
              'label': 'EMAIL',
              'value': c.email,
              'action': 'mailto:${c.email}',
              'icon': Icons.mail_outline,
              'copyable': true
            },
            {
              'label': 'PHONE',
              'value': c.phone,
              'action': 'tel:${c.phone}',
              'icon': Icons.phone_outlined,
              'copyable': true
            },
            {
              'label': 'LOCATION',
              'value': c.address,
              'action': null,
              'icon': Icons.location_on_outlined,
              'copyable': false
            },
            {
              'label': 'INSTAGRAM',
              'value': '@iitzme_eydriyel',
              'action': c.instagram,
              'icon': Icons.camera_alt_outlined,
              'copyable': false
            },
            {
              'label': 'FACEBOOK',
              'value': 'adriel.araos.2024',
              'action': c.facebook,
              'icon': Icons.people_outline,
              'copyable': false
            },
          ];

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 28 : 80, vertical: 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(
                  label: 'CONTACT',
                  title: 'Let\'s work\ntogether.',
                  subtitle:
                      'Have a project in mind, or just want to say hi? Reach out anytime.',
                ),
                const SizedBox(height: 48),

                // Contact info cards
                isMobile
                    ? Column(
                        children: contactItems
                            .asMap()
                            .entries
                            .map((e) =>
                                _ContactCard(item: e.value, index: e.key))
                            .toList())
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 3.4),
                        itemCount: contactItems.length,
                        itemBuilder: (_, i) =>
                            _ContactCard(item: contactItems[i], index: i),
                      ),

                const SizedBox(height: 56),

                // Divider
                Row(children: [
                  const Expanded(child: Divider(color: AppTheme.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR SEND A MESSAGE',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.greyDark,
                            letterSpacing: 2)),
                  ),
                  const Expanded(child: Divider(color: AppTheme.border)),
                ]).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                const SizedBox(height: 40),

                _MessageForm(isMobile: isMobile),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── CONTACT CARD ─────────────────────────────────────────────────
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          transform:
              Matrix4.translationValues(0, _hovered && hasAction ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: _hovered && hasAction ? AppTheme.card : AppTheme.surface,
            border: Border.all(
                color: _hovered && hasAction
                    ? AppTheme.greyDark
                    : AppTheme.border),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _hovered && hasAction
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ]
                : [],
          ),
          child: Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(4)),
                child: Icon(widget.item['icon'] as IconData,
                    size: 16,
                    color: _hovered ? AppTheme.white : AppTheme.grey)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text(widget.item['label'] as String,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.greyDark,
                          letterSpacing: 2)),
                  const SizedBox(height: 2),
                  Text(widget.item['value'] as String,
                      style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 13,
                          color: AppTheme.white,
                          height: 1.4)),
                ])),
            if (hasAction)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _copied
                    ? const Icon(Icons.check,
                        key: ValueKey('c'), size: 15, color: Color(0xFF4ADE80))
                    : Icon(
                        widget.item['copyable'] == true
                            ? Icons.copy_outlined
                            : Icons.arrow_outward,
                        key: const ValueKey('a'),
                        size: 15,
                        color: _hovered ? AppTheme.white : AppTheme.greyDark),
              ),
          ]),
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 80 * widget.index), duration: 400.ms)
        .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
  }
}

// ─── MESSAGE FORM ─────────────────────────────────────────────────
class _MessageForm extends StatefulWidget {
  final bool isMobile;
  const _MessageForm({required this.isMobile});
  @override
  State<_MessageForm> createState() => _MessageFormState();
}

class _MessageFormState extends State<_MessageForm> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  String _service = '';
  bool _sending = false;
  // null = idle, 'ok' = sent, 'err:...' = error
  String? _result;

  static const _services = [
    'Web Development',
    'Photography',
    'UI/UX Design',
    'Collaboration',
    'Other',
  ];

  Future<void> _send() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final msg = _msgCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || msg.isEmpty) {
      setState(() => _result = 'err:Please fill in all required fields.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _result = 'err:Please enter a valid email address.');
      return;
    }

    setState(() {
      _sending = true;
      _result = null;
    });

    final err = await EmailService.sendEmail(
      fromName: name,
      fromEmail: email,
      service: _service.isEmpty ? 'Not specified' : _service,
      message: msg,
    );

    if (!mounted) return;

    if (err == null) {
      _nameCtrl.clear();
      _emailCtrl.clear();
      _msgCtrl.clear();
      setState(() {
        _service = '';
        _sending = false;
        _result = 'ok';
      });
    } else {
      setState(() {
        _sending = false;
        _result = 'err:$err';
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 24 : 36),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Text('Send me a message',
                style: Theme.of(context).textTheme.headlineMedium)
            .animate()
            .fadeIn(delay: 450.ms, duration: 500.ms),
        const SizedBox(height: 6),
        const Text(
          'Fill out the form and I\'ll get back to you as soon as possible.',
          style: TextStyle(fontSize: 14, color: AppTheme.grey, height: 1.6),
        ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
        const SizedBox(height: 32),

        // Name + Email
        widget.isMobile
            ? Column(children: [
                _FormField(
                    label: 'Your Name *',
                    controller: _nameCtrl,
                    hint: 'e.g. Juan dela Cruz'),
                const SizedBox(height: 16),
                _FormField(
                    label: 'Email Address *',
                    controller: _emailCtrl,
                    hint: 'you@email.com',
                    keyboardType: TextInputType.emailAddress),
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: _FormField(
                        label: 'Your Name *',
                        controller: _nameCtrl,
                        hint: 'e.g. Juan dela Cruz')),
                const SizedBox(width: 16),
                Expanded(
                    child: _FormField(
                        label: 'Email Address *',
                        controller: _emailCtrl,
                        hint: 'you@email.com',
                        keyboardType: TextInputType.emailAddress)),
              ]),

        const SizedBox(height: 20),

        // Service
        const _FormLabel('Service Interested In'),
        const SizedBox(height: 6),
        _ServiceDropdown(
            value: _service.isEmpty ? null : _service,
            services: _services,
            onChanged: (v) => setState(() => _service = v ?? '')),

        const SizedBox(height: 20),

        // Message
        _FormField(
            label: 'Message *',
            controller: _msgCtrl,
            hint: 'Tell me about your project or inquiry...',
            maxLines: 5),

        const SizedBox(height: 28),

        // Result banner
        if (_result != null) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _result == 'ok'
                  ? const Color(0xFF4ADE80).withOpacity(0.08)
                  : const Color(0xFFFF5555).withOpacity(0.08),
              border: Border.all(
                  color: _result == 'ok'
                      ? const Color(0xFF4ADE80).withOpacity(0.4)
                      : const Color(0xFFFF5555).withOpacity(0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              Icon(
                  _result == 'ok'
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  size: 16,
                  color: _result == 'ok'
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFFF5555)),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                _result == 'ok'
                    ? 'Message sent! I\'ll get back to you soon. ✓'
                    : _result!.replaceFirst('err:', ''),
                style: TextStyle(
                    fontSize: 13,
                    color: _result == 'ok'
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFFF5555)),
              )),
            ]),
          ),
          const SizedBox(height: 20),
        ],

        // Send button
        SizedBox(
          width: double.infinity,
          child: Material(
            color: _sending ? AppTheme.greyDark : AppTheme.white,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: _sending ? null : _send,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (_sending)
                    const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: AppTheme.grey))
                  else
                    const Icon(Icons.send_outlined,
                        size: 16, color: AppTheme.black),
                  const SizedBox(width: 10),
                  Text(
                    _sending ? 'Sending…' : 'Send Message',
                    style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _sending ? AppTheme.grey : AppTheme.black),
                  ),
                ]),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
      ]),
    )
        .animate()
        .fadeIn(delay: 450.ms, duration: 600.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _FormLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppTheme.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.greyDark, fontSize: 14),
            filled: true,
            fillColor: AppTheme.black,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppTheme.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppTheme.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppTheme.white)),
          ),
        ),
      ]);
}

class _ServiceDropdown extends StatelessWidget {
  final String? value;
  final List<String> services;
  final ValueChanged<String?> onChanged;
  const _ServiceDropdown(
      {required this.value, required this.services, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: AppTheme.black,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: const Text('Select a service…',
                style: TextStyle(color: AppTheme.greyDark, fontSize: 14)),
            isExpanded: true,
            dropdownColor: AppTheme.card,
            icon: const Icon(Icons.keyboard_arrow_down,
                color: AppTheme.grey, size: 20),
            style: const TextStyle(color: AppTheme.white, fontSize: 14),
            items: services
                .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s,
                        style: const TextStyle(
                            color: AppTheme.white, fontSize: 14))))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
}

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel(this.label);
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.grey,
          letterSpacing: 0.5));
}
