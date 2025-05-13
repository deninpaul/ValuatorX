import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/pages/common/map/map_wrapper.dart';
import 'package:valuatorx/providers/location_provider.dart';

class LocationField extends StatefulWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  const LocationField({super.key, required this.latitudeController, required this.longitudeController});

  @override
  State<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {
  final MapController _mapController = MapController();
  late FocusNode latitudeFocusNode;
  late FocusNode longitudeFocusNode;

  @override
  void initState() {
    super.initState();
    latitudeFocusNode = FocusNode();
    longitudeFocusNode = FocusNode();
    latitudeFocusNode.addListener(() {
      if (!latitudeFocusNode.hasFocus) _onLatitudeChanged(widget.latitudeController.text);
    });
    longitudeFocusNode.addListener(() {
      if (!longitudeFocusNode.hasFocus) _onLongitudeChanged(widget.longitudeController.text);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        final provider = Provider.of<LocationProvider>(context, listen: false);
        final latitudeValue = widget.latitudeController.text;
        final longitudeValue = widget.longitudeController.text;
        if (latitudeValue.isNotEmpty && longitudeValue.isNotEmpty) {
          _mapController.move(LatLng(double.parse(latitudeValue), double.parse(longitudeValue)), 18);
        } else {
          if (provider.currentLocation.latitude == 0) provider.moveToMyLocation(_mapController);
          widget.latitudeController.text = provider.currentLocation.latitude.toString();
          widget.longitudeController.text = provider.currentLocation.longitude.toString();
        }
      });
    });
  }

  _onLatitudeChanged(String value) {
    try {
      _mapController.move(
        LatLng(double.parse(value), _mapController.camera.center.longitude),
        _mapController.camera.zoom,
      );
    } catch (e) {
      _mapController.move(_mapController.camera.center, _mapController.camera.zoom);
    }
  }

  _onLongitudeChanged(String value) {
    try {
      _mapController.move(
        LatLng(_mapController.camera.center.latitude, double.parse(value)),
        _mapController.camera.zoom,
      );
    } catch (e) {
      _mapController.move(_mapController.camera.center, _mapController.camera.zoom);
    }
  }

  _onPositionChanged(MapCamera position, bool hasGesture) {
    final center = position.center;
    widget.latitudeController.text = center.latitude.toStringAsFixed(7);
    widget.longitudeController.text = center.longitude.toStringAsFixed(7);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Icon(Icons.location_on_outlined, size: 24)),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              Row(
                spacing: 16,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: widget.latitudeController,
                      focusNode: latitudeFocusNode,
                      onFieldSubmitted: _onLatitudeChanged,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                      enabled: !provider.isLoading,
                      decoration: InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                    ),
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: widget.longitudeController,
                      focusNode: longitudeFocusNode,
                      onFieldSubmitted: _onLongitudeChanged,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                      enabled: !provider.isLoading,
                      decoration: InputDecoration(labelText: 'Longitude', border: const OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 240,
                child: MapWrapper(
                  borderRadius: 24,
                  mapController: _mapController,
                  enableCenterMarker: true,
                  onPositionChanged: _onPositionChanged,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.pinchMove | InteractiveFlag.doubleTapDragZoom,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
