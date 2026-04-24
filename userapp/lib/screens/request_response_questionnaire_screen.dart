import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:userapp/api/appointment_api.dart';
import 'package:userapp/api/blood_request_api.dart';
import 'package:userapp/models/appointment_models.dart';
import 'package:userapp/providers/appointment_providers.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/providers/blood_request_provider.dart' hide bloodRequestApiProvider;
import 'package:userapp/providers/urgent_requests_provider.dart';
import 'package:userapp/theme/app_colors.dart';

class RequestResponseQuestionnaireScreen extends ConsumerStatefulWidget {
  final int demandeId;

  const RequestResponseQuestionnaireScreen({
    super.key,
    required this.demandeId,
  });

  @override
  ConsumerState<RequestResponseQuestionnaireScreen> createState() =>
      _RequestResponseQuestionnaireScreenState();
}

class _RequestResponseQuestionnaireScreenState
    extends ConsumerState<RequestResponseQuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<int, String> _answers = {};
  bool _submitting = false;

  Future<void> _submitQuestionnaire(QuestionnaireModel questionnaire) async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authControllerProvider);
    final userId = auth.user?.id;

    if (userId == null) return;

    setState(() => _submitting = true);

    try {
      final api = ref.read(appointmentApiProvider);

      final questionnaireResponse = await api.soumettreQuestionnaire(
        userId: userId,
        questionnaireId: questionnaire.id,
        reponses: _answers.entries
            .map((e) => {
                  'questionId': e.key,
                  'valeur': e.value,
                })
            .toList(),
      );

      if (!questionnaireResponse.isEligible) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Non éligible'),
            content: const Text(
              'Le questionnaire indique que vous ne pouvez pas contribuer pour le moment.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      final contribution = await ref.read(bloodRequestApiProvider).contribuerAUneDemande(
            demandeId: widget.demandeId,
            userId: userId,
          );

      ref.invalidate(allRequestsProvider);
      ref.invalidate(compatibleUrgentRequestsProvider(userId));
ref.invalidate(hasUnreadUrgentRequestsProvider(userId));
      ref.invalidate(userBloodRequestsProvider(userId));

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Contribution confirmée'),
          content: Text(
            contribution['completed'] == true
                ? 'Dirigez-vous vers le point de collecte mentionné pour achever votre mission. La demande est maintenant satisfaite.'
                : 'Dirigez-vous vers le point de collecte mentionné pour achever votre mission.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      context.go('/request/history');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionnaireAsync = ref.watch(questionnaireEligibiliteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Questionnaire d'éligibilité"),
      ),
      body: questionnaireAsync.when(
        data: (questionnaire) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 26),
                  Text(
                    questionnaire.titre,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  if (questionnaire.description != null &&
                      questionnaire.description!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      questionnaire.description!,
                      style: const TextStyle(
                        fontSize: 17,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ...questionnaire.questions.map((item) {
                    final question = item.question;
                    final options =
                        question.options.where((e) => e.active).toList();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.texte,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (question.aide != null &&
                              question.aide!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              question.aide!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          if (options.isNotEmpty)
                            FormField<String>(
                              validator: (value) {
                                if (item.obligatoire &&
                                    (_answers[item.questionId]?.isEmpty ??
                                        true)) {
                                  return 'Réponse obligatoire';
                                }
                                return null;
                              },
                              builder: (state) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...options.map((opt) {
                                      final selected =
                                          _answers[item.questionId] == opt.value;

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _answers[item.questionId] =
                                                  opt.value;
                                            });
                                            state.didChange(opt.value);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? AppColors.primaryDark
                                                  : AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: selected
                                                    ? AppColors.primaryDark
                                                    : AppColors.border,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    opt.label,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: selected
                                                          ? Colors.white
                                                          : AppColors
                                                              .textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                Icon(
                                                  selected
                                                      ? Icons
                                                          .check_circle_rounded
                                                      : Icons
                                                          .radio_button_unchecked_rounded,
                                                  color: selected
                                                      ? Colors.white
                                                      : AppColors.textMuted,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    if (state.hasError)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 6),
                                        child: Text(
                                          state.errorText!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            )
                          else
                            TextFormField(
                              initialValue: _answers[item.questionId],
                              onChanged: (value) {
                                _answers[item.questionId] = value;
                              },
                              validator: (value) {
                                if (item.obligatoire &&
                                    (value == null || value.trim().isEmpty)) {
                                  return 'Réponse obligatoire';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Votre réponse',
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _submitting
                          ? null
                          : () => _submitQuestionnaire(questionnaire),
                      child: _submitting
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('Valider'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Erreur questionnaire : $e'),
        ),
      ),
    );
  }
}