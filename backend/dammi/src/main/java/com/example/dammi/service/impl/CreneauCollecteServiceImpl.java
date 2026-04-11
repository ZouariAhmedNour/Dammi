package com.example.dammi.service.impl;

import com.example.dammi.dto.response.CreneauCollecteResponse;
import com.example.dammi.dto.response.JourDisponibleResponse;
import com.example.dammi.entity.CreneauCollecte;
import com.example.dammi.entity.PointCollecte;
import com.example.dammi.entity.TypeDon;
import com.example.dammi.exception.ResourceNotFoundException;
import com.example.dammi.repository.CreneauCollecteRepository;
import com.example.dammi.repository.PointCollecteRepository;
import com.example.dammi.repository.TypeDonRepository;
import com.example.dammi.service.CreneauCollecteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.YearMonth;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CreneauCollecteServiceImpl implements CreneauCollecteService {

    private final CreneauCollecteRepository creneauRepository;
    private final PointCollecteRepository pointCollecteRepository;
    private final TypeDonRepository typeDonRepository;

    private static final List<LocalTime> HEURES_SANG = List.of(
            LocalTime.of(9, 0),
            LocalTime.of(9, 30),
            LocalTime.of(10, 0),
            LocalTime.of(10, 30),
            LocalTime.of(14, 0),
            LocalTime.of(14, 30),
            LocalTime.of(15, 0)
    );

    private static final List<LocalTime> HEURES_PLASMA = List.of(
            LocalTime.of(8, 30),
            LocalTime.of(9, 30),
            LocalTime.of(10, 30),
            LocalTime.of(13, 30),
            LocalTime.of(15, 0)
    );

    private static final List<LocalTime> HEURES_PLAQUETTES = List.of(
            LocalTime.of(9, 0),
            LocalTime.of(11, 0),
            LocalTime.of(14, 0)
    );

    @Override
    @Transactional(readOnly = true)
    public List<JourDisponibleResponse> getJoursDisponibles(Long pointCollecteId, Long typeDonId, int year, int month) {
        LocalDate start = LocalDate.of(year, month, 1);
        LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

        List<CreneauCollecte> creneaux = creneauRepository
                .findByPointCollecteIdAndTypeDonIdAndDateCollecteBetweenAndActifTrueOrderByDateCollecteAscHeureDebutAsc(
                        pointCollecteId, typeDonId, start, end
                );

        Map<LocalDate, Long> grouped = creneaux.stream()
                .collect(Collectors.groupingBy(CreneauCollecte::getDateCollecte, TreeMap::new, Collectors.counting()));

        return grouped.entrySet().stream()
                .map(e -> new JourDisponibleResponse(e.getKey().toString(), e.getValue().intValue()))
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<CreneauCollecteResponse> getCreneauxDuJour(Long pointCollecteId, Long typeDonId, String date) {
        LocalDate localDate = LocalDate.parse(date);

        return creneauRepository
                .findByPointCollecteIdAndTypeDonIdAndDateCollecteAndActifTrueOrderByHeureDebutAsc(
                        pointCollecteId, typeDonId, localDate
                )
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional
    public void genererPlanningAnnuel(Long pointCollecteId, int year) {
        PointCollecte point = pointCollecteRepository.findById(pointCollecteId)
                .orElseThrow(() -> new ResourceNotFoundException("PointCollecte", "id", pointCollecteId));

        List<TypeDon> typesDon = point.getTypesDon().stream().toList();

        if (typesDon.isEmpty()) {
            throw new IllegalStateException("Aucun type de don n'est configuré pour ce point de collecte");
        }

        Random random = new Random();

        LocalDate start = LocalDate.of(year, 1, 1);
        LocalDate end = LocalDate.of(year, 12, 31);

        creneauRepository.deleteByPointCollecteIdAndDateCollecteBetween(pointCollecteId, start, end);

        for (TypeDon typeDon : typesDon) {
            for (int month = 1; month <= 12; month++) {
                YearMonth ym = YearMonth.of(year, month);

                int nbJoursDisponibles = randomBetween(random, 4, 8);
                Set<LocalDate> joursChoisis = randomWorkingDays(ym, nbJoursDisponibles, random);

                for (LocalDate jour : joursChoisis) {
                    List<LocalTime> horaires = pickHorairesByType(typeDon.getLabel(), random);

                    for (LocalTime heure : horaires) {
                        int places = computePlaces(point.getCapacite(), typeDon.getLabel(), random);

                        CreneauCollecte creneau = CreneauCollecte.builder()
                                .pointCollecte(point)
                                .typeDon(typeDon)
                                .dateCollecte(jour)
                                .heureDebut(heure)
                                .placesTotales(places)
                                .placesRestantes(places)
                                .actif(true)
                                .build();

                        creneauRepository.save(creneau);
                    }
                }
            }
        }
    }

    private List<LocalTime> pickHorairesByType(String typeDonLabel, Random random) {
        String normalized = typeDonLabel == null ? "" : typeDonLabel.trim().toLowerCase();

        List<LocalTime> base;
        if (normalized.contains("plasma")) {
            base = HEURES_PLASMA;
        } else if (normalized.contains("plaquette")) {
            base = HEURES_PLAQUETTES;
        } else {
            base = HEURES_SANG;
        }

        List<LocalTime> copy = new ArrayList<>(base);
        Collections.shuffle(copy, random);

        int count = Math.min(copy.size(), randomBetween(random, 2, Math.min(5, copy.size())));
        return copy.subList(0, count).stream().sorted().toList();
    }

    private int computePlaces(int capacitePoint, String typeDonLabel, Random random) {
        String normalized = typeDonLabel == null ? "" : typeDonLabel.trim().toLowerCase();

        if (normalized.contains("plaquette")) {
            return Math.max(1, Math.min(capacitePoint, randomBetween(random, 1, 2)));
        }

        if (normalized.contains("plasma")) {
            return Math.max(1, Math.min(capacitePoint, randomBetween(random, 2, 4)));
        }

        return Math.max(1, Math.min(capacitePoint, randomBetween(random, 3, capacitePoint)));
    }

    private Set<LocalDate> randomWorkingDays(YearMonth ym, int count, Random random) {
        List<LocalDate> candidates = new ArrayList<>();

        for (int day = 1; day <= ym.lengthOfMonth(); day++) {
            LocalDate date = ym.atDay(day);
            DayOfWeek dow = date.getDayOfWeek();

            if (dow != DayOfWeek.SATURDAY && dow != DayOfWeek.SUNDAY) {
                candidates.add(date);
            }
        }

        Collections.shuffle(candidates, random);

        return candidates.stream()
                .limit(count)
                .collect(Collectors.toCollection(TreeSet::new));
    }

    private int randomBetween(Random random, int min, int max) {
        return random.nextInt(max - min + 1) + min;
    }

    private CreneauCollecteResponse toResponse(CreneauCollecte c) {
        return CreneauCollecteResponse.builder()
                .id(c.getId())
                .pointCollecteId(c.getPointCollecte().getId())
                .pointCollecteNom(c.getPointCollecte().getNom())
                .typeDonId(c.getTypeDon().getId())
                .typeDonLabel(c.getTypeDon().getLabel())
                .dateCollecte(c.getDateCollecte().toString())
                .heureDebut(c.getHeureDebut().toString())
                .placesTotales(c.getPlacesTotales())
                .placesRestantes(c.getPlacesRestantes())
                .actif(c.isActif())
                .build();
    }
}
