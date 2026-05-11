import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/about_page.dart';
import 'pages/photography_page.dart';
import 'pages/projects_page.dart';
import 'pages/skills_page.dart';
import 'pages/certificates_page.dart';
import 'pages/hobbies_page.dart';
import 'pages/contact_page.dart';
import 'pages/admin_page.dart';
import 'widgets/scaffold_with_sidebar.dart';

void main() {
  runApp(const AdrielPortfolio());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          ScaffoldWithSidebar(child: child),
      routes: [
        GoRoute(path: '/', builder: (c, s) => const HomePage()),
        GoRoute(path: '/about', builder: (c, s) => const AboutPage()),
        GoRoute(path: '/photography', builder: (c, s) => const PhotographyPage()),
        GoRoute(path: '/projects', builder: (c, s) => const ProjectsPage()),
        GoRoute(path: '/skills', builder: (c, s) => const SkillsPage()),
        GoRoute(path: '/certificates', builder: (c, s) => const CertificatesPage()),
        GoRoute(path: '/hobbies', builder: (c, s) => const HobbiesPage()),
        GoRoute(path: '/contact', builder: (c, s) => const ContactPage()),
      ],
    ),
    GoRoute(path: '/admin', builder: (c, s) => const AdminPage()),
  ],
);

class AdrielPortfolio extends StatelessWidget {
  const AdrielPortfolio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Adriel Araos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
