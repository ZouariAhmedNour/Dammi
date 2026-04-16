import 'package:flutter/material.dart';
import 'package:userapp/theme/app_colors.dart';

class UrgentNeedCard extends StatelessWidget {
  final String group;
  final String title;
  final String location;
  final String eta;

  const UrgentNeedCard({
    super.key,
    required this.group,
    required this.title,
    required this.location,
    required this.eta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              group,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  eta,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.background,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_outlined,
                color: AppColors.primaryDark,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}