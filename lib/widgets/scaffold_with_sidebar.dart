import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class ScaffoldWithSidebar extends StatefulWidget {
  final Widget child;
  const ScaffoldWithSidebar({super.key, required this.child});

  @override
  State<ScaffoldWithSidebar> createState() => _ScaffoldWithSidebarState();
}

class _ScaffoldWithSidebarState extends State<ScaffoldWithSidebar>
    with SingleTickerProviderStateMixin {
  bool _sidebarOpen = false;
  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  final List<_NavItem> _navItems = [
    _NavItem('Home', '/', Icons.home_outlined),
    _NavItem('About', '/about', Icons.person_outline),
    _NavItem('Photography', '/photography', Icons.camera_alt_outlined),
    _NavItem('Projects', '/projects', Icons.code_outlined),
    _NavItem('Skills', '/skills', Icons.bolt_outlined),
    _NavItem('Certificates', '/certificates', Icons.workspace_premium_outlined),
    _NavItem('Hobbies', '/hobbies', Icons.favorite_outline),
    _NavItem('Contact', '/contact', Icons.mail_outline),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<double>(begin: -1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() => _sidebarOpen = !_sidebarOpen);
    if (_sidebarOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _closeSidebar() {
    if (_sidebarOpen) {
      setState(() => _sidebarOpen = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              _TopBar(onMenuTap: _toggleSidebar, isOpen: _sidebarOpen),
              Expanded(child: widget.child),
            ],
          ),

          // Overlay
          if (_sidebarOpen)
            AnimatedBuilder(
              animation: _fadeAnim,
              builder: (_, __) => GestureDetector(
                onTap: _closeSidebar,
                child: Container(
                  color: Colors.black.withOpacity(0.6 * _fadeAnim.value),
                ),
              ),
            ),

          // Sidebar drawer
          AnimatedBuilder(
            animation: _slideAnim,
            builder: (_, __) => Transform.translate(
              offset: Offset(_slideAnim.value * (isMobile ? 280 : 320), 0),
              child: _SidebarDrawer(
                navItems: _navItems,
                currentLocation: location,
                onItemTap: (path) {
                  context.go(path);
                  _closeSidebar();
                },
                onClose: _closeSidebar,
                width: isMobile ? 280 : 320,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final bool isOpen;

  const _TopBar({required this.onMenuTap, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppTheme.black,
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          GestureDetector(
            onTap: () => GoRouter.of(context).go('/'),
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'ADRIEL',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.white,
                      letterSpacing: 3,
                    ),
                  ),
                  TextSpan(
                    text: '.',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.grey,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Hamburger
          GestureDetector(
            onTap: onMenuTap,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isOpen ? Icons.close : Icons.menu,
                key: ValueKey(isOpen),
                color: AppTheme.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarDrawer extends StatelessWidget {
  final List<_NavItem> navItems;
  final String currentLocation;
  final void Function(String) onItemTap;
  final VoidCallback onClose;
  final double width;

  const _SidebarDrawer({
    required this.navItems,
    required this.currentLocation,
    required this.onItemTap,
    required this.onClose,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: width,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(right: BorderSide(color: AppTheme.border, width: 1)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADRIEL ARAOS',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.white,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code. Capture. Create.',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 12,
                        color: AppTheme.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: AppTheme.border, height: 1),
              const SizedBox(height: 16),

              // Nav items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: navItems.length,
                  itemBuilder: (context, i) {
                    final item = navItems[i];
                    final isActive = currentLocation == item.path ||
                        (item.path != '/' &&
                            currentLocation.startsWith(item.path));
                    return _NavTile(
                      item: item,
                      isActive: isActive,
                      onTap: () => onItemTap(item.path),
                    );
                  },
                ),
              ),

              const Divider(color: AppTheme.border, height: 1),
              // Footer
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '© 2025 Adriel Araos',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.greyDark,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppTheme.white.withOpacity(0.08)
                : _hovered
                    ? AppTheme.white.withOpacity(0.04)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isActive
                  ? AppTheme.white.withOpacity(0.15)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 18,
                color: widget.isActive ? AppTheme.white : AppTheme.grey,
              ),
              const SizedBox(width: 12),
              Text(
                widget.item.label,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 14,
                  fontWeight: widget.isActive
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: widget.isActive ? AppTheme.white : AppTheme.grey,
                  letterSpacing: 0.3,
                ),
              ),
              if (widget.isActive) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppTheme.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String path;
  final IconData icon;
  const _NavItem(this.label, this.path, this.icon);
}
