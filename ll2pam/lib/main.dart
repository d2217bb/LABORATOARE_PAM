import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cubit/gem_store_cubit.dart';
import 'cubit/gem_store_state.dart';
import 'product_detail_page.dart';
import 'screens/favorites_screen.dart';
import 'screens/account_screen.dart';
import 'screens/cart_screen.dart';
import 'widgets/loading_state_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/error_state_widget.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/sort_dropdown_widget.dart';
import 'models/product.dart';

void main() {
  runApp(const GemStoreApp());
}

class GemStoreApp extends StatelessWidget {
  const GemStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GemStoreCubit>(
      create: (context) => GemStoreCubit()..loadData(),
      child: MaterialApp(
        title: 'GemStore',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF101010),
            surface: const Color(0xFFFFFFFF),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const GemStoreHomePage(),
      ),
    );
  }
}

class GemStoreHomePage extends StatelessWidget {
  const GemStoreHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<GemStoreCubit, GemStoreState>(
          builder: (context, state) {
            if (state is GemStoreLoading || state is GemStoreInitial) {
              return const LoadingStateWidget();
            }

            if (state is GemStoreError) {
              return ErrorStateWidget(
                message: state.message,
                onRetry: () => context.read<GemStoreCubit>().loadData(),
              );
            }

            if (state is GemStoreEmpty) {
              return Column(
                children: [
                  const SizedBox(height: 12),
                  const HeaderSection(),
                  const SizedBox(height: 16),
                  SearchBarWidget(
                    currentQuery: '',
                    onChanged: (q) =>
                        context.read<GemStoreCubit>().searchProducts(q),
                  ),
                  Expanded(
                    child: EmptyStateWidget(
                      message: state.message,
                      onReset: () =>
                          context.read<GemStoreCubit>().clearFilters(),
                    ),
                  ),
                ],
              );
            }

            if (state is GemStoreSuccess) {
              final defaultProduct = state.allProducts.firstWhere(
                (p) => p.id == 'p003',
                orElse: () => state.allProducts.isNotEmpty
                    ? state.allProducts.first
                    : const Product(
                        id: 'p003',
                        name: 'Sportwear Set',
                        price: 80.0,
                        category: 'Women',
                        imageUrl: 'photos/550c305749d6c4a8efe5849bb6952d297db4e2c1.png',
                      ),
              );

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // 1. Header
                    const HeaderSection(),
                    const SizedBox(height: 16),

                    // Search Bar
                    SearchBarWidget(
                      currentQuery: state.searchQuery,
                      onChanged: (query) =>
                          context.read<GemStoreCubit>().searchProducts(query),
                    ),
                    const SizedBox(height: 20),

                    // 2. Categories
                    CategoriesSection(
                      categories: state.categories,
                      selectedCategory: state.selectedCategory,
                    ),
                    const SizedBox(height: 28),

                    // 3. Hero Autumn Collection Banner
                    HeroCollectionBanner(product: defaultProduct),
                    const SizedBox(height: 32),

                    // 4. Feature Products
                    FeatureProductsSection(
                      products: state.displayedProducts,
                      favoriteIds: state.favoriteIds,
                      currentSort: state.sortOption,
                    ),
                    const SizedBox(height: 32),

                    // 5. Banner HANG OUT & PARTY
                    HangOutPartyBanner(product: defaultProduct),
                    const SizedBox(height: 32),

                    // 6. Recommended Section
                    RecommendedSection(products: state.homeData.recommended),
                    const SizedBox(height: 32),

                    // 7. Top Collection Section
                    TopCollectionSection(defaultProduct: defaultProduct),
                    const SizedBox(height: 24),

                    // 8. Category Cards (T-Shirts / Dresses)
                    BottomCategoryCardsSection(defaultProduct: defaultProduct),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

Future<void> _showStoreMenu(BuildContext context) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('All products'),
              onTap: () {
                context.read<GemStoreCubit>().selectCategory('All');
                Navigator.pop(sheetContext, 'all');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My account'),
              onTap: () {
                Navigator.pop(sheetContext, 'account');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Favorites'),
              onTap: () {
                Navigator.pop(sheetContext, 'favorites');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('My cart'),
              onTap: () {
                Navigator.pop(sheetContext, 'cart');
              },
            ),
          ],
        ),
      );
    },
  );

  if (!context.mounted || action == null || action == 'all') return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          action == 'account'
              ? const AccountScreen()
              : action == 'cart'
              ? const CartScreen()
              : const FavoritesScreen(),
    ),
  );
}

