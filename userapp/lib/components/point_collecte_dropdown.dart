import 'package:flutter/material.dart';
import 'package:userapp/models/appointment_models.dart';

class PointCollecteDropdown extends StatelessWidget {
  final List<PointCollecteModel> items;
  final PointCollecteModel? value;
  final ValueChanged<PointCollecteModel?> onChanged;
  final String? Function(PointCollecteModel?)? validator;

  const PointCollecteDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PointCollecteModel>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Point de collecte',
        hintText: 'Sélectionnez un point de collecte',
      ),
      items: items
          .map(
            (point) => DropdownMenuItem<PointCollecteModel>(
              value: point,
              child: Text(point.nom),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}