import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:userapp/components/app_button.dart';
import 'package:userapp/components/donor_card_preview_sheet.dart';
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
    final accessAsync = ref.watch(donorCardAccessProvider);
    final donorCardAsync = ref.watch(donorCardProvider);

    final user = auth.user;
    final fullName = user?.fullName ?? 'Jean Dupont';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              const Icon(Icons.water_drop_rounded,
                  color: AppColors.primary, size: 32),
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

          // ✅ AVATAR SIMPLE (SANS GROUPE SANGUIN)
          Center(
            child: Container(
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
          ),

          const Gap(18),

          // NOM
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
              'Donneur',
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

          accessAsync.when(
  loading: () => AppButton(
    label: 'Vérification...',
    trailingIcon: Icons.badge_outlined,
    backgroundColor: Colors.grey.shade400,
    foregroundColor: Colors.white70,
    height: 64,
    fontSize: 13,
    loading: true,
    onPressed: null,
  ),
  error: (_, __) => AppButton(
    label: 'Vous devez faire au moins un don pour récupérer votre carte donneur',
    trailingIcon: Icons.badge_outlined,
    backgroundColor: Colors.grey.shade400,
    foregroundColor: Colors.white70,
    height: 64,
    fontSize: 13,
    onPressed: null,
  ),
  data: (canAccess) {
    final access = canAccess ?? false;

    return AppButton(
      label: access
          ? 'Télécharger ma Carte Donneur'
          : 'Vous devez faire au moins un don pour récupérer votre carte donneur',
      trailingIcon: Icons.badge_outlined,
      backgroundColor:
          access ? AppColors.primaryLight : Colors.grey.shade400,
      foregroundColor:
          access ? AppColors.primaryDark : Colors.white70,
      height: 64,
      fontSize: 13,
      onPressed: access
          ? () async {
              final currentUser = auth.user;
              if (currentUser == null || currentUser.id == null) return;

              try {
                final api = ref.read(donorCardApiProvider);
                final card = await api.getOrGenerateCard(currentUser.id!);

                if (!mounted) return;

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DonorCardPreviewSheet(
                    fullName: fullName,
                    card: card,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors du chargement de la carte'),
                  ),
                );
              }
            }
          : null,
    );
  },
),

          const Gap(22),

          // STATS
          donorCardAsync.when(
            data: (card) {
              final total = card?.nbDon ?? 0;

              final lastDonation = user?.lastDonation != null
                  ? DateFormat('dd MMM', 'fr_FR')
                      .format(user!.lastDonation!)
                  : '--';

              final location = card?.lieuCollecte ?? '--';

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
                Expanded(
                    child:
                        _miniStat(title: 'TOTAL DONS', main: '...', sub: '')),
                const Gap(14),
                Expanded(
                    child: _miniStat(
                        title: 'DERNIER DON', main: '...', sub: '')),
              ],
            ),
            error: (_, __) => Row(
              children: [
                Expanded(
                    child:
                        _miniStat(title: 'TOTAL DONS', main: '--', sub: '')),
                const Gap(14),
                Expanded(
                    child: _miniStat(
                        title: 'DERNIER DON', main: '--', sub: '--')),
              ],
            ),
          ),

          const Gap(18),

          // ALERTES
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