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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          "${landRate.latitude} ${landRate.longitude}",
          style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w300),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "${landRate.monthOfVisit} ${landRate.yearOfVisit}",
            style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w300),
          ),
        ),
        leading: Text("${landRate.slNo}.", style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w300)),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        
          children: [
            Text(landRate.landRatePerCent, style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w300)),
            Text("/cent", style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w300)),
          ],
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }
}
