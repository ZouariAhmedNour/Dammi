import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userapp/models/blood_request.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/providers/blood_request_provider.dart';
import 'package:userapp/theme/app_colors.dart';

class BloodRequestHistoryScreen extends ConsumerWidget {
  const BloodRequestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final userId = auth.user!.id;
    if (userId == null) {
  return const Scaffold(
    body: Center(child: Text('Utilisateur non connecté')),
  );
}

    final requestsAsync = ref.watch(userBloodRequestsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes demandes'),
      ),
      body: requestsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text(e.toString()),
        ),
        data: (requests) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${request.quantite} poches • ${request.typeSanguinAboGroup ?? ''}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      request.statut.label,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 16),

                    LinearProgressIndicator(
                      value: request.progress,
                      minHeight: 12,
                      backgroundColor: AppColors.border,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${request.quantiteLivree ?? 0}/${request.quantite} poches données',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      request.raisonDemande ?? '',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}