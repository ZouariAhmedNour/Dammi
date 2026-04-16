import 'package:flutter/material.dart';
import 'package:userapp/models/blood_type.dart';
import 'package:userapp/theme/app_colors.dart';

class BloodGroupDropdown extends StatelessWidget {
  final List<BloodType> items;
  final BloodType? value;
  final ValueChanged<BloodType?> onChanged;
  final String? Function(BloodType?)? validator;

  const BloodGroupDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GROUPE SANGUIN',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<BloodType>(
          value: value,
          validator: validator,
          items: items
              .map(
                (group) => DropdownMenuItem<BloodType>(
                  value: group,
                  child: Text(group.aboGroup),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(
              Icons.bloodtype_outlined,
              color: AppColors.textSecondary,
            ),
          ),
          hint: const Text('Sélectionnez votre groupe'),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}