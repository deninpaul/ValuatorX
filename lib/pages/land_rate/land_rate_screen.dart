import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/models/land_rate.dart';
import 'package:valuatorx/pages/common/button/create_button.dart';
import 'package:valuatorx/pages/common/expandable_list.dart';
import 'package:valuatorx/pages/common/map/cluster_icon.dart';
import 'package:valuatorx/pages/common/header/search_header.dart';
import 'package:valuatorx/pages/common/map/map_wrapper.dart';
import 'package:valuatorx/pages/common/tiles/summary_tile.dart';
import 'package:valuatorx/pages/common/map/numbered_marker.dart';
import 'package:valuatorx/pages/land_rate/land_rate_details.dart';
import 'package:valuatorx/pages/land_rate/land_rate_form.dart';
import 'package:valuatorx/providers/land_rate_provider.dart';
import 'package:valuatorx/providers/location_provider.dart';
import 'package:valuatorx/utils/common.dart';

class LandRateScreen extends StatefulWidget {
  const LandRateScreen({super.key});

  @override
  State<LandRateScreen> createState() => _LandRateScreenState();
}

class _LandRateScreenState extends State<LandRateScreen> {
  final MapController _mapController = MapController();
  late LandRateProvider provider;
  late LocationProvider locationProvider;
  String searchQuery = "";
  Timer? timer;

  syncData() async {
    provider = Provider.of<LandRateProvider>(context, listen: false);
    timer = Timer.periodic(const Duration(seconds: 15), (_) => provider.getLandRates(context, refresh: false));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<LandRateProvider>(context, listen: false);
      locationProvider = Provider.of<LocationProvider>(context, listen: false);
      if (locationProvider.isEmpty) locationProvider.moveToMyLocation(_mapController);
      provider.getLandRates(context, refresh: provider.landRates.isEmpty);
      syncData();
    });
  }

  @override
  void dispose() {
    provider.setSelectedItem("", notify: false);
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<LandRateProvider>(context);
    final isHomePage = provider.selectedItem.isEmpty;

    viewLandRate(String id) {
      provider.setSelectedItem(id);
    }

    onSearchAction(String val) {
      setState(() => searchQuery = val);
    }

    Future<void> fetchAllLandRates() async {
      await provider.getLandRates(context);
    }

    return PageTransitionSwitcher(
      reverse: isHomePage,
      transitionBuilder: defaultTransition(colorScheme.surfaceContainer),
      child:
          isHomePage
              ? Scaffold(
                backgroundColor: colorScheme.surfaceContainer,
                floatingActionButton: CreateButton(createPage: LandRateForm(), label: "Add rate"),
                body: RefreshIndicator(
                  onRefresh: fetchAllLandRates,
                  child: ListView(
                    key: const ValueKey('list'),
                    children: [
                      SearchHeader(
                        name: "Land Rate",
                        query: searchQuery,
                        onSearch: onSearchAction,
                        actions: [PopupMenuItem(onTap: fetchAllLandRates, child: Text("Refresh"))],
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: MediaQuery.of(context).size.height / 1.75,
                        clipBehavior: Clip.hardEdge,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), color: colorScheme.surface),
                        child: MapWrapper(
                          mapController: _mapController,
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
                                      point: LatLng(double.tryParse(rate.latitude) ?? 0, double.tryParse(rate.longitude) ?? 0),
                                      child: NumberedMarker(text: rate.slNo, onPressed: () => viewLandRate(rate.id)),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      ExpandableList<LandRate>(
                        items: provider.getSearchResults(searchQuery).reversed.toList(),
                        isLoading: provider.isLoading,
                        itemBuilder: (ctx, landRate, index) {
                          return SummaryTile(
                            onTapAction: viewLandRate,
                            id: landRate.id.toString(),
                            title: "${landRate.latitude}° ${landRate.longitude}°",
                            subtitle: "${landRate.landRatePerCent}/cent",
                            info: "${landRate.monthOfVisit} ${landRate.yearOfVisit}",
                            tag: "No.: ${landRate.slNo}",
                          );
                        },
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              )
              : LandRateDetails(landRate: provider.getSelectedLandRate(), key: const ValueKey('details')),
    );
  }
}
