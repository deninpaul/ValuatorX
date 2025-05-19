import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:valuatorx/pages/common/map/map_action_button.dart';
import 'package:valuatorx/pages/common/map/map_wrapper.dart';
import 'package:valuatorx/pages/common/map/numbered_marker.dart';

class LocationViewTile extends StatelessWidget {
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

  resetLocation(LatLng location) {
    Future.delayed(Duration(milliseconds: 100), () {
      mapController.move(location, 18);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final location = LatLng(double.parse(latitude), double.parse(longitude));

    return Container(
      height: 280,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(32)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) {},
        child: MapWrapper(
          mapController: mapController,
          center: location,
          zoom: 18,
          actions: [MapActionButton(onPressed: () => resetLocation(location), icon: Icons.replay)],
          children: [
            MarkerLayer(markers: [Marker(point: location, width: 56, height: 40, child: NumberedMarker(text: label))]),
          ],
        ),
      ),
    );
  }
}
