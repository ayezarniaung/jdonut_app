import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:jdonut_app/features/home/data/models/banner_model.dart';
import 'package:jdonut_app/features/home/presentation/providers/repository_provider.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';

class BannerCarousel extends ConsumerStatefulWidget {
  const BannerCarousel({super.key});

  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  late Future<List<BannerModel>> _bannersFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _bannersFuture = ref.read(bannerRepositoryProvider).getBanners();
  }

  void _retry() {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BannerModel>>(
      future: _bannersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (snapshot.hasError) {
          return _buildError();
        }

        final banners = snapshot.data ?? [];

        if (banners.isEmpty) {
          return _buildEmpty();
        }

        return _buildCarousel(banners);
      },
    );
  }

  // Carousel
  Widget _buildCarousel(List<BannerModel> banners) {
    return CarouselSlider.builder(
      itemCount: banners.length,
      itemBuilder: (context, index, realIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _BannerCard(banner: banners[index]),
        );
      },
      options: CarouselOptions(
        viewportFraction: 0.8,
        enlargeCenterPage: false,
        autoPlay: banners.length > 1,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.easeInOut,
        onPageChanged: (index, reason) {
          setState(() {});
        },
      ),
    );
  }

  // Skeleton Loading
  Widget _buildLoading() {
    return CarouselSlider.builder(
      itemCount: 2,
      itemBuilder: (context, index, realIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Shimmer(
            enabled: true,
            period: const Duration(milliseconds: 1500),
            gradient: const LinearGradient(
              colors: [Color(0xFFE6E6E6), Color(0xFFF5F5F5), Color(0xFFE6E6E6)],
              stops: [0.1, 0.5, 0.9],
            ),
            child: Container(
              width: double.infinity,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 170,
        viewportFraction: 0.8,
        enlargeCenterPage: false,
      ),
    );
  }

  // Empty State
  Widget _buildEmpty() {
    return const SizedBox(
      height: 170,
      child: Center(child: Text('No promotions available')),
    );
  }

  // Error State
  Widget _buildError() {
    return SizedBox(
      height: 170,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Unable to load promotions'),
            const SizedBox(height: 8),
            TextButton(onPressed: _retry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel banner;

  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/product/${banner.productId}');
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              image: DecorationImage(
                image: AssetImage(banner.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          if (banner.isPopular)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                child: Text(
                  'Popular',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
