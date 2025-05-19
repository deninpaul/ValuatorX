import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/pages/common/map/map_action_button.dart';
import 'package:valuatorx/providers/location_provider.dart';

class MapWrapper extends StatefulWidget {
  final List<Widget> children;
  final List<MapActionButton> actions;
  final MapController mapController;
  final double borderRadius;
  final bool enableCenterMarker;
  final LatLng center;
  final double zoom;
  final InteractionOptions interactionOptions;
  final Function(MapCamera, bool) onPositionChanged;

  const MapWrapper({
    super.key,
    required this.mapController,
    this.borderRadius = 24,
    this.children = const [],
    this.actions = const [],
    this.enableCenterMarker = false,
    this.center = const LatLng(0,0),
    this.zoom = 15,
    this.interactionOptions = const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
    this.onPositionChanged = _defaultOnPositionChanged,
  });

  static void _defaultOnPositionChanged(MapCamera cam, bool hasGesture) {}

  @override
  State<MapWrapper> createState() => _MapWrapperState();
}

class _MapWrapperState extends State<MapWrapper> {
  String cachePath = "";

  @override
  void initState() {
    getCachePath();
    super.initState();
  }

  getCachePath() async {
    final cacheDirectory = await getTemporaryDirectory();
    setState(() => cachePath = cacheDirectory.path);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final LocationProvider provider = Provider.of<LocationProvider>(context);
    final initialCenter = (widget.center.latitude == 0) ? provider.currentLocation : widget.center;

    return cachePath.isNotEmpty
        ? ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: FlutterMap(
            mapController: widget.mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              interactionOptions: widget.interactionOptions,
              backgroundColor: colorScheme.surface,
              onPositionChanged: widget.onPositionChanged,
              initialZoom: widget.zoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.maptiler.com/maps/bright-v2/{z}/{x}/{y}.png?key=TuYo6WbyTRwcTXZfInOZ',
                userAgentPackageName: 'com.example.valuatorx',
                tileProvider: CachedTileProvider(store: HiveCacheStore(cachePath, hiveBoxName: "mapCache")),
              ),
              ...widget.children,
              MarkerLayer(
                markers: [
                  Marker(point: provider.currentLocation, child: Icon(Icons.my_location, color: Colors.blue, size: 28)),
                ],
              ),
              if (widget.enableCenterMarker)
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
                      onPressed: () => provider.moveToMyLocation(widget.mapController),
                      icon: Icons.gps_fixed,
                      isLoading: provider.isLoading,
                    ),
                    ...widget.actions,
                  ],
                ),
              ),
            ],
          ),
        )
        : Center(child: CircularProgressIndicator());
  }
}
