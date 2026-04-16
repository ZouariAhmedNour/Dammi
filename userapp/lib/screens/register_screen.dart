import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:userapp/components/app_button.dart';
import 'package:userapp/components/app_text_field.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _prenomCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? _selectedSexe;
  bool _neverDonated = true;
  DateTime? _lastDonation;

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email requis';
    }

    final emailRegex = RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email invalide';
    }

    return null;
  }

  String? _validatePhoneTunisia(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Numéro de téléphone requis';
    }

    final phone = value.trim();
    final regex = RegExp(r'^(?:\+216)?[0-9]{8}$');

    if (!regex.hasMatch(phone)) {
      return 'Numéro tunisien invalide';
    }

    return null;
  }

  Future<void> _pickLastDonationDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _lastDonation ?? DateTime(now.year - 1),
      firstDate: DateTime(2000),
      lastDate: now,
      locale: const Locale('fr'),
    );

    if (picked != null) {
      setState(() {
        _lastDonation = picked;
        _neverDonated = false;
      });
    }
  }

  Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  if (_selectedSexe == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez choisir le sexe')),
    );
    return;
  }

  final auth = ref.read(authControllerProvider);

  final ok = await auth.register(
    prenom: _prenomCtrl.text.trim(),
    nom: _nomCtrl.text.trim(),
    email: _emailCtrl.text.trim(),
    password: _passwordCtrl.text.trim(),
    phone: _phoneCtrl.text.trim(),
    sexe: _selectedSexe!,
    lastDonation: _neverDonated ? null : _lastDonation,
  );

  if (!mounted) return;

  if (ok) {
    await _showSuccessDialog();

    if (!mounted) return;
    context.go('/login');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.errorMessage ?? 'Inscription échouée')),
    );
  }
}

  Future<void> _showSuccessDialog() async {
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
            Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 28,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Compte créé',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: const Text(
          'Votre compte a été créé avec succès.',
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
}

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    final dateText = _lastDonation == null
        ? 'Choisir une date'
        : DateFormat('dd/MM/yyyy').format(_lastDonation!);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(10),
                    Row(
                      children: const [
                        Icon(Icons.water_drop_rounded, color: AppColors.primary, size: 34),
                        SizedBox(width: 8),
                        Text(
                          'Dammi',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const Gap(32),
                    const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const Gap(10),
                    const Text(
                      "Renseignez vos informations pour créer votre compte.",
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const Gap(28),

                    AppTextField(
                      label: 'Prénom',
                      hint: 'Ahmed',
                      controller: _prenomCtrl,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'Prénom invalide';
                        }
                        return null;
                      },
                    ),
                    const Gap(18),

                    AppTextField(
                      label: 'Nom',
                      hint: 'Ben Salah',
                      controller: _nomCtrl,
                      prefixIcon: Icons.badge_outlined,
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'Nom invalide';
                        }
                        return null;
                      },
                    ),
                    const Gap(18),

                    AppTextField(
                      label: 'Email',
                      hint: 'nom@exemple.com',
                      controller: _emailCtrl,
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const Gap(18),

                    AppTextField(
                      label: 'Téléphone',
                      hint: '+216XXXXXXXX',
                      controller: _phoneCtrl,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhoneTunisia,
                    ),
                    const Gap(18),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SEXE',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Gap(10),
                        DropdownButtonFormField<String>(
                          value: _selectedSexe,
                          items: const [
                            DropdownMenuItem(
                              value: 'HOMME',
                              child: Text('Homme'),
                            ),
                            DropdownMenuItem(
                              value: 'FEMME',
                              child: Text('Femme'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSexe = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Choisir le sexe',
                            prefixIcon: Icon(Icons.wc_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Sexe requis';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const Gap(18),

                    AppTextField(
                      label: 'Mot de passe',
                      hint: '••••••••',
                      controller: _passwordCtrl,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Minimum 6 caractères';
                        }
                        return null;
                      },
                    ),
                    const Gap(18),

                    AppTextField(
                      label: 'Ressaisir mot de passe',
                      hint: '••••••••',
                      controller: _confirmPasswordCtrl,
                      prefixIcon: Icons.lock_reset_outlined,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirmation requise';
                        }
                        if (value != _passwordCtrl.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    const Gap(18),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DERNIER DON',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Gap(12),
                          CheckboxListTile(
                            value: _neverDonated,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Jamais donné'),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (value) {
                              setState(() {
                                _neverDonated = value ?? false;
                                if (_neverDonated) {
                                  _lastDonation = null;
                                }
                              });
                            },
                          ),
                          const Gap(6),
                          InkWell(
                            onTap: _neverDonated ? null : _pickLastDonationDate,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: _neverDonated
                                    ? Colors.grey.shade200
                                    : AppColors.inputFill,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: _neverDonated
                                        ? Colors.grey
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      dateText,
                                      style: TextStyle(
                                        color: _neverDonated
                                            ? Colors.grey
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(24),
                    AppButton(
                      label: "S'inscrire",
                      trailingIcon: Icons.arrow_forward_rounded,
                      loading: auth.isLoading,
                      onPressed: _submit,
                    ),
                    const Gap(24),

                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        const Text(
                          'Déjà un compte ?',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}