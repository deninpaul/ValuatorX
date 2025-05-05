import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/modals/land_rate.dart';
import 'package:valuatorx/pages/common/expandable_list.dart';
import 'package:valuatorx/pages/common/map/cluster_icon.dart';
import 'package:valuatorx/pages/common/header.dart';
import 'package:valuatorx/pages/common/map/map_wrapper.dart';
import 'package:valuatorx/pages/common/summary_tile.dart';
import 'package:valuatorx/pages/common/map/numbered_marker.dart';
import 'package:valuatorx/pages/land_rate/components/details_view.dart';
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
  late LandRateProvider provider;
  late LocationProvider locationProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<LandRateProvider>(context, listen: false);
      locationProvider = Provider.of<LocationProvider>(context, listen: false);
      if (locationProvider.isEmpty) locationProvider.moveToMyLocation(_mapController);
      provider.getLandRates(context, refresh: provider.landRates.isEmpty);
    });
  }

  @override
  void dispose() {
    provider.setSelectedItem(-1, notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<LandRateProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);

    viewLandRate(int id) {
      provider.setSelectedItem(id);
    }

    return PageTransitionSwitcher(
      reverse: provider.selectedItem == -1,
      transitionBuilder: defaultTransition(colorScheme.surfaceContainer),
      child:
          provider.selectedItem == -1
              ? ListView(
                key: const ValueKey('list'),
                children: [
                  Header(name: "Land Rate", onSearch: (val) => print(val)),
                  SizedBox(height: 16),
                  Container(
                    height: MediaQuery.of(context).size.height / 1.75,
                    clipBehavior: Clip.hardEdge,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: colorScheme.surface),
                    child: MapWrapper(
                      mapController: _mapController,
                      provider: locationProvider,
                      enableCenterMarker: false,
                      children: [
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
                                  point: LatLng(
                                    double.tryParse(rate.latitude) ?? 0,
                                    double.tryParse(rate.longitude) ?? 0,
                                  ),
                                  child: NumberedMarker(text: rate.slNo),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  ExpandableList<LandRate>(
                    items: provider.landRates.reversed.toList(),
                    isLoading: provider.isLoading,
                    itemBuilder: (ctx, landRate, index) {
                      return SummaryTile(
                        onTapAction: viewLandRate,
                        id: landRate.id,
                        title: "${landRate.latitude}° ${landRate.longitude}°",
                        subtitle: "${landRate.landRatePerCent}/cent",
                        info: "${landRate.monthOfVisit} ${landRate.yearOfVisit}",
                        tag: "No.: ${landRate.slNo}",
                      );
                    },
                  ),
                  SizedBox(height: 32),
                ],
              )
              : DetailsView(landRate: provider.getSelectedLandRate(), key: const ValueKey('details')),
    );
  }
}
