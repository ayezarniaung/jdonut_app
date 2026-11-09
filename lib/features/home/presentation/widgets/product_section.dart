import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import 'package:jdonut_app/features/home/data/models/product_model.dart';
import 'package:jdonut_app/features/home/presentation/providers/repository_provider.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';
import 'package:jdonut_app/core/router/routes.dart';

class ProductSection extends ConsumerStatefulWidget {
  final String title;
  final bool compact;

  const ProductSection({super.key, required this.title, this.compact = false});

  @override
  ConsumerState<ProductSection> createState() => _ProductSectionState();
}

class _ProductSectionState extends ConsumerState<ProductSection> {
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final repository = ref.read(productRepositoryProvider);

    switch (widget.title) {
      case 'Seasonal specials':
        _productsFuture = repository.getSeasonalProducts();
        break;

      case 'Popular 🔥':
        _productsFuture = repository.getPopularProducts();
        break;

      case 'Order again':
        _productsFuture = repository.getOrderAgainProducts();
        break;

      default:
        _productsFuture = repository.getProducts();
    }
  }

  void onSeeAll() {}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (snapshot.hasError) {
          return _buildError();
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return _buildEmpty();
        }

        return _buildProductList(products);
      },
    );
  }

  // PRODUCT LIST

  Widget _buildProductList(List<ProductModel> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        SizedBox(
          height: widget.compact ? 300 : 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (_, i) => widget.compact
                ? _CompactProductCard(product: products[i])
                : _ProductCard(product: products[i]),
          ),
        ),
      ],
    );
  }

  // HEADER

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onSeeAll,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.chevron_right,
                  size: 26,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SHIMMER LOADING

  Widget _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Shimmer(
            gradient: _shimmerGradient,
            child: Container(
              width: 160,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: widget.compact ? 300 : 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (_, _) {
              return Shimmer(
                gradient: _shimmerGradient,
                child: Container(
                  width: widget.compact ? 160 : 235,
                  height: widget.compact ? 234 : 156,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // EMPTY STATE

  Widget _buildEmpty() {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(
          'No ${widget.title.toLowerCase()} available',
          style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
        ),
      ),
    );
  }

  // ERROR STATE

  Widget _buildError() {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Unable to load products'),
            TextButton(onPressed: () {}, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }

  static const LinearGradient _shimmerGradient = LinearGradient(
    colors: [Color(0xFFE6E6E6), Color(0xFFF5F5F5), Color(0xFFE6E6E6)],
    stops: [0.1, 0.5, 0.9],
  );
}

// PRODUCT CARD

class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/product/${product.id}');
      },
      child: SizedBox(
        width: 235,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: 235,
                    height: 156,
                    child: Image.asset(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: Color(0xFFE3E5E8)),
                    ),
                  ),
                ),
                if (product.discountPercent != null)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Text(
                        '${product.discountPercent}% off',
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// COMPACT PRODUCT CARD

class _CompactProductCard extends StatelessWidget {
  final ProductModel product;

  const _CompactProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/product/${product.id}');
      },
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 160,
                  height: 234,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.expand(),
                  ),
                ),
                if (product.discountPercent != null)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${product.discountPercent}% off',
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
