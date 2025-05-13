import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:valuatorx/pages/common/map/map_action_button.dart';
import 'package:valuatorx/pages/common/map/map_wrapper.dart';
import 'package:valuatorx/pages/common/map/numbered_marker.dart';

class LocationViewTile extends StatefulWidget {
  final MapController mapController;
  final String latitude;
  final String longitude;
  final String label;
  const LocationViewTile({
    super.key,
    required this.mapController,
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  @override
  State<LocationViewTile> createState() => _LocationViewTileState();
}

class _LocationViewTileState extends State<LocationViewTile> {
  late final LatLng location;

  @override
  void initState() {
    location = LatLng(double.parse(widget.latitude), double.parse(widget.longitude));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resetLocation();
    });
    super.initState();
  }

  resetLocation() {
    Future.delayed(Duration(milliseconds: 100), () {
      widget.mapController.move(location, 18);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 280,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(32)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) {},
        child: MapWrapper(
          borderRadius: 24,
          mapController: widget.mapController,
          actions: [MapActionButton(onPressed: resetLocation, icon: Icons.replay)],
          children: [
            MarkerLayer(
              markers: [Marker(point: location, width: 56, height: 40, child: NumberedMarker(text: widget.label))],
            ),
          ],
        ),
      ),
    );
  }
}
