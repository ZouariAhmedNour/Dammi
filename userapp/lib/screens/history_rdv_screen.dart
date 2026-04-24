import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:userapp/api/appointment_api.dart';
import 'package:userapp/models/appointment_models.dart';
import 'package:userapp/providers/appointment_providers.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/providers/donor_card_provider.dart';
import 'package:userapp/theme/app_colors.dart';

class HistoryRDVScreen extends ConsumerStatefulWidget {
  const HistoryRDVScreen({super.key});

  @override
  ConsumerState<HistoryRDVScreen> createState() => _HistoryRDVScreenState();
}

class _HistoryRDVScreenState extends ConsumerState<HistoryRDVScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.invalidate(rendezVousHistoryProvider);
    });
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    RendezVousModel item,
  ) async {
    final auth = ref.read(authControllerProvider);
    final userId = auth.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.pointCollecteNom ?? 'Rendez-vous',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.dateHeure != null
                      ? DateFormat('dd/MM/yyyy - HH:mm', 'fr_FR')
                          .format(item.dateHeure!)
                      : '-',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(sheetContext);

                      try {
                        await ref
    .read(appointmentApiProvider)
    .transformerRdvEnDon(rendezVousId: item.id);

/// refresh données RDV
ref.invalidate(rendezVousHistoryProvider);

/// refresh USER
await ref.read(authControllerProvider).refreshUser();

/// 🔥 TRÈS IMPORTANT → refresh carte donneur
ref.invalidate(donorCardAccessProvider);
ref.invalidate(donorCardProvider);

                        if (!context.mounted) return;

                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('Succès'),
                            content: const Text(
                              'Le rendez-vous a été annulé avec succès.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur : $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Annuler le rendez-vous'),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(sheetContext);

                      try {
                        await ref
                            .read(appointmentApiProvider)
                            .transformerRdvEnDon(rendezVousId: item.id);

                        ref.invalidate(rendezVousHistoryProvider);
                        await ref.read(authControllerProvider).refreshUser();

                        if (!context.mounted) return;

                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('Succès'),
                            content: const Text(
                              'Le don a été créé avec succès.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur : $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Transformer en don'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(rendezVousHistoryProvider);
    await Future.delayed(const Duration(milliseconds: 250));
  }

  @override
  Widget build(BuildContext context) {
    final rdvAsync = ref.watch(rendezVousHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes rendez-vous')),
      body: rdvAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Aucun rendez-vous pour le moment',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final now = DateTime.now();

          final futurs = items
              .where((e) => e.dateHeure != null && e.dateHeure!.isAfter(now))
              .toList()
            ..sort((a, b) => a.dateHeure!.compareTo(b.dateHeure!));

          final passes = items
              .where((e) => e.dateHeure != null && !e.dateHeure!.isAfter(now))
              .toList()
            ..sort((a, b) => b.dateHeure!.compareTo(a.dateHeure!));

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(18),
              children: [
                if (futurs.isNotEmpty) ...[
                  const Text(
                    'À venir',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...futurs.map(
                    (e) => _RdvCard(
                      item: e,
                      onTap: () => _showActions(context, ref, e),
                    ),
                  ),
                  const SizedBox(height: 26),
                ],
                if (passes.isNotEmpty) ...[
                  const Text(
                    'Historique',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...passes.map(
                    (e) => _RdvCard(
                      item: e,
                      onTap: () => _showActions(context, ref, e),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Erreur : $e',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _RdvCard extends StatelessWidget {
  final RendezVousModel item;
  final VoidCallback onTap;

  const _RdvCard({
    required this.item,
    required this.onTap,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRME':
        return Colors.green;
      case 'ANNULE':
        return Colors.red;
      case 'EFFECTUE':
        return Colors.blueGrey;
      default:
        return AppColors.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatted = item.dateHeure != null
        ? DateFormat('dd/MM/yyyy - HH:mm', 'fr_FR').format(item.dateHeure!)
        : '-';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: _statusColor(item.statut).withOpacity(.12),
              child: Icon(
                Icons.event_available_rounded,
                color: _statusColor(item.statut),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.pointCollecteNom ?? 'Point de collecte',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatted,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.statut,
                    style: TextStyle(
                      color: _statusColor(item.statut),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}