import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:valuatorx/pages/common/map/map_action_button.dart';
import 'package:valuatorx/pages/common/map/map_wrapper.dart';
import 'package:valuatorx/pages/common/map/numbered_marker.dart';
import 'package:valuatorx/pages/common/view/group_view.dart';
import 'package:valuatorx/pages/common/view/view_tile.dart';
import 'package:valuatorx/utils/common.dart';

class LocationViewTile extends StatelessWidget {
  final MapController mapController;
  final String latitude;
  final String longitude;
  final String label;
  final int tabIndex;
  final IconData icon;
  final Color? markerColor;
  final Function({String fieldName, int fieldTab})? onPressed;
  const LocationViewTile({
    super.key,
    required this.mapController,
    required this.latitude,
    required this.longitude,
    required this.label,
    this.icon = Icons.location_on_outlined,
    this.onPressed,
    this.tabIndex = 0,
    this.markerColor,
  });

  void resetLocation(LatLng location) {
    Future.delayed(Duration(milliseconds: 100), () {
      mapController.move(location, 18);
    });
  }

  double safeDoubleParse(String value) {
    if (value.trim().isEmpty) return 0.0;
    return double.tryParse(value) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final location = LatLng(safeDoubleParse(latitude), safeDoubleParse(longitude));

    return GroupViewWrapper(
      title: "Location",
      icon: icon,
      spacing: 8,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 8),
          child: Container(
            height: isMobile(context) ? 360 : 240,
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
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: location,
                        width: 56,
                        height: 40,
                        child: NumberedMarker(text: label, fill: markerColor ?? colorScheme.secondaryFixedDim),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          spacing: 15,
          children: [
            Expanded(child: ViewTile(title: "Latitude", value: latitude, onPressed: onPressed, tabIndex: tabIndex)),
            Expanded(child: ViewTile(title: "Longitude", value: longitude, onPressed: onPressed, tabIndex: tabIndex)),
          ],
        ),
      ],
    );
  }
}
