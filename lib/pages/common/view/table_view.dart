import 'dart:math';
import 'package:flutter/material.dart';
import 'package:valuatorx/pages/common/view/group_view.dart';
import 'package:valuatorx/pages/common/view/view_tile.dart';

final double minWidth = 160;

class TableViewTile extends StatelessWidget {
  final int minRows;
  final String title;
  final IconData icon;
  final int tabIndex;
  final List<List<String>> values;
  final List<List<String>> fieldNames;
  final Function({String fieldName, int fieldTab})? onPressed;

  const TableViewTile({
    super.key,
    required this.title,
    required this.icon,
    this.minRows = 2,
    this.tabIndex = 0,
    required this.values,
    required this.fieldNames,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final int rowsToDisplay = minRows == 0 ? values.length : max(values.length, minRows);

    return GroupViewWrapper(
      title: title,
      icon: icon,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final int columnCount = fieldNames[0].length;
            final double availableWidth = constraints.maxWidth - 12 - (16 * (columnCount - 1));
            final bool needsScrolling = columnCount * minWidth > availableWidth;

            return needsScrolling
                ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(children: _buildTableRows(rowsToDisplay, isScrollable: true)),
                )
                : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _buildTableRows(rowsToDisplay, isScrollable: false));
          },
        ),
      ],
    );
  }

  List<Widget> _buildTableRows(int rowsToDisplay, {required bool isScrollable}) {
    return List.generate(rowsToDisplay, (rowIndex) {
      if (values[rowIndex].every((field) => field.isEmpty) && (rowIndex + 1) > minRows) return SizedBox();

      return Row(
        spacing: 16,
        children: [
          ...List.generate(fieldNames[0].length, (colIndex) {
            final String displayValue = rowIndex < values.length ? values[rowIndex][colIndex] : "";
            final String labelText = fieldNames[rowIndex][colIndex];
            return isScrollable
                ? IntrinsicWidth(child: ViewTile(title: labelText, value: displayValue, onPressed: onPressed, tabIndex: tabIndex))
                : Expanded(child: ViewTile(title: labelText, value: displayValue, onPressed: onPressed, tabIndex: tabIndex));
          }),
        ],
      );
    });
  }
}
