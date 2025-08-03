import 'package:flutter/material.dart';
import 'package:valuatorx/utils/common.dart';

class TableField extends StatefulWidget {
  final int minRows;
  final String title;
  final IconData icon;
  final TextInputType keyboardType;
  final List<List<TextEditingController>> controllers;
  final List<List<String>> fieldNames;
  final String focusField;
  const TableField({
    super.key,
    required this.title,
    required this.icon,
    this.minRows = 1,
    this.keyboardType = TextInputType.text,
    this.focusField = "",
    required this.controllers,
    required this.fieldNames,
  });

  @override
  State<TableField> createState() => _TableFieldState();
}

class _TableFieldState extends State<TableField> {
  List<Map<String, String>> rows = [];
  int get maxRows => widget.controllers.length;

  @override
  void initState() {
    super.initState();
    updateRowsBasedOnData();
  }

  void updateRowsBasedOnData() {
    int requiredRows = widget.controllers.where((x) => x.where((y) => y.text.isNotEmpty).isNotEmpty).length;
    if (requiredRows < widget.minRows) {
      requiredRows = widget.minRows;
    }
    setState(() => rows = [for (int i = 0; i < requiredRows; i++) {}]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final widgetWidth = MediaQuery.of(context).size.width - (isMobile(context) ? 40 : isDesktop(context) ? 480 : 96);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(spacing: 24, children: [Icon(widget.icon), Text(widget.title, style: textTheme.bodyLarge)]),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: widgetWidth),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...rows.asMap().entries.map((entry) {
                    final rowIndex = entry.key;
                    if (rowIndex >= widget.controllers.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          removeIcon(rowIndex, theme),
                          ...List.generate(widget.controllers[rowIndex].length, (colIndex) {
                            final labelText = widget.fieldNames[rowIndex][colIndex];
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: 200),
                                  child: TextFormField(
                                    controller: widget.controllers[rowIndex][colIndex],
                                    keyboardType: widget.keyboardType,
                                    autofocus: labelText == widget.focusField,
                                    onChanged: (value) => setState(() {}),
                                    decoration: InputDecoration(border: const OutlineInputBorder(), labelText: labelText),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        if (rows.length < maxRows)
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => rows.add({})),
                icon: const Icon(Icons.add),
                label: Text("Add row", style: textTheme.bodyLarge!.copyWith(color: theme.primaryColor)),
              ),
            ),
          ),
      ],
    );
  }

  Widget removeIcon(int index, ThemeData theme) => SizedBox(
    width: 36,
    child:
        (index < widget.minRows)
            ? const SizedBox()
            : IconButton(
              visualDensity: const VisualDensity(horizontal: -2),
              icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.secondary),
              onPressed: () => setState(() => rows.removeAt(index)),
            ),
  );
}
