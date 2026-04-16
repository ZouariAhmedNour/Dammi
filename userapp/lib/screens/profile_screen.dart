import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:userapp/components/app_button.dart';
import 'package:userapp/components/profile_menu_tile.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/providers/donor_card_provider.dart';
import 'package:userapp/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool emergencyAlerts = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final donorCardAsync = ref.watch(donorCardProvider);

    final user = auth.user;
    final fullName = user?.fullName ?? 'Jean Dupont';

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
          const Gap(24),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 90,
                    color: Colors.white70,
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: donorCardAsync.when(
                      data: (card) => Text(
                        card?.groupeSanguin ?? 'O+',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      loading: () => const Text(
                        '...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      error: (_, __) => const Text(
                        'O+',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(18),
          Center(
            child: Text(
              fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Gap(6),
          const Center(
            child: Text(
              'Donneur Régulier depuis 2021',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Gap(26),
          const AppButton(
            label: 'Modifier le Profil',
            trailingIcon: Icons.edit_outlined,
          ),
          const Gap(14),
          AppButton(
            label: 'Télécharger ma Carte Donneur',
            trailingIcon: Icons.badge_outlined,
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.primaryDark,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonction PDF à brancher ensuite')),
              );
            },
          ),
          const Gap(22),
          donorCardAsync.when(
            data: (card) {
              final total = card?.nbDon ?? 12;
              final lastDonation = user?.lastDonation != null
                  ? DateFormat('dd MMM', 'fr_FR').format(user!.lastDonation!)
                  : '14 Oct.';
              final location = card?.lieuCollecte ?? 'Hôpital Central';

              return Row(
                children: [
                  Expanded(
                    child: _miniStat(
                      title: 'TOTAL DONS',
                      main: '$total',
                      sub: 'pintes',
                    ),
                  ),
                  const Gap(14),
                  Expanded(
                    child: _miniStat(
                      title: 'DERNIER DON',
                      main: lastDonation,
                      sub: location,
                    ),
                  ),
                ],
              );
            },
            loading: () => Row(
              children: [
                Expanded(child: _miniStat(title: 'TOTAL DONS', main: '...', sub: '')),
                const Gap(14),
                Expanded(child: _miniStat(title: 'DERNIER DON', main: '...', sub: '')),
              ],
            ),
            error: (_, __) => Row(
              children: [
                Expanded(child: _miniStat(title: 'TOTAL DONS', main: '12', sub: 'pintes')),
                const Gap(14),
                Expanded(child: _miniStat(title: 'DERNIER DON', main: '14 Oct.', sub: 'Hôpital Central')),
              ],
            ),
          ),
          const Gap(18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.background,
                  child: Icon(
                    Icons.campaign_outlined,
                    color: AppColors.primaryDark,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Appels d'Urgence",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Recevoir les alertes de sang rare',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: emergencyAlerts,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      emergencyAlerts = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const Gap(28),
          const Text(
            'GÉNÉRAL',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
              fontSize: 18,
            ),
          ),
          const Gap(14),
          ProfileMenuTile(
            icon: Icons.lock_outline_rounded,
            title: 'Confidentialité',
            onTap: () {},
          ),
          const Gap(12),
          ProfileMenuTile(
            icon: Icons.help_outline_rounded,
            title: "Centre d'aide",
            onTap: () {},
          ),
          const Gap(12),
          ProfileMenuTile(
            icon: Icons.logout_rounded,
            title: 'Déconnexion',
            titleColor: AppColors.primary,
            onTap: () async {
              await ref.read(authControllerProvider).logout();
              if (!mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required String title,
    required String main,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const Gap(14),
          Text(
            main,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(6),
          Text(
            sub,
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