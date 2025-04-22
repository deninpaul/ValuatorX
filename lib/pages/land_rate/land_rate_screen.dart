import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/pages/common/cluster_icon.dart';
import 'package:valuatorx/pages/common/map_actions.dart';
import 'package:valuatorx/pages/land_rate/components/summary_tile.dart';
import 'package:valuatorx/pages/common/numbered_marker.dart';
import 'package:valuatorx/pages/common/pill.dart';
import 'package:valuatorx/providers/land_rate_provider.dart';
import 'package:valuatorx/providers/location_provider.dart';
import 'package:valuatorx/utils/common_utils.dart';

class LandRate extends StatefulWidget {
  const LandRate({super.key});

  @override
  State<LandRate> createState() => _LandRateState();
}

class _LandRateState extends State<LandRate> {
  final MapController _mapController = MapController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LandRateProvider>(context, listen: false);
      final landProvider = Provider.of<LocationProvider>(context, listen: false);
      provider.getLandRates(context, refresh: provider.landRates.isEmpty);
      landProvider.goToLocation(_mapController);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<LandRateProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);

    return Stack(
      children: [
        Container(color: colorScheme.surface),
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: locationProvider.currentLocation,
            interactionOptions: InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
          ),
          children: [
            ...baseMapLayers(context),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                size: Size(64, 64),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(50),
                builder: (context, markers) => ClusterIcon(text: markers.length),
                markers: [
                  ...provider.landRates.map((rate) {
                    return Marker(
                      width: 56,
                      height: 40,
                      point: LatLng(double.tryParse(rate.latitude) ?? 0, double.tryParse(rate.longitude) ?? 0),
                      child: NumberedMarker(text: rate.slNo),
                    );
                  }),
                ],
              ),
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: locationProvider.currentLocation,
                  child: Icon(Icons.my_location, color: Colors.blue, size: 28),
                ),
              ],
            ),
            MapActions(controller: _mapController, locationProvider: locationProvider),
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
                boxShadow: [BoxShadow(color: colorScheme.shadow.withAlpha(24), blurRadius: 16, offset: Offset(0, 0))],
              ),
              child: Column(
                children: [
                  SingleChildScrollView(controller: scrollController, child: Pill(color: colorScheme.surfaceDim)),
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
                              itemBuilder:
                                  (context, index) =>
                                      SummaryTile(landRate: provider.landRates.reversed.toList()[index]),
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
