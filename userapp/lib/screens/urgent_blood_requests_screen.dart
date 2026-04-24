import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:userapp/models/blood_request.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/providers/blood_request_provider.dart';
import 'package:userapp/providers/urgent_requests_provider.dart';
import 'package:userapp/theme/app_colors.dart';

class UrgentBloodRequestsScreen extends ConsumerStatefulWidget {
  const UrgentBloodRequestsScreen({super.key});

  @override
  ConsumerState<UrgentBloodRequestsScreen> createState() =>
      _UrgentBloodRequestsScreenState();
}

class _UrgentBloodRequestsScreenState
    extends ConsumerState<UrgentBloodRequestsScreen> {
  bool _markedSeen = false;

  Future<void> _markAsSeenIfNeeded() async {
    if (_markedSeen) return;

    final auth = ref.read(authControllerProvider);
    final userId = auth.user?.id;
    final isPertinent = auth.user?.statutPertinent ?? false;

    if (userId == null || !isPertinent) return;

    await ref.read(urgentSeenStorageProvider).markSeen(userId);
    _markedSeen = true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAsSeenIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isPertinent = auth.user?.statutPertinent ?? false;
final userId = auth.user?.id;

if (userId == null) {
  return const Scaffold(
    body: Center(child: Text('Utilisateur non connecté.')),
  );
}

final urgentAsync = ref.watch(compatibleUrgentRequestsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes urgentes'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: !isPertinent
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.block_rounded,
                      size: 56,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Vous devez activer le statut pertinent pour voir les demandes urgentes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              )
            : urgentAsync.when(
                data: (requests) {
                  if (requests.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune demande urgente pour le moment.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  final sorted = [...requests]
                    ..sort((a, b) {
                      final da = a.dateCreation ?? DateTime.fromMillisecondsSinceEpoch(0);
                      final db = b.dateCreation ?? DateTime.fromMillisecondsSinceEpoch(0);
                      return db.compareTo(da);
                    });

                  return RefreshIndicator(
                    onRefresh: () async {
                     ref.invalidate(compatibleUrgentRequestsProvider(userId));
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: sorted.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final request = sorted[index];
                        return BloodRequestCard(
                          request: request,
                          onRespond: () {
                            context.push('/request/respond/${request.id}');
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Erreur de chargement\n$e',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
      ),
    );
  }
}

class BloodRequestCard extends StatelessWidget {
  final BloodRequest request;
  final VoidCallback onRespond;

  const BloodRequestCard({
    super.key,
    required this.request,
    required this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    final group = request.typeSanguinAboGroup ?? '—';
    final timeText = request.dateCreation == null
        ? 'Date inconnue'
        : '${request.dateCreation!.day.toString().padLeft(2, '0')}/'
          '${request.dateCreation!.month.toString().padLeft(2, '0')}/'
          '${request.dateCreation!.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    group,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demande urgente ${request.urgence ? '• URGENTE' : ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Publié le $timeText',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Quantité :${request.quantite} poche(s)',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),


const SizedBox(height: 10),

Builder(
  builder: (context) {
    final total = request.quantite;
    final collected = request.quantiteLivree ?? 0;

    final progress = total > 0
        ? (collected / total).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$collected / $total collectées',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(
              AppColors.primary,
            ),
          ),
        ),
      ],
    );
  },
),

const SizedBox(height: 8),
          const SizedBox(height: 8),
          Text(
            'Contact: ${request.contactNom}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if ((request.raisonDemande ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),

Text(
  'Téléphone : ${request.contactTelephone ?? 'Non disponible'}',
  style: const TextStyle(
    color: AppColors.textSecondary,
  ),
),

const SizedBox(height: 8),

Text(
  'Point de collecte : ${request.pointCollecteNom ?? 'Non défini'}',
  style: const TextStyle(
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w600,
  ),
),
            const SizedBox(height: 8),
            Text(
              request.raisonDemande!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
          if ((request.notesComplementaires ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              request.notesComplementaires!,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onRespond,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Répondre à cette demande'),
            ),
          ),
        ],
      ),
    );
  }
}