/* ============================================================================
 * 1. HEADER SECTION
 * ============================================================================ */
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GemStoreCubit>().state;
    final favCount = (state is GemStoreSuccess) ? state.favoriteIds.length : 0;
    final cartCount = state is GemStoreSuccess
        ? state.cartQuantities.values.fold<int>(0, (sum, count) => sum + count)
        : 0;

    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 24,
            child: GestureDetector(
              onTap: () => _showStoreMenu(context),
              child: const CustomHamburgerIcon(),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              'GemStore',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF101010),
                letterSpacing: -0.3,
              ),
            ),
          ),
          Positioned(
            right: 18,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                  child: _CartHeaderIcon(itemCount: cartCount),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  ),
                  child: BellNotificationIcon(favoriteCount: favCount),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartHeaderIcon extends StatelessWidget {
  final int itemCount;

  const _CartHeaderIcon({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(
          Icons.shopping_bag_outlined,
          size: 23,
          color: Color(0xFF101010),
        ),
        if (itemCount > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF147C83),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$itemCount',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CustomHamburgerIcon extends StatelessWidget {
  const CustomHamburgerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 18, height: 1.8, color: const Color(0xFF101010)),
          const SizedBox(height: 4),
          Container(width: 13, height: 1.8, color: const Color(0xFF101010)),
          const SizedBox(height: 4),
          Container(width: 18, height: 1.8, color: const Color(0xFF101010)),
        ],
      ),
    );
  }
}

class BellNotificationIcon extends StatelessWidget {
  final int favoriteCount;

  const BellNotificationIcon({super.key, this.favoriteCount = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.notifications_none_outlined,
              size: 22,
              color: Color(0xFF101010),
            ),
          ),
          if (favoriteCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF646B),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text(
                  '$favoriteCount',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4D76),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* ============================================================================
 * 2. CATEGORIES SECTION
 * ============================================================================ */
class CategoriesSection extends StatelessWidget {
  final List<dynamic> categories;
  final String selectedCategory;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories.map((cat) {
          final label = cat.label as String;
          final isSelected = label == selectedCategory;
          final iconType = _parseIconType(cat.iconType as String);

          return CategoryItemWidget(
            label: label,
            isSelected: isSelected,
            iconType: iconType,
            onTap: () {
              context.read<GemStoreCubit>().selectCategory(label);
            },
          );
        }).toList(),
      ),
    );
  }

  CategoryIconType _parseIconType(String type) {
    switch (type) {
      case 'men':
        return CategoryIconType.men;
      case 'accessories':
        return CategoryIconType.accessories;
      case 'beauty':
        return CategoryIconType.beauty;
      case 'women':
      default:
        return CategoryIconType.women;
    }
  }
}

enum CategoryIconType { women, men, accessories, beauty }

class CategoryItemWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final CategoryIconType iconType;
  final VoidCallback onTap;

  const CategoryItemWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.iconType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          if (isSelected)
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF382A27), width: 1.2),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF382A27),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomCategoryPainterWidget(
                    iconType: iconType,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F3F4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomCategoryPainterWidget(
                  iconType: iconType,
                  color: const Color(0xFF9A9AA0),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? const Color(0xFF101010)
                  : const Color(0xFF9A9AA0),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCategoryPainterWidget extends StatelessWidget {
  final CategoryIconType iconType;
  final Color color;

  const CustomCategoryPainterWidget({
    super.key,
    required this.iconType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _LineIconPainter(iconType: iconType, color: color),
      ),
    );
  }
}

class _LineIconPainter extends CustomPainter {
  final CategoryIconType iconType;
  final Color color;

  _LineIconPainter({required this.iconType, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (iconType) {
      case CategoryIconType.women:
        canvas.drawCircle(Offset(cx, cy - 2.5), size.width * 0.28, paint);
        canvas.drawLine(Offset(cx, cy + 3), Offset(cx, cy + 8.5), paint);
        canvas.drawLine(
          Offset(cx - 3.5, cy + 5.5),
          Offset(cx + 3.5, cy + 5.5),
          paint,
        );
        break;

      case CategoryIconType.men:
        canvas.drawCircle(Offset(cx - 2, cy + 2), size.width * 0.28, paint);
        canvas.drawLine(
          Offset(cx + 1, cy - 1),
          Offset(cx + 6.5, cy - 6.5),
          paint,
        );
        canvas.drawLine(
          Offset(cx + 6.5, cy - 6.5),
          Offset(cx + 2.5, cy - 6.5),
          paint,
        );
        canvas.drawLine(
          Offset(cx + 6.5, cy - 6.5),
          Offset(cx + 6.5, cy - 2.5),
          paint,
        );
        break;

      case CategoryIconType.accessories:
        canvas.drawCircle(Offset(cx - 4.2, cy + 0.5), 3.2, paint);
        canvas.drawCircle(Offset(cx + 4.2, cy + 0.5), 3.2, paint);
        canvas.drawLine(Offset(cx - 1, cy), Offset(cx + 1, cy), paint);
        canvas.drawLine(
          Offset(cx - 7.2, cy - 1),
          Offset(cx - 9, cy - 4),
          paint,
        );
        canvas.drawLine(
          Offset(cx + 7.2, cy - 1),
          Offset(cx + 9, cy - 4),
          paint,
        );
        break;

      case CategoryIconType.beauty:
        final fillPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 2.5, cy + 1, 5, 7.5),
            const Radius.circular(1),
          ),
          fillPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 1.5, cy - 6, 3, 6),
            const Radius.circular(1),
          ),
          paint,
        );
        canvas.drawLine(Offset(cx - 3, cy + 1), Offset(cx + 3, cy + 1), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _LineIconPainter oldDelegate) =>
      oldDelegate.iconType != iconType || oldDelegate.color != color;
}

