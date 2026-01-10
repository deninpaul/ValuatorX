import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/models/valuation.dart';
import 'package:valuatorx/pages/common/animations/horizontal_transition.dart';
import 'package:valuatorx/pages/common/button/create_button.dart';
import 'package:valuatorx/pages/common/expandable_list.dart';
import 'package:valuatorx/pages/common/header/filter_pill.dart';
import 'package:valuatorx/pages/common/header/search_header.dart';
import 'package:valuatorx/pages/common/tiles/info_tile.dart';
import 'package:valuatorx/pages/common/tiles/summary_tile.dart';
import 'package:valuatorx/pages/valuation/valuation_archive.dart';
import 'package:valuatorx/pages/valuation/valuation_details.dart';
import 'package:valuatorx/pages/valuation/valuation_form.dart';
import 'package:valuatorx/pages/valuation/valuation_templates.dart';
import 'package:valuatorx/providers/valuation_provider.dart';

class Valuations extends StatefulWidget {
  const Valuations({super.key});

  @override
  State<Valuations> createState() => _ValuationsState();
}

class _ValuationsState extends State<Valuations> with WidgetsBindingObserver {
  late ValuationProvider provider;
  String searchQuery = "";
  String filter = Valuation.statusOptions[0];
  bool isTemplate = false;
  Timer? timer;

  void onSearchAction(String val) {
    setState(() => searchQuery = val);
  }

  void onSelectFilter(String val) {
    setState(() => filter = val);
  }

  void onViewTemplate() {
    setState(() => isTemplate = true);
  }

  void onOpenArchive() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ValuationArchive()));
    provider.setSelectedItem("");
  }

  Future<void> fetchAllValuations({bool refresh = true}) async {
    await provider.getValuations(context, refresh: refresh);
    await provider.getDrafts();
  }

  void syncData() {
    timer?.cancel();
    fetchAllValuations(refresh: provider.valuations.isEmpty);
    timer = Timer.periodic(const Duration(seconds: 30), (_) async => await fetchAllValuations(refresh: provider.valuations.isEmpty));
  }

  void stopSync() {
    timer?.cancel();
    timer = null;
  }

  void onTemplateBackAction() {
    setState(() => isTemplate = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<ValuationProvider>(context, listen: false);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final provider = Provider.of<ValuationProvider>(context);
    final isHomePage = provider.selectedItem == "";
    final total = provider.allValutions.length.toString().padLeft(2, '0');
    final inProgress = provider.allValutions.where((r) => r.status == Valuation.statusOptions[0]).length.toString().padLeft(2, '0');

    viewValuation(String id) {
      provider.setSelectedItem(id);
    }

    openValuationForm(String selected) {
      if (selected.isEmpty) return ValuationForm();
      return ValuationForm(template: provider.allValutions.firstWhere((val) => val.id == selected));
    }

    Widget siteVisitIndicator() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(21), color: colorScheme.secondaryContainer),
        child: Row(
          spacing: 2,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hiking_outlined, size: 12, color: theme.hintColor),
            Icon(Icons.check_circle_outline, size: 12, color: theme.hintColor),
          ],
        ),
      );
    }

    return Stack(
      children: [
        HorizontalTransition(
          visible: isHomePage && !isTemplate,
          reverse: true,
          child: Scaffold(
            backgroundColor: colorScheme.surfaceContainer,
            floatingActionButton: CreateButton(
              label: "New report",
              onOpen: openValuationForm,
              isLoading: provider.isLoading,
              options: provider.templates.map((val) => CreateButtonOption(id: val.id, label: val.templateTile)).toList(),
            ),
            body: RefreshIndicator(
              onRefresh: fetchAllValuations,
              child: ListView(
                key: const ValueKey('list'),
                children: [
                  SearchHeader(
                    name: "Valuation",
                    query: searchQuery,
                    onSearch: onSearchAction,
                    onFocus: isHomePage,
                    actions: [
                      PopupMenuItem(onTap: fetchAllValuations, child: Text("Refresh", style: textTheme.bodyMedium)),
                      PopupMenuItem(onTap: onViewTemplate, child: Text("View templates", style: textTheme.bodyMedium)),
                      PopupMenuItem(onTap: onOpenArchive, child: Text("Archived", style: textTheme.bodyMedium)),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    spacing: 18,
                    children: [
                      Expanded(child: InfoTile(icon: Icons.view_carousel_rounded, title: "Total reports", value: total)),
                      Expanded(child: InfoTile(icon: Icons.timelapse_rounded, title: "In progress", value: inProgress)),
                    ],
                  ),
                  SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FilterPill(text: Valuation.statusOptions[0], selectedText: filter, onSelected: onSelectFilter),
                        FilterPill(text: "All", selectedText: filter, onSelected: onSelectFilter),
                        FilterPill(text: "Site visited", selectedText: filter, onSelected: onSelectFilter),
                        FilterPill(text: Valuation.statusOptions[1], selectedText: filter, onSelected: onSelectFilter),
                        FilterPill(text: "Drafts", selectedText: filter, onSelected: onSelectFilter),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  ExpandableList(
                    items: provider.getSearchResults(query: searchQuery, filter: filter),
                    isLoading: provider.isLoading,
                    initialCount: 30,
                    incrementCount: 30,
                    itemBuilder: (ctx, valuation, index) {
                      return SummaryTile(
                        id: valuation.id,
                        title: valuation.title,
                        subtitle: valuation.subtitle,
                        info: valuation.dateOfInspection,
                        tag: valuation.status,
                        onTapAction: viewValuation,
                        subtitleInfo: valuation.siteVisited ? siteVisitIndicator() : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        HorizontalTransition(
          visible: !isHomePage,
          destroyOnHide: true,
          child: ValuationDetails(valuation: provider.getSelectedValuation()),
        ),
        HorizontalTransition(visible: isTemplate, destroyOnHide: true, child: ValuationTemplates(onBack: onTemplateBackAction)),
      ],
    );
  }
}
