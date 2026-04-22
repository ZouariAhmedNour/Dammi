import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:userapp/components/app_button.dart';
import 'package:userapp/components/app_text_field.dart';
import 'package:userapp/components/blood_group_dropdown.dart';
import 'package:userapp/components/point_collecte_dropdown.dart';
import 'package:userapp/models/appointment_models.dart';
import 'package:userapp/models/blood_request.dart';
import 'package:userapp/models/blood_type.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/providers/blood_request_provider.dart';
import 'package:userapp/providers/blood_type_provider.dart';
import 'package:userapp/theme/app_colors.dart';

class NewBloodRequestScreen extends ConsumerStatefulWidget {
  const NewBloodRequestScreen({super.key});

  @override
  ConsumerState<NewBloodRequestScreen> createState() =>
      _NewBloodRequestScreenState();
}

class _NewBloodRequestScreenState extends ConsumerState<NewBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _quantityCtrl = TextEditingController(text: '1');
  final _contactNameCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  PointCollecteModel? _selectedPointCollecte;

  bool _urgency = false;
  BloodType? _selectedBloodType;

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _contactNameCtrl.dispose();
    _reasonCtrl.dispose();
    _notesCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authControllerProvider);
    final userId =
        auth.user?.id; // adapte si ton modèle utilisateur a un autre champ

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Utilisateur non connecté')));
      return;
    }

    final body = BloodRequestCreateBody(
      quantite: int.parse(_quantityCtrl.text.trim()),
      urgence: _urgency,
      contactNom: _contactNameCtrl.text.trim(),
      contactTelephone: _phoneCtrl.text.trim(),
      raisonDemande: _reasonCtrl.text.trim().isEmpty
          ? null
          : _reasonCtrl.text.trim(),
      notesComplementaires: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
      userId: userId,
      pointCollecteId: _selectedPointCollecte!.id,
      typeSanguinId: _selectedBloodType?.id,
    );

    try {
      await ref.read(bloodRequestSubmitProvider.notifier).submit(body);

      ref.invalidate(userBloodRequestsProvider(userId));

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Succès'),
              ],
            ),
            content: const Text(
              'Votre demande a été créée avec succès.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      context.go('/request/history');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création de la demande'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(bloodTypesProvider);
    final submitState = ref.watch(bloodRequestSubmitProvider);
    final pointsAsync = ref.watch(pointsCollecteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle demande')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nouvelle Demande',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Remplissez les détails pour soumettre une demande de don de sang.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                AppTextField(
                  label: 'Quantité (poches)',
                  hint: 'Ex: 5',
                  controller: _quantityCtrl,
                  prefixIcon: Icons.water_drop_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    if (n == null || n < 1) return 'Quantité invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                typesAsync.when(
                  data: (types) {
                    return Column(
                      children: [
                        BloodGroupDropdown(
                          items: types,
                          value: _selectedBloodType,
                          onChanged: (value) =>
                              setState(() => _selectedBloodType = value),
                          validator: (_) {
                            if (_selectedBloodType == null)
                              return 'Sélectionnez un groupe sanguin';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, __) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Impossible de charger les types sanguins'),
                  ),
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _urgency,
                  onChanged: (v) => setState(() => _urgency = v),
                  title: const Text(
                    'Urgence critique',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Traitement prioritaire immédiat'),
                  secondary: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 8),
                AppTextField(
                  label: 'Nom du contact',
                  hint: 'Entrez le nom complet',
                  controller: _contactNameCtrl,
                  prefixIcon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Le nom du contact est obligatoire';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                AppTextField(
                  label: 'Numéro de téléphone',
                  hint: 'Ex: +216XXXXXXXX',
                  controller: _phoneCtrl,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    final regex = RegExp(r'^[+]?[0-9]{8,15}$');
                    if (value.isEmpty)
                      return 'Le numéro de téléphone est obligatoire';
                    if (!regex.hasMatch(value))
                      return 'Numéro de téléphone invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                pointsAsync.when(
                  data: (points) {
                    return PointCollecteDropdown(
                      items: points,
                      value: _selectedPointCollecte,
                      onChanged: (value) =>
                          setState(() => _selectedPointCollecte = value),
                      validator: (value) {
                        if (value == null)
                          return 'Sélectionnez un point de collecte';
                        return null;
                      },
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, __) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Impossible de charger les points de collecte'),
                  ),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Raison de la demande',
                  hint: 'Détaillez la raison médicale...',
                  controller: _reasonCtrl,
                  prefixIcon: Icons.description_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Notes additionnelles',
                  hint: 'Informations complémentaires...',
                  controller: _notesCtrl,
                  prefixIcon: Icons.notes_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 22),

                AppButton(
                  label: 'Soumettre la demande',
                  loading: submitState.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
