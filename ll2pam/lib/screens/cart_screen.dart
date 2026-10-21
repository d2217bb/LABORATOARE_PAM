import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubit/gem_store_cubit.dart';
import '../cubit/gem_store_state.dart';
import '../models/product.dart';
import '../product_detail_page.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My cart',
          style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<GemStoreCubit, GemStoreState>(
        builder: (context, state) {
          if (state is! GemStoreSuccess) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = state.allProducts
              .where((product) => state.cartQuantities.containsKey(product.id))
              .toList();
          final itemCount = state.cartQuantities.values.fold<int>(
            0,
            (sum, quantity) => sum + quantity,
          );
          final subtotal = products.fold<double>(
            0,
            (sum, product) =>
                sum + product.price * state.cartQuantities[product.id]!,
          );

          if (products.isEmpty) {
            return _EmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _CartProductTile(
                      product: product,
                      quantity: state.cartQuantities[product.id]!,
                    );
                  },
                ),
              ),
              _CartSummary(subtotal: subtotal, itemCount: itemCount),
            ],
          );
        },
      ),
    );
  }
}

class _CartProductTile extends StatelessWidget {
  final Product product;
  final int quantity;

  const _CartProductTile({required this.product, required this.quantity});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GemStoreCubit>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(product: product),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                product.imageUrl,
                width: 82,
                height: 98,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 82,
                  height: 98,
                  color: const Color(0xFFE7F2EF),
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '\$ ${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF147C83),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: () => cubit.changeCartQuantity(
                        product.id,
                        quantity - 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '$quantity',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: () => cubit.changeCartQuantity(
                        product.id,
                        quantity + 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove from cart',
            onPressed: () => cubit.removeFromCart(product.id),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFF9B5C62),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFE7F2EF),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF356E63)),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double subtotal;
  final int itemCount;

  const _CartSummary({required this.subtotal, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                  style: GoogleFonts.poppins(color: const Color(0xFF77777F)),
                ),
                Text(
                  '\$ ${subtotal.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Checkout is ready for your order.'),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Continue to checkout'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF147C83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFE7F2EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 54,
                color: Color(0xFF147C83),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Your cart is waiting',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add something you love and it will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF8A8A91),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
