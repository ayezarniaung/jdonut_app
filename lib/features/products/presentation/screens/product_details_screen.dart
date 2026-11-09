import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdonut_app/features/home/data/models/product_model.dart';
import 'package:jdonut_app/features/home/presentation/providers/repository_provider.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  static const _pageBg = Color(0xFFF1F2F4);
  static const _orange = Color(0xFFF07F2B);
  static const _muted = Color(0xFF7B8794);

  static const _minQty = 1;
  static const _maxQty = 99;

  int _qty = 1;

  late Future<ProductModel?> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = ref
        .read(productRepositoryProvider)
        .getProductById(widget.productId);
  }

  int _total(ProductModel product) {
    return product.priceMmk * _qty;
  }

  String _withCommas(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }

  void _change(int delta) {
    final next = (_qty + delta).clamp(_minQty, _maxQty);

    if (next != _qty) {
      setState(() => _qty = next);
    }
  }

  void _addToCart(ProductModel product) {
    debugPrint('Add ${product.code} x$_qty = ${_total(product)} MMK');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel?>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: _pageBg,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: _pageBg,
            appBar: AppBar(),
            body: const Center(child: Text('Product not found')),
          );
        }

        final product = snapshot.data!;

        return _buildProductDetail(product);
      },
    );
  }

  Widget _buildProductDetail(ProductModel product) {
    return Theme(
      data: ThemeData(
        dividerTheme: const DividerThemeData(color: Colors.transparent),
      ),
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(
          title: Text(
            product.name,
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(child: _buildCard(product)),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -28,
                        child: Center(child: _buildStepper()),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                _buildDescription(product),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        persistentFooterButtons: [_buildAddToCart(product)],
      ),
    );
  }

  Widget _buildCard(ProductModel product) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.code,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: _muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (product.isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'New',
                    style: GoogleFonts.fredoka(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

          Text(
            product.name,
            style: GoogleFonts.fredoka(
              fontSize: 34,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '${_withCommas(product.priceMmk)} MMK',
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),

          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _pageBg,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white, width: 2.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundButton(
            icon: Icons.remove,
            onTap: _qty > _minQty ? () => _change(-1) : null,
          ),

          SizedBox(
            width: 64,
            child: Text(
              '$_qty',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),

          _RoundButton(
            icon: Icons.add,
            onTap: _qty < _maxQty ? () => _change(1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ProductModel product) {
    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8DB63C),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '?',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'What’s\nthis?',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),

          Container(width: 2, color: const Color(0xFFE4E6EA)),

          const SizedBox(width: 16),

          Expanded(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.6, 1.0],
                colors: [Colors.black, Colors.black, Colors.transparent],
              ).createShader(rect),
              child: SingleChildScrollView(
                child: Text(
                  product.description,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCart(ProductModel product) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => _addToCart(product),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sky,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ADD TO CART',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),

            Container(
              width: 1.5,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: Colors.white.withValues(alpha: 0.7),
            ),

            Text(
              '${_withCommas(_total(product))} MMK',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: AppColors.sky.withValues(alpha: enabled ? 1 : 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
