import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';
import 'package:jdonut_app/features/home/presentation/widgets/banner_section.dart';
import 'package:jdonut_app/features/home/presentation/widgets/product_section.dart';
import 'package:jdonut_app/features/home/presentation/widgets/shop_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: ClampingScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                floating: false,
                // flexibleSpace: _Header(),
                delegate: MyDelegateClass(),
              ),

              SliverToBoxAdapter(child: const SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: ProductSection(title: 'Seasonal specials'),
              ),
              SliverToBoxAdapter(
                child: ProductSection(title: 'Popular 🔥', compact: true),
              ),
              SliverToBoxAdapter(
                child: ProductSection(title: 'Order again', compact: true),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 32)),
              SliverToBoxAdapter(child: ExploreSection()),
              SliverToBoxAdapter(child: const SizedBox(height: 32)),

              // _Header(),
            ],
          ),
          Positioned(
            top: top + 8,
            right: 0,
            child: _NotificationPill(count: 2),
          ),
        ],
      ),
    );
  }
}

class MyDelegateClass extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final top = MediaQuery.of(context).padding.top;

    final progress = (shrinkOffset / 193).clamp(0.0, 1.0);

    final shrinkProgress = (shrinkOffset / 400).clamp(0.0, 1.0);

    final bannerHeight = (193 - shrinkOffset).clamp(0.0, 193.0);

    final profileOpacity = (1 - shrinkProgress).clamp(0.0, 1.0);

    return Opacity(
      opacity: profileOpacity,
      child: Container(
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFEEDC), Color(0xFFFBE6D2)],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        padding: EdgeInsets.fromLTRB(24, top + 24, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _Avatar(),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hania',
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      'Bronze member',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '1290 points left to become Gold Member',
                style: GoogleFonts.nunito(fontSize: 12, color: AppColors.ink),
              ),
            ),
            SizedBox(height: 16 * (1 - progress)),
            SizedBox(
              height: bannerHeight,
              width: double.infinity,
              child: BannerCarousel(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 400;

  @override
  double get minExtent => maxExtent - 193;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF2C79B),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/profile.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: Colors.white,
            child: Icon(Icons.person, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _NotificationPill extends StatelessWidget {
  final int count;

  const _NotificationPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      decoration: const BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_none, color: Colors.white, size: 24),
          const SizedBox(width: 6),
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
