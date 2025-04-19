import 'package:flutter/material.dart';
import 'package:valuatorx/modals/land_rate.dart';

class SummaryTile extends StatelessWidget {
  final LandRate landRate;
  final bool showDivider;
  const SummaryTile({super.key, required this.landRate, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final labelColor = colorScheme.onSurface.withAlpha(160);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text("${landRate.latitude} ${landRate.longitude}", style: textTheme.bodyLarge!.copyWith(color: colorScheme.onSurfaceVariant)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("${landRate.landRatePerCent}/cent", style: textTheme.bodyLarge!.copyWith(color: labelColor)),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${landRate.monthOfVisit} ${landRate.yearOfVisit}", style: textTheme.bodyMedium!.copyWith(color: labelColor)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: colorScheme.onSurface.withAlpha(24)),
                  child: Center(child: Text("No.: ${landRate.slNo}", style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurface))),
                ),
              ],
            ),
          ],
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }
}
