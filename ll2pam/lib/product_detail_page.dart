import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cubit/gem_store_cubit.dart';
import 'cubit/gem_store_state.dart';
import 'models/product.dart';
import 'models/review.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedColorIndex = 0; // 0: Bej, 1: Black, 2: Coral
  String selectedSize = 'L';
  String selectedVariant = '';
  bool isDescriptionExpanded = true;
  bool isReviewsExpanded = true;
  bool isSimilarProductsExpanded = true;

  @override
  void initState() {
    super.initState();
    if (widget.product.category != 'Women') {
      selectedVariant = _optionsForProduct().first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GemStoreCubit>().state;
    final isFav = (state is GemStoreSuccess)
        ? state.favoriteIds.contains(widget.product.id)
        : widget.product.isFavorite;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Scrollable main content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Gallery Section
                _buildGallerySection(context, isFav),

                // 2. Product Sheet Overlapping Card
                _buildProductSheet(),
              ],
            ),
          ),

          // 8. Fixed Add To Cart CTA Bar
          _buildFixedCtaBar(context),
        ],
      ),
    );
  }

  /* ============================================================================
   * 1. GALLERY SECTION
   * ============================================================================ */
  Widget _buildGallerySection(BuildContext context, bool isFav) {
    return SizedBox(
      height: 410,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Pale Pink-Beige Circle
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: Color(0xFFFBF1EC),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Main Product Image
          Positioned.fill(
            top: 15,
            bottom: 0,
            child: Center(
              child: SizedBox(
                width: 260,
                height: 390,
                child: ProductImageWidget(
                  imageUrl: widget.product.imageUrl,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),

          // Top Navigation Bar (Back & Favorite Buttons)
          Positioned(
            top: 48,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 12,
                        color: Color(0xFF242424),
                      ),
                    ),
                  ),
                ),

                // Favorite Button
                GestureDetector(
                  onTap: () {
                    context.read<GemStoreCubit>().toggleFavorite(
                      widget.product.id,
                    );
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isFav
                            ? const Color(0xFFFF646B)
                            : const Color(0xFF8A8A91),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Gallery Page Indicator Dots
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF242424),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 3.5,
                      height: 3.5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF242424),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF555555),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF555555),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /* ============================================================================
   * 2. PRODUCT SHEET (INFO, OPTIONS, REVIEWS, SIMILAR PRODUCTS)
   * ============================================================================ */
  Widget _buildProductSheet() {
    return Transform.translate(
      offset: const Offset(0, -35),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Price Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF242424),
                    ),
                  ),
                ),
                Text(
                  '\$ ${widget.product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF242424),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Rating Stars & Count
            Row(
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => const Icon(
                      Icons.star,
                      size: 15,
                      color: Color(0xFF4D9183),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${widget.product.ratingCount > 0 ? widget.product.ratingCount : 83})',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8A91),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Divider
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 18),

            // 3. Category-specific product options
            _buildOptionsSection(),
            const SizedBox(height: 20),

            // Divider
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),

            // 4. Description Accordion
            _buildDescriptionAccordion(),
            const SizedBox(height: 12),

            // Divider
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),

            // 5. Reviews Accordion & Breakdown
            _buildReviewsAccordion(),
            const SizedBox(height: 24),

            // 6. Individual Reviews
            _buildIndividualReviews(),
            const SizedBox(height: 28),

            // Divider
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 20),

            // 7. Similar Products Section
            _buildSimilarProductsSection(),
          ],
        ),
      ),
    );
  }

  /* ============================================================================
   * 3. COLOR & SIZE OPTIONS
   * ============================================================================ */
  Widget _buildOptionsSection() {
    if (widget.product.category != 'Women') {
      return _buildNonClothingOptions();
    }

    final colors = [
      const Color(0xFFE8BCA6), // Bej
      const Color(0xFF050505), // Black
      const Color(0xFFF05F66), // Coral
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Color',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF79839A),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(colors.length, (index) {
                  final isSelected = selectedColorIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColorIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: colors[index],
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: colors[index].withAlpha(100),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Size',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF79839A),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: ['S', 'M', 'L'].map((size) {
                  final isSelected = selectedSize == size;
                  final isDisabled = size == 'S' || size == 'M';

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSize = size;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 29,
                      height: 29,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4B4B4B)
                            : (isDisabled
                                  ? const Color(0xFFF8F8F8)
                                  : Colors.white),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          size,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : (isDisabled
                                      ? const Color(0xFFC0C0C0)
                                      : const Color(0xFF242424)),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNonClothingOptions() {
    final isBeauty = widget.product.category == 'Beauty';
    final options = _optionsForProduct();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBeauty ? 'Choose your option' : 'Choose your variant',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF79839A),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final isSelected = selectedVariant == option;
            return GestureDetector(
              onTap: () => setState(() => selectedVariant = option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF147C83)
                      : const Color(0xFFF4F7F7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF147C83)
                        : const Color(0xFFE1E8E6),
                  ),
                ),
                child: Text(
                  option,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF356E63),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          isBeauty
              ? 'Select the finish or size that suits you.'
              : 'Select the style that suits you.',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: const Color(0xFF9A9EA7),
          ),
        ),
      ],
    );
  }

  List<String> _optionsForProduct() {
    if (widget.product.category == 'Beauty') {
      if (widget.product.name.toLowerCase().contains('lipstick')) {
        return ['Nude', 'Rose', 'Berry'];
      }
      if (widget.product.name.toLowerCase().contains('perfume')) {
        return ['30 ml', '50 ml', '100 ml'];
      }
      return ['Travel size', 'Full size', 'Gift set'];
    }

    final name = widget.product.name.toLowerCase();
    if (name.contains('sunglass')) {
      return ['Black frame', 'Tortoise frame', 'Clear frame'];
    }
    if (name.contains('watch')) {
      return ['Black strap', 'Brown strap', 'Silver strap'];
    }
    if (name.contains('belt')) {
      return ['S (28-30")', 'M (32-34")', 'L (36-38")'];
    }
    return ['Black', 'Tan', 'Cream'];
  }

  /* ============================================================================
   * 4. DESCRIPTION ACCORDION
   * ============================================================================ */
  Widget _buildDescriptionAccordion() {
    final desc = widget.product.description.isNotEmpty
        ? widget.product.description
        : 'Sportswear is no longer under culture, it is no longer indie or cobbled together as it once was. Sport is fashion today. The top is oversized in fit and style, may need to size down.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isDescriptionExpanded = !isDescriptionExpanded;
            });
          },
          child: SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Description',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF242424),
                  ),
                ),
                Icon(
                  isDescriptionExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: const Color(0xFF242424),
                ),
              ],
            ),
          ),
        ),
        if (isDescriptionExpanded) ...[
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$desc '),
                TextSpan(
                  text: 'Read more',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4D9183),
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF777777),
              height: 1.55,
            ),
          ),
        ],
      ],
    );
  }

  /* ============================================================================
   * 5. REVIEWS ACCORDION & BREAKDOWN
   * ============================================================================ */
  Widget _buildReviewsAccordion() {
    final state = context.watch<GemStoreCubit>().state;
    final reviews = state is GemStoreSuccess
        ? (state.reviewsByProduct[widget.product.id] ?? const <ReviewModel>[])
        : const <ReviewModel>[];
    final reviewAverage = reviews.isEmpty
        ? (widget.product.rating > 0 ? widget.product.rating : 4.9)
        : reviews.fold<int>(0, (sum, review) => sum + review.rating) /
              reviews.length;
    final reviewCount = reviews.length;
    final ratingPercentages = {
      for (var star = 5; star >= 1; star--)
        star: reviewCount == 0
            ? 0.0
            : reviews.where((review) => review.rating == star).length /
                  reviewCount,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isReviewsExpanded = !isReviewsExpanded;
            });
          },
          child: SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF242424),
                  ),
                ),
                Icon(
                  isReviewsExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: const Color(0xFF242424),
                ),
              ],
            ),
          ),
        ),
        if (isReviewsExpanded) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    reviewAverage.toStringAsFixed(1),
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF242424),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'OUT OF 5',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8A8A91),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFF4D9183),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$reviewCount ratings',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8A8A91),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildRatingBar(
            star: '5',
            factor: ratingPercentages[5]!,
            percent: '${(ratingPercentages[5]! * 100).round()}%',
          ),
          const SizedBox(height: 6),
          _buildRatingBar(
            star: '4',
            factor: ratingPercentages[4]!,
            percent: '${(ratingPercentages[4]! * 100).round()}%',
          ),
          const SizedBox(height: 6),
          _buildRatingBar(
            star: '3',
            factor: ratingPercentages[3]!,
            percent: '${(ratingPercentages[3]! * 100).round()}%',
          ),
          const SizedBox(height: 6),
          _buildRatingBar(
            star: '2',
            factor: ratingPercentages[2]!,
            percent: '${(ratingPercentages[2]! * 100).round()}%',
          ),
          const SizedBox(height: 6),
          _buildRatingBar(
            star: '1',
            factor: ratingPercentages[1]!,
            percent: '${(ratingPercentages[1]! * 100).round()}%',
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${reviews.length} Reviews',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8A8A91),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _showReviewDialog,
                    child: Text(
                      'WRITE A REVIEW',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4D9183),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.edit_outlined,
                    size: 12,
                    color: Color(0xFF8A8A91),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRatingBar({
    required String star,
    required double factor,
    required String percent,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          child: Row(
            children: [
              Text(
                star,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8A8A91),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.star, size: 9, color: Color(0xFF4D9183)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(
              height: 3,
              color: const Color(0xFFEAEAEF),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: factor,
                child: Container(color: const Color(0xFF4D9183)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            percent,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8A8A91),
            ),
          ),
        ),
      ],
    );
  }

  /* ============================================================================
   * 6. INDIVIDUAL REVIEWS
   * ============================================================================ */
  Widget _buildIndividualReviews() {
    final state = context.watch<GemStoreCubit>().state;
    final reviews = state is GemStoreSuccess
        ? (state.reviewsByProduct[widget.product.id] ?? const <ReviewModel>[])
        : const <ReviewModel>[];
    return Column(
      children: reviews
          .map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildReviewTile(
                review: review,
                onDelete: review.isMine
                    ? () => _confirmDeleteReview(review)
                    : null,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildReviewTile({
    required ReviewModel review,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 31,
              height: 31,
              child: ProductImageWidget(
                imageUrl: review.avatarUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        review.name,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF242424),
                        ),
                      ),
                    ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        tooltip: 'Delete review',
                        icon: const Icon(Icons.delete_outline, size: 17),
                        color: const Color(0xFF9A9A9F),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      review.time,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A8A91),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      size: 10,
                      color: const Color(0xFF4D9183),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  review.content,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF555555),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteReview(ReviewModel review) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete review?'),
        content: const Text('This review will be removed from this product.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || shouldDelete != true) return;
    await context.read<GemStoreCubit>().deleteReview(
      productId: widget.product.id,
      reviewId: review.id,
    );
  }

  Future<void> _showReviewDialog() async {
    final state = context.read<GemStoreCubit>().state;
    final profileName = state is GemStoreSuccess
        ? state.profileName
        : 'Your account';
    final profileAvatarUrl = state is GemStoreSuccess
        ? state.profileAvatarUrl
        : 'photos/profile_avatar_unique.png';

    final result = await showDialog<ReviewDraft>(
      context: context,
      builder: (_) => ReviewDialog(
        profileName: profileName,
        profileAvatarUrl: profileAvatarUrl,
      ),
    );
    if (!mounted || result == null) return;
    context.read<GemStoreCubit>().addReview(
      productId: widget.product.id,
      content: result.content,
      rating: result.rating,
    );
  }

  /* ============================================================================
   * 7. SIMILAR PRODUCTS SECTION
   * ============================================================================ */
  Widget _buildSimilarProductsSection() {
    final state = context.read<GemStoreCubit>().state;
    final products = state is GemStoreSuccess
        ? state.allProducts
              .where(
                (product) =>
                    product.category == widget.product.category &&
                    product.id != widget.product.id,
              )
              .take(6)
              .toList()
        : <Product>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isSimilarProductsExpanded = !isSimilarProductsExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Similar Products',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF242424),
                ),
              ),
              Icon(
                isSimilarProductsExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 18,
                color: Color(0xFF242424),
              ),
            ],
          ),
        ),
        if (isSimilarProductsExpanded) const SizedBox(height: 16),
        if (isSimilarProductsExpanded && products.isNotEmpty)
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 17),
              itemBuilder: (context, index) {
                final p = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(product: p),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 106,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 106,
                            height: 146,
                            color: const Color(0xFFF8F8FA),
                            child: ProductImageWidget(
                              imageUrl: p.imageUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF242424),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$ ${p.price.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF242424),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else if (isSimilarProductsExpanded)
          Text(
            'No similar products in this category.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF8A8A91),
            ),
          ),
      ],
    );
  }

  /* ============================================================================
   * 8. FIXED CTA BAR (ADD TO CART)
   * ============================================================================ */
  Widget _buildFixedCtaBar(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 78,
        decoration: const BoxDecoration(
          color: Color(0xFF333333),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: InkWell(
            onTap: () {
              context.read<GemStoreCubit>().addToCart(widget.product.id);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.product.name} added to cart',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Add To Cart',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(200),
                    borderRadius: BorderRadius.circular(1.5),
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

class ReviewDraft {
  final String content;
  final int rating;

  const ReviewDraft({required this.content, required this.rating});
}

class ReviewDialog extends StatefulWidget {
  final String profileName;
  final String profileAvatarUrl;

  const ReviewDialog({
    super.key,
    required this.profileName,
    required this.profileAvatarUrl,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  late final TextEditingController _reviewController;
  var _rating = 5;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _publish() {
    final content = _reviewController.text.trim();
    if (content.isEmpty) {
      setState(() => _validationMessage = 'Please enter your review.');
      return;
    }
    Navigator.pop(context, ReviewDraft(content: content, rating: _rating));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 32,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF173F45), Color(0xFF4D9183)],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 27,
                        backgroundImage: AssetImage(widget.profileAvatarUrl),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Share your style',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            'Write a review',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Posting as ${widget.profileName}',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF333333),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4FAF8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      tooltip: '${index + 1} stars',
                      onPressed: () => setState(() => _rating = index + 1),
                      icon: Icon(
                        index < _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 29,
                        color: const Color(0xFFE3A93B),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _rating == 5 ? 'Perfect choice!' : 'Your rating: $_rating/5',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF71807D),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reviewController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Your review',
                  hintText: 'Tell us what you loved about it...',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: const Color(0xFFF8F8FA),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 8, bottom: 54),
                    child: Icon(
                      Icons.format_quote_rounded,
                      color: Color(0xFF4D9183),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFF4D9183),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              if (_validationMessage != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _validationMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF356E63),
                        minimumSize: const Size.fromHeight(50),
                        side: const BorderSide(color: Color(0xFFD8E7E3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _publish,
                      icon: const Icon(Icons.send_rounded, size: 17),
                      label: const Text('Publish'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF147C83),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductImageWidget extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    const fallbackAsset = 'photos/265cd7ba4de44d517944d6e28fbe7a516c2c8937.png';

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
            _buildAnimatedImage(child, frame != null || wasSynchronouslyLoaded),
        errorBuilder: (_, _, _) => Image.asset(
          fallbackAsset,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
        ),
      );
    }
    return Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
          _buildAnimatedImage(child, frame != null || wasSynchronouslyLoaded),
      errorBuilder: (_, _, _) => Image.asset(
        fallbackAsset,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
      ),
    );
  }

  Widget _buildAnimatedImage(Widget child, bool loaded) {
    return AnimatedOpacity(
      opacity: loaded ? 1 : 0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      child: child,
    );
  }
}
