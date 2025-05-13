import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/pages/common/map/map_action_button.dart';
import 'package:valuatorx/providers/location_provider.dart';

class MapWrapper extends StatelessWidget {
  final List<Widget> children;
  final List<MapActionButton> actions;
  final MapController mapController;
  final double borderRadius;
  final bool enableCenterMarker;
  final InteractionOptions interactionOptions;
  final Function(MapCamera, bool) onPositionChanged;

  const MapWrapper({
    super.key,
    required this.mapController,
    this.borderRadius = 24,
    this.children = const [],
    this.actions = const [],
    this.enableCenterMarker = false,
    this.interactionOptions = const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
    this.onPositionChanged = _defaultOnPositionChanged,
  });

  static void _defaultOnPositionChanged(MapCamera cam, bool hasGesture) {}

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final LocationProvider provider = Provider.of<LocationProvider>(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: provider.currentLocation,
          interactionOptions: interactionOptions,
          backgroundColor: colorScheme.surface,
          onPositionChanged: onPositionChanged,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://api.maptiler.com/maps/bright-v2/{z}/{x}/{y}.png?key=cnscXQAGGIRCXm0KVoTo',
            userAgentPackageName: 'com.example.valuatorx',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          ...children,
          MarkerLayer(
            markers: [
              Marker(point: provider.currentLocation, child: Icon(Icons.my_location, color: Colors.blue, size: 28)),
            ],
          ),
          if (enableCenterMarker)
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 24),
              child: Icon(Icons.location_pin, color: colorScheme.primary, size: 36), // Fixed center marker
            ),
          Container(
            alignment: AlignmentDirectional.topEnd,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                MapActionButton(
                  onPressed: () => provider.moveToMyLocation(mapController),
                  icon: Icons.gps_fixed,
                  isLoading: provider.isLoading,
                ),
                ...actions,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
