import 'dart:async';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/models/valuation.dart';
import 'package:valuatorx/pages/common/button/create_button.dart';
import 'package:valuatorx/pages/common/expandable_list.dart';
import 'package:valuatorx/pages/common/header/filter_pill.dart';
import 'package:valuatorx/pages/common/header/search_header.dart';
import 'package:valuatorx/pages/common/view/info_tile.dart';
import 'package:valuatorx/pages/common/summary_tile.dart';
import 'package:valuatorx/pages/valuation/valuation_details.dart';
import 'package:valuatorx/pages/valuation/valuation_form.dart';
import 'package:valuatorx/providers/valuation_provider.dart';
import 'package:valuatorx/utils/common.dart';

class Valuations extends StatefulWidget {
  const Valuations({super.key});

  @override
  State<Valuations> createState() => _ValuationsState();
}

class _ValuationsState extends State<Valuations> with WidgetsBindingObserver {
  late ValuationProvider provider;
  String searchQuery = "";
  String filter = Valuation.statusOptions[0];
  Timer? timer;



  onSearchAction(String val) {
    setState(() => searchQuery = val);
  }

  onSelectFilter(String val) {
    setState(() => filter = val);
  }

  Future<void> fetchAllValuations({bool refresh = true}) async {
    await provider.getValuations(context, refresh: refresh);
    await provider.getDrafts();
  }

  syncData() async {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 30), (_) async => await fetchAllValuations(refresh: provider.valuations.isEmpty));
  }

  void stopSync() {
    timer?.cancel();
    timer = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<ValuationProvider>(context, listen: false);
      fetchAllValuations();
      syncData();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      stopSync();
    } else if (state == AppLifecycleState.resumed) {
      syncData();
    }
  }

  @override
  void dispose() {
    stopSync();
    provider.setSelectedItem("", notify: false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<ValuationProvider>(context);
    final isHomePage = provider.selectedItem == "";
    final total = provider.allValutions.length.toString().padLeft(2, '0');
    final inProgress = provider.allValutions.where((r) => r.status == Valuation.statusOptions[0]).length.toString().padLeft(2, '0');

    viewValuation(String id) {
      provider.setSelectedItem(id);
    }

    return PageTransitionSwitcher(
      reverse: isHomePage,
      transitionBuilder: defaultTransition(colorScheme.surfaceContainer),
      child:
          isHomePage
              ? Scaffold(
                backgroundColor: colorScheme.surfaceContainer,
                floatingActionButton: CreateButton(createPage: ValuationForm(), label: "New report"),
                body: RefreshIndicator(
                  onRefresh: fetchAllValuations,
                  child: ListView(
                    key: const ValueKey('list'),
                    children: [
                      SearchHeader(
                        name: "Valuation",
                        query: searchQuery,
                        onSearch: onSearchAction,
                        actions: [PopupMenuItem(onTap: fetchAllValuations, child: Text("Refresh"))],
                      ),
                      SizedBox(height: 16),
                      Row(
                        spacing: 20,
                        children: [
                          Expanded(child: InfoTile(icon: Icons.view_carousel_rounded, title: "Total reports", value: total)),
                          Expanded(child: InfoTile(icon: Icons.timelapse_rounded, title: "In progress", value: inProgress)),
                        ],
                      ),
                      SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FilterPill(text: Valuation.statusOptions[0], selectedText: filter, onSelected: onSelectFilter),
                            FilterPill(text: "All", selectedText: filter, onSelected: onSelectFilter),
                            FilterPill(text: Valuation.statusOptions[1], selectedText: filter, onSelected: onSelectFilter),
                            FilterPill(text: "Drafts", selectedText: filter, onSelected: onSelectFilter),
                            // FilterPill(text: "Trash", selectedText: filter, onSelected: onSelectFilter),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      ExpandableList(
                        items: provider.getSearchResults(query: searchQuery, filter: filter),
                        isLoading: provider.isLoading,
                        initialCount: 30,
                        itemBuilder: (ctx, valuation, index) {
                          return SummaryTile(
                            id: valuation.id,
                            title: valuation.title,
                            subtitle: valuation.subtitle,
                            info: valuation.dateOfInspection,
                            tag: valuation.status,
                            onTapAction: viewValuation,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
              : ValuationDetails(valuation: provider.getSelectedValuation()),
    );
  }
}
