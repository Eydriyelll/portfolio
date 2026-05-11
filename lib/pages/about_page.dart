import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
          _PageLabel(label: 'ABOUT ME'),
          const SizedBox(height: 16),
          Text(
            'The person\nbehind the screen.',
            style: Theme.of(context).textTheme.displaySmall,
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 48),

          isMobile
              ? _MobileBio()
              : _DesktopBio(),

          const SizedBox(height: 72),
          _SectionDivider(label: 'EDUCATION'),
          const SizedBox(height: 40),
          _EducationTimeline(),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _DesktopBio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _BioText()),
        const SizedBox(width: 64),
        Expanded(flex: 2, child: _InfoCard()),
      ],
    );
  }
}

class _MobileBio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BioText(),
        const SizedBox(height: 40),
        _InfoCard(),
      ],
    );
  }
}

class _BioText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "I'm a passionate developer with a focus on creating intuitive and performant web applications. A self-taught student passionate about web development and various fields within IT, aspiring to become a full-fledged developer not just in web technologies but across multiple development areas.",
          style: Theme.of(context).textTheme.bodyLarge,
        ).animate().fadeIn(delay: 100.ms, duration: 600.ms),

        const SizedBox(height: 20),

        Text(
          "Beyond the screen, I'm drawn to the world through a lens — photography is my other language. Whether capturing candid moments or composed scenes, I see it as another form of storytelling, one that complements my eye for design and detail in code.",
          style: Theme.of(context).textTheme.bodyLarge,
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

        const SizedBox(height: 20),

        Text(
          "A Senior High School graduate and incoming first-year college student at Mapúa Malayan Colleges Laguna, continuously honing my skills to master programming languages and expand my expertise in software development.",
          style: Theme.of(context).textTheme.bodyLarge,
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'LOCATION', 'value': 'Santa Rosa, Laguna\nPhilippines'},
      {'label': 'EMAIL', 'value': 'araos.adriel06@gmail.com'},
      {'label': 'PHONE', 'value': '09493441883'},
      {'label': 'STATUS', 'value': 'Open to opportunities'},
      {'label': 'INSTAGRAM', 'value': '@iitzme_eydriyel'},
      {'label': 'FACEBOOK', 'value': 'adriel.araos.2024'},
    ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['label']!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.greyDark,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['value']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 700.ms).slideX(begin: 0.1, end: 0);
  }
}

class _EducationTimeline extends StatelessWidget {
  final List<Map<String, String>> education = const [
    {
      'school': 'Mapúa Malayan Colleges Laguna',
      'degree': 'Bachelor of Science in Information Technology',
      'period': '2025 – Ongoing',
      'level': '1st Year College',
    },
    {
      'school': 'Mapúa Malayan Colleges Laguna',
      'degree': 'Senior High School — ICT Strand',
      'period': '2023 – 2025',
      'level': 'SHS Graduate',
    },
    {
      'school': 'Emmanuel Christian School',
      'degree': 'Junior High School',
      'period': '2019 – 2023',
      'level': 'JHS Graduate',
    },
    {
      'school': "Sts. Paul & Mark School",
      'degree': 'Elementary',
      'period': '2011 – 2019',
      'level': 'Elementary Graduate',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: education.asMap().entries.map((entry) {
        final i = entry.key;
        final edu = entry.value;
        final isLast = i == education.length - 1;

        return _TimelineItem(
          edu: edu,
          isLast: isLast,
          index: i,
        );
      }).toList(),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Map<String, String> edu;
  final bool isLast;
  final int index;

  const _TimelineItem({
    required this.edu,
    required this.isLast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: index == 0 ? AppTheme.white : AppTheme.greyDark,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: index == 0 ? AppTheme.white : AppTheme.greyDark,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: AppTheme.border,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          edu['period']!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        edu['level']!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.greyDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    edu['school']!,
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    edu['degree']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index), duration: 600.ms);
  }
}

class _PageLabel extends StatelessWidget {
  final String label;
  const _PageLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.grey,
        letterSpacing: 3,
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.grey,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(child: Divider(color: AppTheme.border)),
      ],
    );
  }
}
