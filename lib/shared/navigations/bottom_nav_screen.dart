import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';
import 'package:jdonut_app/features/auth/presentation/screens/logout_screen.dart';
import 'package:jdonut_app/features/home/presentation/screens/home_screen.dart';
import 'package:jdonut_app/features/rewards/presentation/screens/rewards_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(),
      const RewardsScreen(),
      const Scaffold(),
      const Scaffold(),
      const LogoutButton(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _sky = Color(0xFF7BCBE8);
  static const _vPad = 10.0;
  static const _itemHeight = 44.0;

  static const _items = [
    (icon: Icons.home_outlined, label: 'Home'),
    (icon: Icons.workspace_premium_outlined, label: 'Rewards'),
    (icon: Icons.donut_large, label: 'Menu'),
    (icon: Icons.account_balance_wallet_outlined, label: 'Wallet'),
    (icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return SizedBox(
      height: _vPad * 2 + _itemHeight + bottom,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 24 + bottom,
            child: const ColoredBox(color: AppColors.pink),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(8, _vPad, 8, _vPad + bottom),
              decoration: BoxDecoration(
                color: _sky,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < _items.length; i++)
                    _NavItem(
                      icon: _items[i].icon,
                      label: _items[i].label,
                      height: _itemHeight,
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double height;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.height,
    required this.selected,
    required this.onTap,
  });

  static const _duration = Duration(milliseconds: 500);
  static const _bounce = Curves.easeOutBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        height: height,
        duration: _duration,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.pink
              : AppColors.pink.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: Colors.white.withValues(alpha: selected ? 0.8 : 0),
          ),
        ),
        child: AnimatedPadding(
          duration: _duration,
          curve: _bounce,
          padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              AnimatedSize(
                duration: _duration,
                curve: _bounce,
                alignment: Alignment.centerLeft,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          label,
                          maxLines: 1,
                          softWrap: false,
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
