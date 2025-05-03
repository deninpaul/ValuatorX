import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/modals/valuation.dart';
import 'package:valuatorx/pages/common/delete_dialog.dart';
import 'package:valuatorx/providers/valuation_provider.dart';

class DetailsView extends StatelessWidget {
  final Valuation valuation;
  const DetailsView({super.key, required this.valuation});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<ValuationProvider>(context);

    onEditAction(int id) {
      provider.setSelectedItem(id);
      Navigator.pushNamed(context, '/land_rate/edit');
    }

    onDeleteAction(Valuation valuation) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => DeleteDialog(
              onDelete: () async {
                await provider.deleteValuation(context, valuation);
              },
            ),
      );
      if (confirmed == true) {
        provider.setSelectedItem(-1);
      }
    }

    onBackAction() {
      provider.setSelectedItem(-1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 12,
              children: [
                IconButton(onPressed: onBackAction, icon: Icon(Icons.arrow_back_outlined)),
                Text(valuation.reportName, style: textTheme.bodyLarge),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                IconButton(onPressed: () => onEditAction(valuation.id), icon: Icon(Icons.mode_edit_outlined)),
                IconButton(onPressed: () => onDeleteAction(valuation), icon: Icon(Icons.delete_outline)),
              ],
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              ViewTile(title: "Latitude", value: valuation.latitude),
              ViewTile(title: "Longitude", value: valuation.longitude),
              ViewTile(title: "Land Rate (per cent)", value: valuation.reportName),
              ViewTile(title: "Size of Land / Remarks", value: valuation.taluk),
              ViewTile(title: "Type of Road", value: valuation.dateOfInspection),
              ViewTile(title: "Date of Visit", value: valuation.taluk),
            ],
          ),
        ),
      ],
    );
  }
}

class ViewTile extends StatelessWidget {
  const ViewTile({super.key, required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelColor = Theme.of(context).colorScheme.onSurface.withAlpha(160);
    final valueFormated = value.trim().isEmpty ? "-" : value;

    return Container(
      height: 80,
      width: 200,
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(title, style: textTheme.bodyMedium!.copyWith(color: labelColor)),
          Text(valueFormated, style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}
