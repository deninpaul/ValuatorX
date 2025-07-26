import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valuatorx/models/land_rate.dart';
import 'package:valuatorx/pages/common/button/action_button.dart';
import 'package:valuatorx/pages/common/field/tag.dart';
import 'package:valuatorx/pages/common/modal/delete_dialog.dart';
import 'package:valuatorx/pages/common/header/actions_header.dart';
import 'package:valuatorx/pages/common/header/title_header.dart';
import 'package:valuatorx/pages/common/view/location_view.dart';
import 'package:valuatorx/pages/common/view/view_tile.dart';
import 'package:valuatorx/pages/land_rate/land_rate_form.dart';
import 'package:valuatorx/providers/land_rate_provider.dart';
import 'package:valuatorx/utils/common.dart';

class LandRateDetails extends StatelessWidget {
  final LandRate landRate;
  const LandRateDetails({super.key, required this.landRate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<LandRateProvider>(context);
    final MapController mapController = MapController();

    onEditAction({String fieldName = "", int fieldTab = 0}) {
      provider.setSelectedItem(landRate.id.toString(), landRate.author);
      Navigator.push(context, MaterialPageRoute(builder: (context) => LandRateForm(editMode: true, focusField: fieldName)));
    }

    onDeleteAction() async {
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
        provider.setSelectedItem("", "");
      }
    }

    onBackAction() {
      Future.microtask(() {
        provider.setSelectedItem("", "");
      });
    }

    onOpenMapAction() async {
      final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${landRate.latitude},${landRate.longitude}');
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch Google Maps')));
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackAction(),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainer,
        body: CustomScrollView(
          slivers: [
            TitleHeader(
              title: landRate.slNo,
              onBackPressed: onBackAction,
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 11),
                  child: Tag(
                    text: formatCamelCase(landRate.author),
                    color: LandRate.getMapColors(colorScheme, landRate.author).clusterFill,
                  ),
                ),
              ],
            ),
            ActionsHeader(
              actions: [
                ActionButton(icon: Icons.edit_outlined, label: "Edit", onPressed: onEditAction),
                ActionButton(icon: Icons.delete_outlined, label: "Delete", onPressed: onDeleteAction),
                ActionButton(icon: Icons.public_rounded, label: "Open in Maps", onPressed: onOpenMapAction),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: isDesktop(context) ? 200 : 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 13,
                  children: [
                    LocationViewTile(
                      mapController: mapController,
                      latitude: landRate.latitude,
                      longitude: landRate.longitude,
                      onPressed: onEditAction,
                      label: landRate.slNo,
                      markerColor: LandRate.getMapColors(colorScheme, landRate.author).markerFill,
                    ),
                    ViewTile(
                      title: LandRate.LAND_RATE_PER_CENT,
                      value: landRate.landRatePerCent,
                      icon: Icons.paid_outlined,
                      onPressed: onEditAction,
                    ),
                    ViewTile(
                      title: LandRate.LAND_SIZE_REMARKS,
                      value: landRate.landSizeRemarks,
                      icon: Icons.straighten_outlined,
                      onPressed: onEditAction,
                    ),
                    ViewTile(title: LandRate.LAND_TYPE, value: landRate.landType, icon: Icons.landscape_outlined, onPressed: onEditAction),
                    ViewTile(title: LandRate.ROAD, value: landRate.road, icon: Icons.traffic_outlined, onPressed: onEditAction),
                    ViewTile(
                      title: "Date of Visit",
                      value: "${landRate.monthOfVisit} ${landRate.yearOfVisit}",
                      icon: Icons.calendar_today_outlined,
                      onPressed: onEditAction,
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
