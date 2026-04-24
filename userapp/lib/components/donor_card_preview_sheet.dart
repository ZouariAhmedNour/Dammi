import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:userapp/components/app_button.dart';
import 'package:userapp/models/donor_card_model.dart';
import 'package:userapp/theme/app_colors.dart';
import 'package:userapp/utils/donor_card_pdf.dart';

class DonorCardPreviewSheet extends ConsumerStatefulWidget {
  final String fullName;
  final DonorCard card;

  const DonorCardPreviewSheet({
    super.key,
    required this.fullName,
    required this.card,
  });

  @override
  ConsumerState<DonorCardPreviewSheet> createState() => _DonorCardPreviewSheetState();
}

class _DonorCardPreviewSheetState extends ConsumerState<DonorCardPreviewSheet> {
  bool loadingPdf = false;

  @override
  Widget build(BuildContext context) {
    final date = widget.card.dateEditionCarte != null
        ? DateFormat('dd MMM yyyy', 'fr_FR').format(widget.card.dateEditionCarte!)
        : '--';

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const Gap(16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.22),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water_drop_rounded, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Carte Donneur',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withOpacity(0.18)),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(22),
                  Text(
                    widget.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Gap(8),
                  const Text(
                    'Merci pour votre engagement solidaire',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const Gap(22),
                  Row(
                    children: [
                      Expanded(child: _badge('Groupe', widget.card.groupeSanguin)),
                      const Gap(10),
                      Expanded(child: _badge('Dons', '${widget.card.nbDon}')),
                    ],
                  ),
                  const Gap(12),
                  _infoLine(
                    icon: Icons.event_available_outlined,
                    label: 'Édition',
                    value: date,
                  ),
                  if ((widget.card.lieuCollecte ?? '').isNotEmpty) ...[
                    const Gap(10),
                    _infoLine(
                      icon: Icons.location_on_outlined,
                      label: 'Lieu',
                      value: widget.card.lieuCollecte!,
                    ),
                  ],
                ],
              ),
            ),
            const Gap(16),
            AppButton(
              label: loadingPdf ? 'Génération du PDF...' : 'Télécharger en PDF',
              trailingIcon: Icons.download_outlined,
              height: 54,
              loading: loadingPdf,
              onPressed: loadingPdf
                  ? null
                  : () async {
                      setState(() => loadingPdf = true);
                      try {
                        final file = await generateDonorCardPdf(
                          fullName: widget.fullName,
                          card: widget.card,
                        );
                        await OpenFilex.open(file.path);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('PDF enregistré : ${file.path}')),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => loadingPdf = false);
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label : $value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}