import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/models/land_rate.dart';
import 'package:valuatorx/pages/common/animations/horizontal_transition.dart';
import 'package:valuatorx/pages/common/button/create_button.dart';
import 'package:valuatorx/pages/common/expandable_list.dart';
import 'package:valuatorx/pages/common/field/tag.dart';
import 'package:valuatorx/pages/common/header/filter_pill.dart';
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
  String filter = LandRate.TABLE1;
  bool enableCenterMarker = false;
  String searchQuery = "";
  Timer? timer;

  onSelectFilter(String val) {
    setState(() => filter = val.replaceAll(' ', ''));
  }

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
    provider.setSelectedItem("", "", notify: false);
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<LandRateProvider>(context);
    final isHomePage = provider.selectedItem.isEmpty;

    viewLandRate(String id, String author) {
      provider.setSelectedItem(id, author);
    }

    onSearchAction(String val) {
      setState(() => searchQuery = val);
      final location = parseLatLng(val);
      if (location != null) {
        setState(() => enableCenterMarker = true);
        _mapController.move(location, 15);
      } else {
        setState(() => enableCenterMarker = false);
      }
    }

    onOpenCreate() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.setSelectedTable(filter.replaceAll(' ', ''));
      });
    }

    Future<void> fetchAllLandRates() async {
      await provider.getLandRates(context);
    }

    return Stack(
      children: [
        HorizontalTransition(
          visible: isHomePage,
          reverse: true,
          child: Scaffold(
            backgroundColor: colorScheme.surfaceContainer,
            floatingActionButton: CreateButton(createPage: LandRateForm(), label: "Add rate", onOpen: onOpenCreate),
            body: RefreshIndicator(
              onRefresh: fetchAllLandRates,
              child: ListView(
                key: const ValueKey('list'),
                children: [
                  SearchHeader(
                    name: "Land Rate",
                    query: searchQuery,
                    onSearch: onSearchAction,
                    onFocus: isHomePage,
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
                      enableCenterMarker: enableCenterMarker,
                      interactionOptions: InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate & ~InteractiveFlag.scrollWheelZoom),
                      children: [
                        ...LandRate.tables.map((table) {
                          final mapColor = LandRate.getMapColors(colorScheme, table);
                          return MarkerClusterLayerWidget(
                            options: MarkerClusterLayerOptions(
                              size: Size(64, 64),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(50),
                              builder: (context, markers) {
                                return ClusterIcon(text: markers.length, fill: mapColor.clusterFill, stroke: mapColor.clusterStroke);
                              },
                              markers: [
                                ...provider.landRates.where((rate) => rate.author == table).map((rate) {
                                  return Marker(
                                    width: 56,
                                    height: 40,
                                    point: LatLng(double.tryParse(rate.latitude) ?? 0, double.tryParse(rate.longitude) ?? 0),
                                    child: NumberedMarker(
                                      text: rate.slNo,
                                      onPressed: () => viewLandRate(rate.id, rate.author),
                                      fill: mapColor.markerFill,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FilterPill(text: formatCamelCase(LandRate.TABLE1), selectedText: formatCamelCase(filter), onSelected: onSelectFilter, color: LandRate.getMapColors(colorScheme, LandRate.TABLE1).clusterFill,),
                        FilterPill(text: formatCamelCase(LandRate.TABLE2), selectedText: formatCamelCase(filter), onSelected: onSelectFilter, color: LandRate.getMapColors(colorScheme, LandRate.TABLE2).clusterFill,),
                        FilterPill(text: formatCamelCase(LandRate.TABLE3), selectedText: formatCamelCase(filter), onSelected: onSelectFilter, color: LandRate.getMapColors(colorScheme, LandRate.TABLE3).clusterFill,),
                        FilterPill(text: formatCamelCase(LandRate.TABLE4), selectedText: formatCamelCase(filter), onSelected: onSelectFilter, color: LandRate.getMapColors(colorScheme, LandRate.TABLE4).clusterFill,),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  ExpandableList<LandRate>(
                    items: provider.getSearchResults(searchQuery, filter).reversed.toList(),
                    isLoading: provider.isLoading,
                    itemBuilder: (ctx, landRate, index) {
                      return SummaryTile(
                        id: landRate.id.toString(),
                        title: "${landRate.latitude}° ${landRate.longitude}°",
                        subtitle: "${landRate.landRatePerCent}/cent",
                        info: "${landRate.monthOfVisit} ${landRate.yearOfVisit}",
                        onTapAction: (id) => viewLandRate(id, landRate.author),
                        tag: landRate.slNo,
                        additionalInfo: Tag(
                          text: formatCamelCase(landRate.author),
                          color: LandRate.getMapColors(colorScheme, landRate.author).clusterFill,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          )
        ),
        HorizontalTransition(visible: !isHomePage, destroyOnHide: true, child: LandRateDetails(landRate: provider.getSelectedLandRate(), key: const ValueKey('details')))
      ],
    );
  }
}
