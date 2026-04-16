import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:userapp/components/app_button.dart';
import 'package:userapp/components/app_text_field.dart';
import 'package:userapp/components/blood_group_dropdown.dart';
import 'package:userapp/models/blood_type.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/providers/blood_type_provider.dart';
import 'package:userapp/theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  BloodType? _selectedBloodType;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez accepter les conditions')),
      );
      return;
    }

    final auth = ref.read(authControllerProvider);
    final ok = await auth.register(
      fullName: _fullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      bloodType: _selectedBloodType,
    );

    if (!mounted) return;

    if (ok) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Inscription échouée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final bloodTypesAsync = ref.watch(bloodTypesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
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
                    const Gap(42),
                    const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const Gap(12),
                    const Text(
                      "Commencez votre voyage en tant que donateur aujourd'hui.",
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const Gap(34),
                    AppTextField(
                      label: 'Nom complet',
                      hint: 'Jean Dupont',
                      controller: _fullNameCtrl,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return 'Nom complet requis';
                        }
                        return null;
                      },
                    ),
                    const Gap(22),
                    AppTextField(
                      label: 'Email',
                      hint: 'jean.dupont@exemple.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email requis';
                        }
                        return null;
                      },
                    ),
                    const Gap(22),
                    bloodTypesAsync.when(
                      data: (items) => BloodGroupDropdown(
                        items: items,
                        value: _selectedBloodType,
                        onChanged: (value) {
                          setState(() {
                            _selectedBloodType = value;
                          });
                        },
                        validator: (_) {
                          if (_selectedBloodType == null) {
                            return 'Sélectionnez un groupe';
                          }
                          return null;
                        },
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, _) => const Text(
                        'Impossible de charger les groupes sanguins',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    const Gap(22),
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
                    const Gap(26),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptedTerms = value ?? false;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(text: "J'accepte les "),
                                  TextSpan(
                                    text: "Conditions d'utilisation",
                                    style: TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(text: " et la "),
                                  TextSpan(
                                    text: "Politique de confidentialité",
                                    style: TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(text: "."),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                    AppButton(
                      label: "S'inscrire",
                      trailingIcon: Icons.arrow_forward_rounded,
                      loading: auth.isLoading,
                      onPressed: _submit,
                    ),
                    const Gap(30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Déjà un compte ? ',
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
                    const Gap(24),
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