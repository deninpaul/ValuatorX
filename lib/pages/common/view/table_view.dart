import 'dart:math';

import 'package:flutter/material.dart';
import 'package:valuatorx/pages/common/view/view_tile.dart';

class TableViewTile extends StatelessWidget {
  final int minRows;
  final String title;
  final IconData icon;
  final List<List<String>> values;
  final List<List<String>> fieldNames;

  const TableViewTile({
    super.key,
    required this.title,
    required this.icon,
    this.minRows = 0,
    required this.values,
    required this.fieldNames,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final int rowsToDisplay = minRows == 0 ? values.length : max(values.length, minRows);

    return Container(
      padding: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 0, 0),
            child: Row(spacing: 20, children: [Icon(icon), Text(title, style: textTheme.bodyLarge)]),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...List.generate(rowsToDisplay, (rowIndex) {
                if (values[rowIndex].every((field) => field.isEmpty) && (rowIndex + 1) > minRows) {
                  return SizedBox();
                }
                return Row(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 12),
                    ...List.generate(fieldNames[0].length, (colIndex) {
                      final String displayValue = rowIndex < values.length ? values[rowIndex][colIndex] : "";
                      final String labelText = fieldNames[rowIndex][colIndex];
                      return Expanded(child: ViewTile(title: labelText, value: displayValue));
                    }),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
