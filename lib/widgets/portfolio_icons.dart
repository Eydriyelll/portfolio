import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Clean vector icons for skills — no emojis
class PortfolioIcons {
  static const Map<String, IconData> skillIcons = {
    'JavaScript': Icons.code,
    'TypeScript': Icons.code_off,
    'Python': Icons.terminal,
    'HTML': Icons.html,
    'CSS': Icons.css,
    'Dart': Icons.adjust,
    'React': Icons.all_inclusive,
    'Flutter': Icons.flutter_dash,
    'Vercel': Icons.cloud_done_outlined,
    'Git': Icons.merge,
    'VS Code': Icons.edit_note,
    'Firebase': Icons.local_fire_department_outlined,
    'Photography': Icons.camera_alt_outlined,
    'UI/UX Thinking': Icons.palette_outlined,
    'Web Development': Icons.language_outlined,
    'default': Icons.star_outline,
  };

  static const Map<String, IconData> hobbyIcons = {
    'Music': Icons.headphones_outlined,
    'Bass Guitar': Icons.music_note_outlined,
    'Working Out': Icons.fitness_center_outlined,
    'Sports': Icons.emoji_events_outlined,
    'Reading': Icons.menu_book_outlined,
    'Gaming': Icons.sports_esports_outlined,
    'Studying': Icons.school_outlined,
    'Photography': Icons.camera_alt_outlined,
    'default': Icons.star_outline,
  };

  static IconData forSkill(String name) =>
      skillIcons[name] ?? skillIcons['default']!;

  static IconData forHobby(String name) =>
      hobbyIcons[name] ?? hobbyIcons['default']!;

  /// Renders a clean vector icon badge
  static Widget badge(IconData icon, {double size = 20, Color? color}) {
    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        color: AppTheme.border,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: size, color: color ?? AppTheme.grey),
    );
  }
}
