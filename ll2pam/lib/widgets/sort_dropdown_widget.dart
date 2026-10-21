import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SortDropdownWidget extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortChanged;

  const SortDropdownWidget({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  static const List<String> options = [
    'Default',
    'Price: Low -> High',
    'Price: High -> Low',
    'Name: A -> Z',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: PopupMenuButton<String>(
        onSelected: onSortChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        itemBuilder: (context) {
          return options.map((opt) {
            return PopupMenuItem<String>(
              value: opt,
              child: Text(
                opt,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: opt == currentSort ? FontWeight.w600 : FontWeight.w400,
                  color: opt == currentSort ? const Color(0xFF101010) : const Color(0xFF777777),
                ),
              ),
            );
          }).toList();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sort_rounded,
              size: 16,
              color: Color(0xFF101010),
            ),
            const SizedBox(width: 4),
            Text(
              currentSort == 'Default' ? 'Sort' : currentSort,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF101010),
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: Color(0xFF101010),
            ),
          ],
        ),
      ),
    );
  }
}
