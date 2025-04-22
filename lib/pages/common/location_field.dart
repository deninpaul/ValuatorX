import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/pages/common/map_actions.dart';
import 'package:valuatorx/providers/location_provider.dart';
import 'package:valuatorx/utils/common_utils.dart';

class LocationField extends StatelessWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  LocationField({super.key, required this.latitudeController, required this.longitudeController});

  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 240,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialZoom: 18,
              initialCenter: provider.currentLocation,
              interactionOptions: InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
            ),
            children: [
              ...baseMapLayers(context),
              MarkerLayer(
                markers: [
                  Marker(point: provider.currentLocation, child: Icon(Icons.my_location, color: Colors.blue, size: 28)),
                ],
              ),
              MapActions(controller: _mapController, locationProvider: provider),
            ],
          ),
        ),
        Row(
          children: [
            Flexible(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Lattitude', // You can prettify this if needed
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Flexible(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Longitude', // You can prettify this if needed
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
