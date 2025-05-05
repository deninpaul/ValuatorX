import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/modals/land_rate.dart';
import 'package:valuatorx/pages/common/delete_dialog.dart';
import 'package:valuatorx/providers/land_rate_provider.dart';

class DetailsView extends StatelessWidget {
  final LandRate landRate;
  const DetailsView({super.key, required this.landRate});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<LandRateProvider>(context);

    onEditAction(int id) {
      provider.setSelectedItem(id);
      Navigator.pushNamed(context, '/land_rate/edit');
    }

    onDeleteAction(LandRate landRate) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => DeleteDialog(
              onDelete: () async {
                await provider.deleteLandRate(context, landRate);
              },
            ),
      );
      if (confirmed == true) {
        provider.setSelectedItem(-1);
      }
    }

    onBackAction() {
      Future.microtask(() {
        provider.setSelectedItem(-1);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 16,
              children: [
                IconButton(onPressed: onBackAction, icon: Icon(Icons.arrow_back_outlined)),
                Text(landRate.slNo, style: textTheme.bodyLarge),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                IconButton(onPressed: () => onEditAction(landRate.id), icon: Icon(Icons.mode_edit_outlined)),
                IconButton(onPressed: () => onDeleteAction(landRate), icon: Icon(Icons.delete_outline)),
              ],
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              ViewTile(title: "Latitude", value: landRate.latitude),
              ViewTile(title: "Longitude", value: landRate.longitude),
              ViewTile(title: "Land Rate (per cent)", value: landRate.landRatePerCent),
              ViewTile(title: "Size of Land / Remarks", value: landRate.landSizeRemarks),
              ViewTile(title: "Type of Land", value: landRate.landType),
              ViewTile(title: "Type of Road", value: landRate.road),
              ViewTile(title: "Date of Visit", value: "${landRate.monthOfVisit} ${landRate.yearOfVisit}"),
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
