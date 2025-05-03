import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/pages/common/summary_tile.dart';
import 'package:valuatorx/pages/valuation/components/details_view.dart';
import 'package:valuatorx/providers/valuation_provider.dart';

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
    final provider = Provider.of<ValuationProvider>(context);
    final dividerColor = theme.dividerColor.withAlpha(64);

    viewValuation(int id) {
      provider.setSelectedItem(id);
    }

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child:
                (provider.selectedItem == -1)
                    ? ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(bottom: 80, top: 12),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: provider.valuations.length,
                      separatorBuilder: (ctx, index) => Divider(color: dividerColor),
                      itemBuilder: (ctx, index) {
                        final valuation = provider.valuations.reversed.toList()[index];
                        return SummaryTile(
                          id: valuation.id,
                          title: valuation.reportName,
                          subtitle: "${valuation.village}, ${valuation.taluk}",
                          info: valuation.dateOfInspection,
                          tag: valuation.status,
                          onTapAction: viewValuation,
                        );
                      },
                    )
                    : DetailsView(valuation: provider.getSelectedValuation()),
          ),
    );
  }
}
