import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/pages/common/summary_tile.dart';
import 'package:valuatorx/pages/land_rate/components/numbered_marker.dart';
import 'package:valuatorx/pages/land_rate/components/pill.dart';
import 'package:valuatorx/providers/land_rate_provider.dart';

class LandRate extends StatefulWidget {
  const LandRate({super.key});

  @override
  State<LandRate> createState() => _LandRateState();
}

class _LandRateState extends State<LandRate> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LandRateProvider>(context, listen: false);
      if (provider.landRates.isEmpty) {
        provider.getLandRates();
      }
    });
    _goToMyLocation();
  }

  Future<void> _goToMyLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) return;
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() => _currentLocation = LatLng(position.latitude, position.longitude));
    _mapController.move(_currentLocation, 12);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<LandRateProvider>(context);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(initialCenter: _currentLocation),
          children: [
            Container(color: colorScheme.surface),
            TileLayer(
              urlTemplate: "https://api.maptiler.com/maps/bright-v2/{z}/{x}/{y}.png?key=cnscXQAGGIRCXm0KVoTo",
              userAgentPackageName: "com.example.valuatorx",
            ),
            MarkerLayer(
              markers: [
                Marker(point: _currentLocation, child: Icon(Icons.my_location, color: Colors.blue, size: 32)),
                ...provider.landRates.map((rate) {
                  return Marker(
                    width: 48,
                    height: 48,
                    point: LatLng(double.tryParse(rate.latitude) ?? 0, double.tryParse(rate.longitude) ?? 0),
                    child: NumberedMarker(text: rate.slNo),
                  );
                }),
              ],
            ),
            Container(
              alignment: AlignmentDirectional.topEnd,
              child: ElevatedButton(onPressed: () {}, child: Text("test")),
            ),
          ],
        ),
        DraggableScrollableSheet(
          minChildSize: 0.2,
          initialChildSize: 0.35,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: colorScheme.shadow.withAlpha(25), blurRadius: 10, offset: Offset(0, 0))],
              ),
              child: Column(
                children: [
                  SingleChildScrollView(controller: scrollController, child: Pill(color: theme.dividerColor)),
                  Expanded(
                    child:
                        provider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.only(bottom: 80),
                              physics: BouncingScrollPhysics(),
                              controller: scrollController,
                              itemCount: provider.landRates.length,
                              itemBuilder: (context, index) => SummaryTile(landRate: provider.landRates[index]),
                              separatorBuilder: (context, index) => Divider(),
                            ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
