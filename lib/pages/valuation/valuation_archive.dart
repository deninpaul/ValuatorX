import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:valuatorx/pages/common/animations/horizontal_transition.dart';
import 'package:valuatorx/pages/common/expandable_list.dart';
import 'package:valuatorx/pages/common/header/search_header.dart';
import 'package:valuatorx/pages/common/tiles/summary_tile.dart';
import 'package:valuatorx/pages/valuation/valuation_details.dart';
import 'package:valuatorx/providers/valuation_provider.dart';
import 'package:valuatorx/utils/common.dart';

class ValuationArchive extends StatefulWidget {
  const ValuationArchive({super.key});

  @override
  State<ValuationArchive> createState() => _ValuationArchiveState();
}

class _ValuationArchiveState extends State<ValuationArchive> {
  late ValuationProvider provider;
  String searchQuery = "";

  void onSearchAction(String val) {
    setState(() => searchQuery = val);
  }

  void viewValuation(String id) {
    provider.setSelectedItem(id);
  }

  Future<void> onRefreshArchive() async {
    await provider.getArchivedValuations(context, refresh: true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<ValuationProvider>(context, listen: false);
      onRefreshArchive();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<ValuationProvider>(context);
    final isArchivePage = provider.selectedItem == "";

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Stack(
          children: [
            HorizontalTransition(
              visible: isArchivePage,
              reverse: true,
              child: Scaffold(
                backgroundColor: colorScheme.surfaceContainer,
                appBar: AppBar(
                  centerTitle: false,
                  backgroundColor: colorScheme.surfaceContainer,
                  surfaceTintColor: colorScheme.surfaceContainer,
                  title: Text('Archived Valuations', style: headerTheme),
                  iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
                  actions: [
                    Row(
                      spacing: 8,
                      children: [
                        provider.isLoading
                            ? Shimmer.fromColors(
                              baseColor: colorScheme.surfaceContainerHighest,
                              highlightColor: colorScheme.surfaceContainerHigh,
                              child: Container(
                                height: 15,
                                width: 41,
                                decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(16)),
                              ),
                            )
                            : Text(provider.archived.length.toString(), style: theme.textTheme.bodyMedium),
                        Icon(Icons.archive_outlined, size: 21, color: colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ],
                ),
                body: RefreshIndicator(
                  onRefresh: onRefreshArchive,
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: isMobile(context) ? 0 : 40),
                    child: ListView(
                      key: const ValueKey('list_archive'),
                      children: [
                        SizedBox(height: 15),
                        SearchHeader(name: "Archive", query: searchQuery, onFocus: isArchivePage, onSearch: onSearchAction),
                        SizedBox(height: 15),
                        ExpandableList(
                          items: provider.getArchivedSearchResults(query: searchQuery),
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
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            HorizontalTransition(
              visible: !isArchivePage,
              destroyOnHide: true,
              child: ValuationDetails(
                padding: EdgeInsetsGeometry.symmetric(horizontal: isMobile(context) ? 0 : 40),
                valuation: provider.getSelectedArchivedValuation(),
                archived: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
