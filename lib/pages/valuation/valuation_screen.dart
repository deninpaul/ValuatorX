import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/pages/common/expandable_list.dart';
import 'package:valuatorx/pages/common/header.dart';
import 'package:valuatorx/pages/common/summary_tile.dart';
import 'package:valuatorx/pages/valuation/components/details_view.dart';
import 'package:valuatorx/providers/valuation_provider.dart';
import 'package:valuatorx/utils/common_utils.dart';

class Valuations extends StatefulWidget {
  const Valuations({super.key});

  @override
  State<Valuations> createState() => _ValuationsState();
}

class _ValuationsState extends State<Valuations> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ValuationProvider>(context, listen: false);
      provider.getValuations(context, refresh: provider.valuations.isEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<ValuationProvider>(context);
    final dividerColor = theme.dividerColor.withAlpha(64);

    viewValuation(int id) {
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
                  SizedBox(height: 32),
                ],
              )
              : DetailsView(valuation: provider.getSelectedValuation()),
    );
  }
}
