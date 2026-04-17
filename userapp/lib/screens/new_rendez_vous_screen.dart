import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:userapp/models/appointment_models.dart';
import 'package:userapp/providers/appointment_providers.dart';
import 'package:userapp/theme/app_colors.dart';

class NewRendezVousScreen extends ConsumerStatefulWidget {
  final int pointId;

  const NewRendezVousScreen({
    super.key,
    required this.pointId,
  });

  @override
  ConsumerState<NewRendezVousScreen> createState() =>
      _NewRendezVousScreenState();
}

class _NewRendezVousScreenState extends ConsumerState<NewRendezVousScreen> {
  TypeDonLite? _selectedTypeDon;
  DateTime _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate;
  CreneauCollecteModel? _selectedSlot;

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _changeMonth(int offset) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + offset);
      _selectedDate = null;
      _selectedSlot = null;
    });
  }

  void _continueToQuestionnaire(PointCollecteModel point) {
    if (_selectedTypeDon == null || _selectedDate == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez compléter le type de don, la date et le créneau.'),
        ),
      );
      return;
    }

    ref.read(appointmentFlowProvider.notifier).setSelection(
          point: point,
          typeDon: _selectedTypeDon!,
          date: _selectedDate!,
          slot: _selectedSlot!,
        );

    context.go('/appointment/questionnaire');
  }

  @override
  Widget build(BuildContext context) {
    final pointAsync = ref.watch(pointCollecteDetailsProvider(widget.pointId));

    return Scaffold(
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new_rounded),
    onPressed: () => context.pop(),
  ),
  title: const Text('Nouveau Rendez-vous'),
),
      body: pointAsync.when(
        data: (point) {
          final availableDaysAsync = _selectedTypeDon == null
              ? null
              : ref.watch(
                  joursDisponiblesProvider(
                    (
                      pointCollecteId: point.id,
                      typeDonId: _selectedTypeDon!.id,
                      year: _displayedMonth.year,
                      month: _displayedMonth.month,
                    ),
                  ),
                );

          final availableDays = availableDaysAsync?.maybeWhen(
                data: (days) => days,
                orElse: () => <JourDisponibleModel>[],
              ) ??
              <JourDisponibleModel>[];

          final enabledDates = availableDays
              .map((e) => _normalizeDate(e.parsedDate))
              .toSet();

          if (_selectedDate != null &&
              !enabledDates.contains(_normalizeDate(_selectedDate!))) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _selectedDate = null;
                _selectedSlot = null;
              });
            });
          }

          final slotsAsync = (_selectedTypeDon != null && _selectedDate != null)
              ? ref.watch(
                  creneauxDuJourProvider(
                    (
                      pointCollecteId: point.id,
                      typeDonId: _selectedTypeDon!.id,
                      date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    ),
                  ),
                )
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _StepHeader(currentStep: 1),
                const SizedBox(height: 24),
                const Text(
                  'Nouveau Rendez-vous',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choisissez le type de don et votre créneau pour commencer votre geste héroïque.',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  point.nom,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  point.fullAddress,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),

                const Text(
                  '1. TYPE DE DON',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                ...point.typesDon.map((type) {
                  final selected = _selectedTypeDon?.id == type.id;

                  IconData iconData;
                  final lower = type.label.toLowerCase();
                  if (lower.contains('plasma')) {
                    iconData = Icons.science_outlined;
                  } else if (lower.contains('plaquette')) {
                    iconData = Icons.medical_services_outlined;
                  } else {
                    iconData = Icons.water_drop_outlined;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTypeDon = type;
                          _selectedDate = null;
                          _selectedSlot = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              iconData,
                              color: selected ? Colors.white : AppColors.primaryDark,
                              size: 26,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Don de ${type.label}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: selected ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _typeDescription(type.label),
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.4,
                                      color: selected
                                          ? Colors.white.withOpacity(.85)
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              selected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: selected ? Colors.white : AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 18),
                const Text(
                  '2. CHOISIR UNE DATE',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                 child: _selectedTypeDon == null
    ? const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Choisissez d’abord un type de don',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      )
    : availableDaysAsync!.when(
        data: (days) {
          final enabledDates = days
              .map((e) => _normalizeDate(e.parsedDate))
              .toSet();

          return _CustomCalendar(
            displayedMonth: _displayedMonth,
            selectedDate: _selectedDate,
            enabledDates: enabledDates,
            onPreviousMonth: () => _changeMonth(-1),
            onNextMonth: () => _changeMonth(1),
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
                _selectedSlot = null;
              });
            },
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Erreur chargement jours disponibles : $e'),
        ),
      ),
                ),

                const SizedBox(height: 22),
                const Text(
                  '3. CRÉNEAUX DISPONIBLES',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),

                if (_selectedDate == null)
                  const Text(
                    'Cliquez sur un jour disponible pour voir les créneaux.',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else if (slotsAsync == null)
                  const SizedBox.shrink()
                else
                  slotsAsync.when(
                    data: (slots) {
                      if (slots.isEmpty) {
                        return const Text(
                          'Aucun créneau disponible pour cette date.',
                          style: TextStyle(color: AppColors.textSecondary),
                        );
                      }

                      final morningSlots = slots.where((slot) => slot.dateTime.hour < 12).toList();
                      final afternoonSlots = slots.where((slot) => slot.dateTime.hour >= 12).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (morningSlots.isNotEmpty) ...[
                            const _SlotSectionTitle(
                              icon: Icons.wb_sunny_outlined,
                              title: 'Matinée',
                            ),
                            const SizedBox(height: 12),
                            _SlotsGrid(
                              slots: morningSlots,
                              selectedSlot: _selectedSlot,
                              onSelect: (slot) {
                                setState(() {
                                  _selectedSlot = slot;
                                });
                              },
                            ),
                            const SizedBox(height: 18),
                          ],
                          if (afternoonSlots.isNotEmpty) ...[
                            const _SlotSectionTitle(
                              icon: Icons.wb_twilight_outlined,
                              title: 'Après-midi',
                            ),
                            const SizedBox(height: 12),
                            _SlotsGrid(
                              slots: afternoonSlots,
                              selectedSlot: _selectedSlot,
                              onSelect: (slot) {
                                setState(() {
                                  _selectedSlot = slot;
                                });
                              },
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Erreur chargement créneaux : $e'),
                  ),

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.primaryDark),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "N'oubliez pas de bien manger et de vous hydrater avant votre don. Prévoyez environ 45 minutes sur place.",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _selectedSlot == null
                        ? null
                        : () => _continueToQuestionnaire(point),
                    child: const Text('Valider'),
                  ),
                ),
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

  String _typeDescription(String label) {
    final lower = label.toLowerCase();

    if (lower.contains('plasma')) {
      return 'Essentiel pour fabriquer des médicaments pour les grands brûlés.';
    }
    if (lower.contains('plaquette')) {
      return 'Crucial pour les patients atteints de leucémie et de cancers.';
    }
    return 'Le don le plus fréquent, vital pour les urgences et la chirurgie.';
  }
}

class _CustomCalendar extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final Set<DateTime> enabledDates;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  const _CustomCalendar({
    required this.displayedMonth,
    required this.selectedDate,
    required this.enabledDates,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<DateTime> _calendarDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
    final endDate = lastDayOfMonth.add(Duration(days: 7 - lastDayOfMonth.weekday));

    final days = <DateTime>[];
    var current = startDate;

    while (!current.isAfter(endDate)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = _calendarDays(displayedMonth);
    final monthLabel = _capitalize(DateFormat('MMMM yyyy', 'fr_FR').format(displayedMonth));
    const weekDays = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  monthLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: weekDays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: calendarDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final day = calendarDays[index];
              final normalized = _normalizeDate(day);
              final isCurrentMonth =
                  day.month == displayedMonth.month && day.year == displayedMonth.year;
              final isAvailable = isCurrentMonth && enabledDates.contains(normalized);
              final isSelected = selectedDate != null &&
                  _normalizeDate(selectedDate!) == normalized;

              Color bgColor = Colors.transparent;
              Color textColor = AppColors.textPrimary;
              FontWeight fontWeight = FontWeight.w700;
              Border? border;

              if (!isCurrentMonth) {
                textColor = const Color(0xFFD7CFC4);
              } else if (!isAvailable) {
                bgColor = const Color(0xFFF4EEE6);
                textColor = const Color(0xFFD7CFC4);
              } else if (isSelected) {
                bgColor = AppColors.primaryDark;
                textColor = Colors.white;
                border = Border.all(color: Colors.white, width: 2);
              }

              return GestureDetector(
                onTap: isAvailable ? () => onDateSelected(normalized) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: border,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: fontWeight,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}

class _SlotSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SlotSectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SlotsGrid extends StatelessWidget {
  final List<CreneauCollecteModel> slots;
  final CreneauCollecteModel? selectedSlot;
  final ValueChanged<CreneauCollecteModel> onSelect;

  const _SlotsGrid({
    required this.slots,
    required this.selectedSlot,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: slots.map((slot) {
        final selected = selectedSlot?.id == slot.id;
        final enabled = slot.placesRestantes > 0 && slot.actif;

        return GestureDetector(
          onTap: enabled ? () => onSelect(slot) : null,
          child: Container(
            width: 98,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: !enabled
                  ? const Color(0xFFF4EEE6)
                  : selected
                      ? AppColors.primaryDark
                      : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(14),
              border: selected ? Border.all(color: Colors.white, width: 2) : null,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryDark.withOpacity(.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              slot.heureDebut,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: !enabled
                    ? const Color(0xFFD7CFC4)
                    : selected
                        ? Colors.white
                        : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int>? onStepTapped;

  const _StepHeader({
    required this.currentStep,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    Widget dot(int step, String label) {
      final active = step == currentStep;
      final done = step < currentStep;
      final clickable = onStepTapped != null && step < currentStep;

      final content = Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: active || done
                    ? AppColors.primary
                    : AppColors.surfaceDark,
                child: Text(
                  '$step',
                  style: TextStyle(
                    color: active || done ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (step != 3)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: active ? AppColors.primaryDark : AppColors.textMuted,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      );

      return Expanded(
        child: clickable
            ? InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onStepTapped!(step),
                child: content,
              )
            : content,
      );
    }

    return Row(
      children: [
        dot(1, 'TYPE'),
        dot(2, 'QUESTIONNAIRE'),
        dot(3, 'CONFIRMATION'),
      ],
    );
  }
}