import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:userapp/providers/blood_request_provider.dart';
import 'package:userapp/screens/urgent_blood_requests_screen.dart';
import 'package:userapp/theme/app_colors.dart';

class AllBloodRequestsScreen extends ConsumerWidget {
  const AllBloodRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(allRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les demandes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: requestsAsync.when(
          data: (requests) {
            if (requests.isEmpty) {
              return const Center(
                child: Text(
                  'Aucune demande disponible.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            final sorted = [...requests]
              ..sort((a, b) {
                // urgentes en premier
                if (a.urgence != b.urgence) {
                  return a.urgence ? -1 : 1;
                }

                final da = a.dateCreation ??
                    DateTime.fromMillisecondsSinceEpoch(0);
                final db = b.dateCreation ??
                    DateTime.fromMillisecondsSinceEpoch(0);

                return db.compareTo(da);
              });

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(allRequestsProvider);
              },
              child: ListView.separated(
                itemCount: sorted.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final request = sorted[index];

                  return BloodRequestCard(
                    request: request,
                    onRespond: () {
                      context.push('/request_response_questionnaire/${request.id}');

                      // contribution
                    },
                  );
                },
              ),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text('Erreur : $e')),
        ),
      ),
    );
  }
}