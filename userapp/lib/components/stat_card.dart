import 'package:flutter/material.dart';
import 'package:userapp/theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color? backgroundColor;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.backgroundColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}