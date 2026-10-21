import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingStateWidget extends StatefulWidget {
  const LoadingStateWidget({super.key});

  @override
  State<LoadingStateWidget> createState() => _LoadingStateWidgetState();
}

class _LoadingStateWidgetState extends State<LoadingStateWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              Text(
                'GemStore',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF101010),
                ),
              ),
              const SizedBox(height: 18),
              _buildSkeleton(
                width: double.infinity,
                height: 44,
                borderRadius: 14,
              ),
              const SizedBox(height: 24),
              _buildSkeleton(
                width: double.infinity,
                height: 166,
                borderRadius: 16,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildSkeleton(
                      width: double.infinity,
                      height: 175,
                      borderRadius: 12,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildSkeleton(
                      width: double.infinity,
                      height: 175,
                      borderRadius: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Loading GemStore...',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF8A8A91),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    final progress = _shimmerController.value;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(-1.5 + progress * 3, 0),
          end: Alignment(-0.5 + progress * 3, 0),
          colors: const [
            Color(0xFFF1F1F3),
            Color(0xFFFAFAFB),
            Color(0xFFF1F1F3),
          ],
        ),
      ),
    );
  }
}
