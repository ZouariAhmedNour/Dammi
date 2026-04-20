import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:userapp/components/app_button.dart';
import 'package:userapp/components/stat_card.dart';
import 'package:userapp/components/urgent_need_card.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/providers/user_provider.dart';
import 'package:userapp/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    final status = auth.user?.eligibilityStatus?.trim().toUpperCase();
    final eligible = status == 'ELIGIBLE';

    final bloodGroup = auth.user?.typeSanguinAboGroup ?? '—';
    final firstName = auth.user?.prenom ?? 'donneur';

    final isPertinent = auth.user?.statutPertinent ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              const Icon(
                Icons.water_drop_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 8),

              const Text(
                'Dammi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),

              const Spacer(),

              /// TOGGLE MODERNE
              GestureDetector(
                onTap: () async {
                  final userId = auth.user?.id;
                  if (userId == null) return;

                  final newValue = !isPertinent;

                  await ref
                      .read(statutPertinentProvider.notifier)
                      .toggle(userId, newValue);

                  ref
                      .read(authControllerProvider)
                      .updatePertinent(newValue);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPertinent
                        ? AppColors.success.withOpacity(.12)
                        : AppColors.warning.withOpacity(.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPertinent
                          ? AppColors.success.withOpacity(.3)
                          : AppColors.warning.withOpacity(.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPertinent
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        child: Icon(
                          isPertinent
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPertinent
                            ? 'Pertinent'
                            : 'Non pertinent',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isPertinent
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                onPressed: () {},
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.primaryDark,
                  size: 22,
                ),
              ),
            ],
          ),

          const Gap(18),

          /// BANNIÈRE PRINCIPALE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: eligible
                    ? [
                        AppColors.primaryDark,
                        AppColors.primary,
                      ]
                    : [
                        Colors.grey.shade700,
                        Colors.grey.shade500,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'STATUT : ${status ?? 'INCONNU'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const Gap(18),

                Text(
                  eligible
                      ? 'Vous êtes éligible\npour donner !'
                      : 'Vous n’êtes pas encore\néligible',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),

                const Gap(14),

                Text(
                  eligible
                      ? 'Votre générosité sauve des vies, $firstName.'
                      : 'Merci $firstName. Reprenez après 2 mois.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.85),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),

                const Gap(18),

                AppButton(
                  label: 'Prendre rendez-vous',
                  fontSize: 14,
                  height: 46,
                  onPressed:
                      eligible ? () => context.go('/map') : null,
                  backgroundColor: eligible
                      ? AppColors.background
                      : Colors.grey.shade300,
                  foregroundColor: eligible
                      ? AppColors.primaryDark
                      : Colors.grey,
                ),
              ],
            ),
          ),

          const Gap(18),

          /// GROUPE SANGUIN
          StatCard(
            title: 'Groupe sanguin',
            value: bloodGroup,
            subtitle: 'Profil utilisateur',
            valueColor: AppColors.primaryDark,
          ),

          const Gap(24),

          /// ACTIONS
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Nouvelle demande',
                  fontSize: 13,
                  height: 46,
                  onPressed: () {
                    context.go('/request/new');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Mes demandes',
                  fontSize: 13,
                  height: 46,
                  onPressed: () {
                    context.go('/request/history');
                  },
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primaryDark,
                ),
              ),
            ],
          ),

          const Gap(24),

          /// COLLECTE
          const Text(
            'Collecte de Sang',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const Gap(14),

          Container(
            width: double.infinity,
            height: 220,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF989590),
                  Color(0xFFD7D2C7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.75),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  bottom: 0,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trouver un point',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '3 centres ouverts',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: eligible
                        ? AppColors.primary
                        : Colors.grey,
                    child: IconButton(
                      onPressed:
                          eligible
                              ? () => context.go('/map')
                              : null,
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Gap(24),

          /// URGENCES
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Urgences Vitales',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'Voir tout',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const Gap(14),

          const UrgentNeedCard(
            group: 'AB-',
            title: 'Besoin Urgent : AB Négatif',
            location: 'Hôpital Central',
            eta: 'Moins de 2h',
          ),

          const Gap(12),

          const UrgentNeedCard(
            group: 'O+',
            title: 'Réserve Faible : O Positif',
            location: 'Clinique du Parc',
            eta: "Aujourd'hui",
          ),
        ],
      ),
    );
  }
}