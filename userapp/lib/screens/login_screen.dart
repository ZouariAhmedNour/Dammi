import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:userapp/components/app_button.dart';
import 'package:userapp/components/app_text_field.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authControllerProvider);
    final ok = await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Connexion échouée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Gap(40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.water_drop_rounded, color: AppColors.primary, size: 38),
                        SizedBox(width: 8),
                        Text(
                          'Dammi',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const Gap(14),
                    const Text(
                      'Votre don est une promesse de vie.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Gap(28),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.03),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          AppTextField(
                            label: 'Email',
                            hint: 'nom@exemple.com',
                            controller: _emailCtrl,
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email requis';
                              }
                              return null;
                            },
                          ),
                          const Gap(18),
                          Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Expanded(
      child: Text(
        'MOT DE PASSE',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: AppColors.textSecondary,
        ),
      ),
    ),
    const SizedBox(width: 8),
    Flexible(
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          'Mot de passe oublié ?',
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  ],
),
                          const Gap(10),
                          AppTextField(
                            label: '',
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
                          const Gap(24),
                          AppButton(
                            label: 'Se connecter',
                            trailingIcon: Icons.arrow_forward_rounded,
                            loading: auth.isLoading,
                            onPressed: _submit,
                          ),
                          const Gap(26),
                       Wrap(
  alignment: WrapAlignment.center,
  crossAxisAlignment: WrapCrossAlignment.center,
  spacing: 4,
  children: [
    const Text(
      'Pas encore de compte ?',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 16,
      ),
      textAlign: TextAlign.center,
    ),
    GestureDetector(
      onTap: () => context.go('/register'),
      child: const Text(
        'Créer un compte',
        style: TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  ],
),
                        ],
                      ),
                    ),
                    const Gap(28),
                    const Wrap(
  alignment: WrapAlignment.center,
  crossAxisAlignment: WrapCrossAlignment.center,
  spacing: 10,
  runSpacing: 8,
  children: [
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.shield_outlined, size: 18, color: AppColors.textSecondary),
        SizedBox(width: 6),
        Text(
          'SÉCURISÉ',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
    Text(
      '|',
      style: TextStyle(color: AppColors.textMuted),
    ),
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.verified_user_outlined, size: 18, color: AppColors.textSecondary),
        SizedBox(width: 6),
        Text(
          'DONNÉES PROTÉGÉES',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  ],
),
                    const Gap(16),
                    const Text(
                      'Dammi respecte la confidentialité de vos données médicales et se conforme aux standards de santé.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
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