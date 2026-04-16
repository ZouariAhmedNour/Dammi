import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:userapp/components/app_button.dart';
import 'package:userapp/components/stat_card.dart';
import 'package:userapp/components/urgent_need_card.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/providers/donor_card_provider.dart';
import 'package:userapp/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final donorCardAsync = ref.watch(donorCardProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, color: AppColors.primary, size: 32),
              const SizedBox(width: 8),
              const Text(
                'Dammi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          const Gap(18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'STATUT : ÉLIGIBLE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const Gap(18),
                const Text(
                  'Vous êtes éligible\npour donner !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const Gap(14),
                Text(
                  'Votre générosité sauve des vies, ${auth.user?.prenom.isNotEmpty == true ? auth.user!.prenom : 'donneur'}. Prenez rendez-vous dès aujourd’hui.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.85),
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
                const Gap(18),
                AppButton(
                  label: 'Prendre rendez-vous',
                  onPressed: () {},
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.primaryDark,
                ),
              ],
            ),
          ),
          const Gap(18),
          donorCardAsync.when(
            data: (card) {
              final bloodGroup = card?.groupeSanguin ?? 'O+';
              final totalDonations = card?.nbDon ?? 12;
              final livesSaved = totalDonations * 3;

              return Column(
                children: [
                  StatCard(
                    title: 'Groupe sanguin',
                    value: bloodGroup,
                    subtitle: 'Donneur universel',
                    valueColor: AppColors.primaryDark,
                  ),
                  const Gap(16),
                  StatCard(
                    title: 'Total des dons',
                    value: '$totalDonations',
                    subtitle: '+2 cette année',
                    backgroundColor: AppColors.primaryLight,
                    valueColor: AppColors.primaryDark,
                  ),
                  const Gap(16),
                  StatCard(
                    title: 'Vies sauvées',
                    value: '$livesSaved',
                    subtitle: 'Chaque don peut sauver jusqu’à 3 vies.',
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, __) => Column(
              children: const [
                StatCard(
                  title: 'Groupe sanguin',
                  value: 'O+',
                  subtitle: 'Donneur universel',
                ),
                Gap(16),
                StatCard(
                  title: 'Total des dons',
                  value: '12',
                  subtitle: '+2 cette année',
                ),
              ],
            ),
          ),
          const Gap(24),
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
            height: 240,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF989590), Color(0xFFD7D2C7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.75),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 38,
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  bottom: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trouver un point de collecte',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '3 centres ouverts à proximité',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),
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