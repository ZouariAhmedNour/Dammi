import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:userapp/models/appointment_models.dart';
import 'package:userapp/providers/appointment_providers.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/theme/app_colors.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  
  bool _didFitBounds = false;

  void _fitAllPoints(List<PointCollecteModel> points) {
    if (_didFitBounds || points.isEmpty) return;

    final uniqueCoords = points
        .map((e) => '${e.latitude},${e.longitude}')
        .toSet();

    if (uniqueCoords.length <= 1) {
      _mapController.move(
        LatLng(points.first.latitude, points.first.longitude),
        15,
      );
    } else {
      final bounds = LatLngBounds.fromPoints(
        points.map((e) => LatLng(e.latitude, e.longitude)).toList(),
      );

      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
      );
    }

    _didFitBounds = true;
  }

  void _openPointDetails(PointCollecteModel point, bool eligible) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        point.nom,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  point.fullAddress,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (point.description != null &&
                    point.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    point.description!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: point.typesDon
                      .map(
                        (type) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: eligible
                        ? () {
                            Navigator.of(context).pop();
                            context.go('/appointment/new/${point.id}');
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: eligible
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      foregroundColor: eligible ? Colors.white : Colors.grey,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey,
                    ),
                    child: const Text('Prendre un rendez-vous'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pointsAsync = ref.watch(pointsCollecteProvider);

    final auth = ref.watch(authControllerProvider);

     final status = auth.user?.eligibilityStatus?.trim().toUpperCase();
     final eligible = status == 'ELIGIBLE';

    

    return Scaffold(
      body: pointsAsync.when(
        data: (points) {
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(34.0, 9.0),
              initialZoom: 6.5,
              onMapReady: () {
                if (!_didFitBounds) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    _fitAllPoints(points);
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.userapp',
              ),
              MarkerLayer(
                markers: points.map((point) {
                  return Marker(
                    point: LatLng(point.latitude, point.longitude),
                    width: 64,
                    height: 64,
                    child: GestureDetector(
                      onTap: () {
                        _mapController.move(
                          LatLng(point.latitude, point.longitude),
                          15,
                        );
                        _openPointDetails(point, eligible);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Erreur de chargement des points\n$e',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
