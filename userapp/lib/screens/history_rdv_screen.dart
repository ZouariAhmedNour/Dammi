import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:userapp/models/appointment_models.dart';
import 'package:userapp/providers/appointment_providers.dart';
import 'package:userapp/theme/app_colors.dart';

class HistoryRDVScreen extends ConsumerWidget {
  const HistoryRDVScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rdvAsync = ref.watch(rendezVousHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes rendez-vous'),
      ),
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
          final futurs = items.where((e) => e.dateHeure != null && e.dateHeure!.isAfter(now)).toList()
            ..sort((a, b) => a.dateHeure!.compareTo(b.dateHeure!));
          final passes = items.where((e) => e.dateHeure != null && !e.dateHeure!.isAfter(now)).toList()
            ..sort((a, b) => b.dateHeure!.compareTo(a.dateHeure!));

          return ListView(
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
                ...futurs.map((e) => _RdvCard(item: e)),
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
                ...passes.map((e) => _RdvCard(item: e)),
              ],
            ],
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

  const _RdvCard({required this.item});

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

    return Container(
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
    );
  }
}