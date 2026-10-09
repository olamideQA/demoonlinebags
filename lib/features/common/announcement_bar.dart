import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class AnnouncementBar extends StatelessWidget {
  const AnnouncementBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.obsidianNoir,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, color: AppTheme.primaryGold, size: 14),
              const SizedBox(width: 8),
              Text(
                'COMPLIMENTARY VIP COURIER DELIVERY ACROSS NIGERIA ON ORDERS OVER ₦150,000  •  100% ITALIAN FULL-GRAIN LEATHER',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.stars, color: AppTheme.primaryGold, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