/* ============================================================================
 * 3. HERO AUTUMN COLLECTION BANNER
 * ============================================================================ */
class HeroCollectionBanner extends StatefulWidget {
  final Product product;

  const HeroCollectionBanner({super.key, required this.product});

  @override
  State<HeroCollectionBanner> createState() => _HeroCollectionBannerState();
}

class _HeroCollectionBannerState extends State<HeroCollectionBanner> {
  static const _bannerImages = [
    'photos/autumn_collection_new_1.jpg',
    'photos/autumn_collection_new_2.jpg',
    'photos/autumn_collection_new_3.jpg',
  ];

  final PageController _pageController = PageController();
  int _activePage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: widget.product),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 166,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _bannerImages.length,
                    onPageChanged: (page) => setState(() => _activePage = page),
                    itemBuilder: (context, index) => ProductImageWidget(
                      imageUrl: _bannerImages[index],
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withAlpha(115),
                          Colors.black.withAlpha(30),
                          Colors.black.withAlpha(90),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 22,
                  top: 22,
                  child: Text(
                    'Autumn\nCollection\n2021',
                    style: GoogleFonts.poppins(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _bannerImages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == _activePage ? 14 : 6,
                        height: index == _activePage ? 6 : 6,
                        decoration: BoxDecoration(
                          color: index == _activePage
                              ? Colors.white
                              : Colors.white70,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================================================================
 * 4. FEATURE PRODUCTS SECTION
 * ============================================================================ */
class FeatureProductsSection extends StatelessWidget {
  final List<Product> products;
  final Set<String> favoriteIds;
  final String currentSort;

  const FeatureProductsSection({
    super.key,
    required this.products,
    required this.favoriteIds,
    required this.currentSort,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Feature Products',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF101010),
                ),
              ),
              SortDropdownWidget(
                currentSort: currentSort,
                onSortChanged: (sort) {
                  context.read<GemStoreCubit>().sortProducts(sort);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (products.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'No products match your search.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF8A8A91),
              ),
            ),
          ),
        SizedBox(
          height: 235,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = products[index];
              final isFav = favoriteIds.contains(product.id);

              return FeatureProductCard(
                product: product,
                isFavorite: isFav,
                onFavoriteToggle: () {
                  context.read<GemStoreCubit>().toggleFavorite(product.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class FeatureProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const FeatureProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 130,
                  height: 175,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF8F8FA),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ProductImageWidget(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 15,
                          color: isFavorite
                              ? const Color(0xFFFF646B)
                              : const Color(0xFF8A8A91),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF202020),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '\$ ${product.price.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF25252B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================================
 * 5. BANNER HANG OUT & PARTY
 * ============================================================================ */
class HangOutPartyBanner extends StatelessWidget {
  final Product product;

  const HangOutPartyBanner({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: product),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAEAEF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: -10,
                  top: 0,
                  bottom: -10,
                  child: ProductImageWidget(
                    imageUrl:
                        'photos/253f5374175bb9210b2f2de3f4abe98c37fd3cbb.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 1.5,
                            height: 12,
                            color: const Color(0xFF7A808C),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'NEW COLLECTION',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                              color: const Color(0xFF7A808C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'HANG OUT\n& PARTY',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF333743),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================================================================
 * 6. RECOMMENDED SECTION
 * ============================================================================ */
class RecommendedSection extends StatelessWidget {
  final List<Product> products;

  const RecommendedSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GemStoreCubit>().state;
    final favoriteIds = (state is GemStoreSuccess)
        ? state.favoriteIds
        : <String>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: SectionHeader(title: 'Recommended'),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 65,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = products[index];
              final isFav = favoriteIds.contains(product.id);

              return CompactRecommendationTile(
                product: product,
                isFavorite: isFav,
                onFavoriteToggle: () {
                  context.read<GemStoreCubit>().toggleFavorite(product.id);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F2)),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onShowAll;

  const SectionHeader({super.key, required this.title, this.onShowAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101010),
            ),
          ),
        ),
        GestureDetector(
          onTap:
              onShowAll ??
              () => context.read<GemStoreCubit>().selectCategory('All'),
          child: Text(
            'Show all',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9A9A9F),
            ),
          ),
        ),
      ],
    );
  }
}

class CompactRecommendationTile extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const CompactRecommendationTile({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        width: 210,
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 65,
                height: 65,
                child: ProductImageWidget(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF202020),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$ ${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF25252B),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite
                    ? const Color(0xFFFF646B)
                    : const Color(0xFF8A8A91),
              ),
              onPressed: onFavoriteToggle,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

/* ============================================================================
 * 7. TOP COLLECTION SECTION
 * ============================================================================ */
class TopCollectionSection extends StatelessWidget {
  final Product defaultProduct;

  const TopCollectionSection({super.key, required this.defaultProduct});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: SectionHeader(title: 'Top Collection'),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              TopCollectionPromoCard(
                label: 'Sale up to 40%',
                title: 'FOR SLIM\n& BEAUTY',
                isTitleBold: false,
                imagePath:
                    'photos/3d8289e005f646c4c914bb766d81b1457a1815b2.png',
                cardHeight: 145,
                circleSize: 125,
                circleRight: 15,
                circleTop: 10,
                imageRight: 10,
                imageTop: 0,
                product: defaultProduct,
              ),
              const SizedBox(height: 16),
              TopCollectionPromoCard(
                label: 'Summer Collection 2021',
                title: 'Most sexy\n& fabulous\ndesign',
                isTitleBold: true,
                imagePath:
                    'photos/071373fad51ad0143a98105907f84f8d80c53d58.png',
                cardHeight: 165,
                circleSize: 135,
                circleRight: 15,
                circleTop: 15,
                imageRight: 5,
                imageTop: 10,
                product: defaultProduct,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TopCollectionPromoCard extends StatelessWidget {
  final String label;
  final String title;
  final bool isTitleBold;
  final String imagePath;
  final double cardHeight;
  final double circleSize;
  final double circleRight;
  final double circleTop;
  final double imageRight;
  final double imageTop;
  final Product product;

  const TopCollectionPromoCard({
    super.key,
    required this.label,
    required this.title,
    required this.isTitleBold,
    required this.imagePath,
    required this.cardHeight,
    required this.circleSize,
    required this.circleRight,
    required this.circleTop,
    required this.imageRight,
    required this.imageTop,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: cardHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned(
                right: circleRight,
                top: circleTop,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAEAEF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: imageRight,
                top: imageTop,
                bottom: 0,
                child: ProductImageWidget(
                  imageUrl: imagePath,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                ),
              ),
              Positioned(
                left: 20,
                top: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 1.5,
                          height: 12,
                          color: const Color(0xFF97979D),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF97979D),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: isTitleBold
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isTitleBold
                            ? const Color(0xFF101010)
                            : const Color(0xFF333743),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================================================================
 * 8. BOTTOM CATEGORY CARDS (T-SHIRTS & DRESSES)
 * ============================================================================ */
class BottomCategoryCardsSection extends StatelessWidget {
  final Product defaultProduct;

  const BottomCategoryCardsSection({super.key, required this.defaultProduct});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 192,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          BottomCategoryCard(
            category: 'T-Shirts',
            title: 'The\nOffice\nLife',
            imagePath: 'photos/24642656f175b762469766070dae1ee73196af89.png',
            imageOnLeft: true,
            product: defaultProduct,
          ),
          const SizedBox(width: 12),
          BottomCategoryCard(
            category: 'Dresses',
            title: 'Elegant\nDesign',
            imagePath: 'photos/2059944f83f665e563d29b20be6188383e033306.png',
            imageOnLeft: false,
            product: defaultProduct,
          ),
        ],
      ),
    );
  }
}

class BottomCategoryCard extends StatelessWidget {
  final String category;
  final String title;
  final String imagePath;
  final bool imageOnLeft;
  final Product product;

  const BottomCategoryCard({
    super.key,
    required this.category,
    required this.title,
    required this.imagePath,
    required this.imageOnLeft,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        width: 160,
        height: 192,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned(
                left: imageOnLeft ? 0 : null,
                right: imageOnLeft ? null : 0,
                top: 0,
                bottom: 0,
                width: 90,
                child: ProductImageWidget(
                  imageUrl: imagePath,
                  fit: BoxFit.cover,
                  alignment: imageOnLeft
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                ),
              ),
              Positioned(
                left: imageOnLeft ? null : 16,
                right: imageOnLeft ? 12 : null,
                top: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF97979D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF333743),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
