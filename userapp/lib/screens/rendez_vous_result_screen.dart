import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:userapp/models/appointment_models.dart';
import 'package:userapp/theme/app_colors.dart';

class RendezVousResultScreen extends StatelessWidget {
  final AppointmentResultArgs args;

  const RendezVousResultScreen({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    final rdv = args.rendezVous;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 44,
              backgroundColor: args.success
                  ? Colors.green.withOpacity(.12)
                  : Colors.red.withOpacity(.12),
              child: Icon(
                args.success ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 54,
                color: args.success ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              args.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              args.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (args.motif != null && args.motif!.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  args.motif!,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
            if (rdv != null) ...[
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DÉTAILS DU RENDEZ-VOUS',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      rdv.pointCollecteNom ?? '-',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rdv.dateHeure != null
                          ? DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(rdv.dateHeure!)
                          : '-',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Statut : ${rdv.statut}',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            if (args.success)
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () => context.go('/history'),
                  child: const Text('Voir mes rendez-vous'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Retour à l’accueil'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}