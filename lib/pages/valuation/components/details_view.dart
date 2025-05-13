import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/modals/valuation.dart';
import 'package:valuatorx/pages/common/action_button.dart';
import 'package:valuatorx/pages/common/delete_dialog.dart';
import 'package:valuatorx/pages/common/header/actions_header.dart';
import 'package:valuatorx/pages/common/header/title_header.dart';
import 'package:valuatorx/pages/common/view/view_tile.dart';
import 'package:valuatorx/providers/valuation_provider.dart';

class DetailsView extends StatelessWidget {
  final Valuation valuation;
  const DetailsView({super.key, required this.valuation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<ValuationProvider>(context);

    onEditAction() {
      provider.setSelectedItem(valuation.id);
      Navigator.pushNamed(context, '/valuation/edit');
    }

    onDeleteAction() async {
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

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      body: CustomScrollView(
        slivers: [
          TitleHeader(title: valuation.reportName, onBackPressed: onBackAction),
          ActionsHeader(
            actions: [
              ActionButton(icon: Icons.edit_outlined, label: "Edit", onPressed: onEditAction),
              ActionButton(icon: Icons.delete_outlined, label: "Delete", onPressed: onDeleteAction),
              ActionButton(icon: Icons.public_rounded, label: "Open in Maps", onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  ViewTile(title: "Latitude", value: valuation.latitude),
                  ViewTile(title: "Longitude", value: valuation.longitude),
                  ViewTile(title: "Land Rate (per cent)", value: valuation.reportName),
                  ViewTile(title: "Size of Land / Remarks", value: valuation.taluk),
                  ViewTile(title: "Type of Road", value: valuation.dateOfInspection),
                  ViewTile(title: "Date of Visit", value: valuation.taluk),
                  SizedBox(height: 600),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
