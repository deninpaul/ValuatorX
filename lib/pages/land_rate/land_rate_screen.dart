import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/modals/land_rate.dart';
import 'package:valuatorx/pages/common/cluster_icon.dart';
import 'package:valuatorx/pages/common/map_actions.dart';
import 'package:valuatorx/pages/land_rate/components/details_view.dart';
import 'package:valuatorx/pages/common/summary_tile.dart';
import 'package:valuatorx/pages/common/numbered_marker.dart';
import 'package:valuatorx/pages/common/pill.dart';
import 'package:valuatorx/providers/land_rate_provider.dart';
import 'package:valuatorx/providers/location_provider.dart';
import 'package:valuatorx/utils/common_utils.dart';

class LandRateScreen extends StatefulWidget {
  const LandRateScreen({super.key});

  @override
  State<LandRateScreen> createState() => _LandRateScreenState();
}

class _LandRateScreenState extends State<LandRateScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LandRateProvider>(context, listen: false);
      final landProvider = Provider.of<LocationProvider>(context, listen: false);
      if (provider.selectedItem == -1) landProvider.moveToMyLocation(_mapController);
      provider.getLandRates(context, refresh: provider.landRates.isEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<LandRateProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final dividerColor = theme.dividerColor.withAlpha(64);

    getLandRateLocation(LandRate landRate) {
      return LatLng(double.parse(landRate.latitude) - 0.005, double.parse(landRate.longitude));
    }

    viewLandRate(int id) {
      provider.setSelectedItem(id);
      final selected = provider.getSelectedLandRate();
      final itemLocation = getLandRateLocation(selected);
      _mapController.move(itemLocation, 16);
    }

    return Stack(
      children: [
        Container(color: colorScheme.surface),
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialZoom: 15,
            initialCenter: provider.selectedItem == -1 ? locationProvider.currentLocation : getLandRateLocation(provider.getSelectedLandRate()),
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
          minChildSize: 0.19,
          initialChildSize: 0.36,
          maxChildSize: provider.selectedItem == -1 ? 1 : 0.475,
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
                            : SingleChildScrollView(
                              controller: scrollController,
                              child:
                                  (provider.selectedItem == -1)
                                      ? ListView.separated(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.only(bottom: 80),
                                        physics: NeverScrollableScrollPhysics(),
                                        controller: scrollController,
                                        itemCount: provider.landRates.length,
                                        separatorBuilder: (ctx, index) => Divider(color: dividerColor),
                                        itemBuilder: (ctx, index) {
                                          final landRate = provider.landRates.reversed.toList()[index];
                                          return SummaryTile(
                                            id: landRate.id,
                                            title: "${landRate.latitude}° ${landRate.longitude}°",
                                            subtitle: "${landRate.landRatePerCent}/cent",
                                            info: "${landRate.monthOfVisit} ${landRate.yearOfVisit}",
                                            tag: "No.: ${landRate.slNo}",
                                            onTapAction: viewLandRate,
                                          );
                                        },
                                      )
                                      : DetailsView(landRate: provider.getSelectedLandRate()),
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
