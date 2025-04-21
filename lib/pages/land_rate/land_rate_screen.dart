import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/pages/land_rate/components/summary_tile.dart';
import 'package:valuatorx/pages/land_rate/components/numbered_marker.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:valuatorx/pages/land_rate/components/pill.dart';
import 'package:valuatorx/providers/land_rate_provider.dart';

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
      provider.getLandRates(context, refresh: provider.landRates.isEmpty);
      provider.goToLocation(_mapController);
    });
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
          options: MapOptions(
            initialCenter: provider.currentLocation,
            interactionOptions: InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
          ),
          children: [
            Container(color: colorScheme.surface),
            TileLayer(
              urlTemplate: "https://api.maptiler.com/maps/bright-v2/{z}/{x}/{y}.png?key=cnscXQAGGIRCXm0KVoTo",
              userAgentPackageName: "com.example.valuatorx",
              tileProvider: CancellableNetworkTileProvider(),
            ),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                size: Size(64, 64),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(50),
                builder: (context, markers) => clusterIcon(markers.length, theme),
                markers: [
                  ...provider.landRates.map((rate) {
                    return Marker(
                      width: 64,
                      height: 40,
                      point: LatLng(double.tryParse(rate.latitude) ?? 0, double.tryParse(rate.longitude) ?? 0),
                      child: NumberedMarker(text: rate.slNo),
                    );
                  }),
                ],
              ),
            ),
            MarkerLayer(
              markers: [Marker(point: provider.currentLocation, child: Icon(Icons.my_location, color: Colors.blue, size: 28))],
            ),
            mapActions(provider, theme),
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

  Widget mapActions(LandRateProvider provider, ThemeData theme) {
    return Container(
      alignment: AlignmentDirectional.topEnd,
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => provider.goToLocation(_mapController),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          shape: const CircleBorder(),
          padding: EdgeInsets.all(16),
        ),
        child:
            provider.isLoadingLocation
                ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
                : Icon(Icons.gps_fixed, color: theme.colorScheme.onSurfaceVariant, size: 24),
      ),
    );
  }

  Widget clusterIcon(int text, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surfaceContainer,
        border: Border.all(
          width: 8,
          strokeAlign: BorderSide.strokeAlignOutside,
          color: theme.colorScheme.primary.withAlpha(64),
        ),
      ),
      alignment: Alignment.center,
      child: Text(text.toString(), style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
    );
  }
}
