import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdonut_app/features/home/data/models/shop_model.dart';
import 'package:jdonut_app/features/home/presentation/providers/repository_provider.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class ExploreSection extends ConsumerWidget {
  const ExploreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color sky = Color(0xFF7BCBE8);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.7, 1.0],
          colors: [sky, Color(0xFFA9D8A0), Color(0xFF8FC27F)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/explore_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),

          FutureBuilder<List<ShopModel>>(
            future: ref.read(shopRepositoryProvider).getShops(),
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;

              final hasError = snapshot.hasError;

              final shops = snapshot.data ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Discover J\'Donut shops\nnear you. 😋',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Material(
                      color: Colors.white,
                      shape: const StadiumBorder(),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Text(
                            'EXPLORE NOW',
                            style: GoogleFonts.fredoka(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: sky,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 276,
                    child: Builder(
                      builder: (context) {
                        if (isLoading) {
                          return _shopSkeletonList();
                        }

                        if (hasError) {
                          return _shopErrorState();
                        }

                        if (shops.isEmpty) {
                          return _shopEmptyState();
                        }

                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: shops.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 16),
                          itemBuilder: (_, i) {
                            return _ShopCard(shop: shops[i]);
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _shopSkeletonList() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 2,
      separatorBuilder: (_, _) => const SizedBox(width: 16),
      itemBuilder: (_, _) {
        return Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Shimmer(
            enabled: true,
            period: const Duration(milliseconds: 1500),
            gradient: const LinearGradient(
              colors: [Color(0xFFE6E6E6), Color(0xFFF5F5F5), Color(0xFFE6E6E6)],
              stops: [0.1, 0.5, 0.9],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                const SizedBox(height: 12),

                _skeletonLine(170, 14),
                const SizedBox(height: 8),

                _skeletonLine(220, 12),
                const SizedBox(height: 6),
                _skeletonLine(150, 12),
                const Spacer(),

                _skeletonLine(84, 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _skeletonLine(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _shopEmptyState() {
    return const Center(
      child: Text('No shops available', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _shopErrorState() {
    return const Center(
      child: Text(
        'Unable to load shops',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final ShopModel shop;

  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: double.infinity,
              height: 140,
              child: Image.asset(
                shop.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: Color(0xFFE3E5E8)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            shop.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            shop.address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 12,
              height: 1.4,
              color: AppColors.ink,
            ),
          ),

          const Spacer(),

          GestureDetector(
            onTap: () {},
            child: Text(
              'Order Online',
              style: GoogleFonts.fredoka(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
