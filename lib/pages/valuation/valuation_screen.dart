import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/pages/common/button/create_button.dart';
import 'package:valuatorx/pages/common/expandable_list.dart';
import 'package:valuatorx/pages/common/header/search_header.dart';
import 'package:valuatorx/pages/common/info_tile.dart';
import 'package:valuatorx/pages/common/summary_tile.dart';
import 'package:valuatorx/pages/valuation/valuation_details.dart';
import 'package:valuatorx/pages/valuation/valuation_form.dart';
import 'package:valuatorx/providers/valuation_provider.dart';
import 'package:valuatorx/utils/common_utils.dart';

class Valuations extends StatefulWidget {
  const Valuations({super.key});

  @override
  State<Valuations> createState() => _ValuationsState();
}

class _ValuationsState extends State<Valuations> {
  late ValuationProvider provider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<ValuationProvider>(context, listen: false);
      provider.getValuations(context, refresh: provider.valuations.isEmpty);
    });
  }

  @override
  void dispose() {
    provider.setSelectedItem(-1, notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<ValuationProvider>(context);
    final isHomePage = provider.selectedItem == -1;
    final total = provider.valuations.length.toString().padLeft(2, '0');;
    final inProgress = provider.valuations.where((r) => r.status == "In Progress").length.toString().padLeft(2, '0');;

    viewValuation(int id) {
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
                  onRefresh: () => provider.getValuations(context),
                  child: ListView(
                    key: const ValueKey('list'),
                    children: [
                      SearchHeader(name: "Land Rate", onSearch: (val) => debugPrint(val)),
                      SizedBox(height: 16),
                      Row(
                        spacing: 20,
                        children: [
                          Expanded(child: InfoTile(icon: Icons.view_carousel_rounded, title: "Total reports", value: total)),
                          Expanded(child: InfoTile(icon: Icons.timelapse_rounded, title: "In progress", value: inProgress)),
                        ],
                      ),
                      SizedBox(height: 16),
                      ExpandableList(
                        items: provider.valuations,
                        isLoading: provider.isLoading,
                        itemBuilder: (ctx, valuation, index) {
                          return SummaryTile(
                            id: valuation.id,
                            title: valuation.reportName,
                            subtitle: "${valuation.village}, ${valuation.taluk}",
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
