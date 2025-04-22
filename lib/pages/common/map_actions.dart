import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:valuatorx/providers/location_provider.dart';

class MapActions extends StatelessWidget {
  final LocationProvider locationProvider;
  final MapController controller;

  const MapActions({super.key, required this.controller, required this.locationProvider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      alignment: AlignmentDirectional.topEnd,
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => locationProvider.goToLocation(controller),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          shape: const CircleBorder(),
          padding: EdgeInsets.all(16),
        ),
        child:
            locationProvider.isLoading
                ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
                : Icon(Icons.gps_fixed, color: colorScheme.onSurfaceVariant, size: 24),
      ),
    );
  }
}
