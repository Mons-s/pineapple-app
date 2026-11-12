import 'package:flutter/material.dart';
import '../../services/mock_data.dart';
import 'dashboard_screen.dart';
import 'orders_screen.dart';
import 'batches_screen.dart';
import 'settings_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  final _navItems = const [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
    _NavItem(icon: Icons.inventory_2_rounded, label: 'Batches'),
    _NavItem(icon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(),
      OrdersScreen(),
      BatchesScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: const Color(0xFF16281F),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD98F27),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('🍍', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FreshPine',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          Text('Admin Panel',
                              style: TextStyle(
                                  color: Color(0xFF7A9E84),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Nav items
                ...List.generate(_navItems.length, (i) {
                  final item = _navItems[i];
                  final selected = _selectedIndex == i;
                  return _SidebarTile(
                    icon: item.icon,
                    label: item.label,
                    selected: selected,
                    badge: i == 1
                        ? (MockData.orders.where((o) => o.status == 'placed').length > 0
                            ? MockData.orders.where((o) => o.status == 'placed').length
                            : null)
                        : null,
                    onTap: () => setState(() => _selectedIndex = i),
                  );
                }),
                const Spacer(),
                // Admin info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3828),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF2F6B4F),
                          child: Text('M',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Moncy Simon',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis),
                              Text('Admin',
                                  style: TextStyle(
                                      color: Color(0xFF7A9E84), fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content area
          Expanded(child: screens[_selectedIndex]),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int? badge;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.selected
                ? const Color(0xFF2F6B4F)
                : _hovered
                    ? const Color(0xFF1E3828)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(widget.icon,
                  size: 18,
                  color: widget.selected
                      ? Colors.white
                      : const Color(0xFF7A9E84)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.selected
                        ? Colors.white
                        : const Color(0xFF7A9E84),
                    fontSize: 13,
                    fontWeight: widget.selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              if (widget.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD98F27),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${widget.badge}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
