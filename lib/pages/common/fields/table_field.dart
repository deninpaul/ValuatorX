import 'package:flutter/material.dart';

class TableField extends StatefulWidget {
  final int minRows;
  final String title;
  final TextInputType keyboardType;
  final List<List<TextEditingController>> controllers;
  final List<List<String>> fieldNames;
  const TableField({super.key, required this.title, this.minRows = 1, this.keyboardType = TextInputType.text ,required this.controllers, required this.fieldNames});

  @override
  State<TableField> createState() => _TableFieldState();
}

class _TableFieldState extends State<TableField> {
  List<Map<String, String>> rows = [];
  int maxRows = 4;

  @override
  void initState() {
    super.initState();
    rows = [for (int i = 0; i < widget.minRows; i++) {}];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final widgetWidth = MediaQuery.of(context).size.width - 96;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 24,
          children: [
            const Icon(Icons.aspect_ratio_outlined),
            Text(widget.title, style: textTheme.bodyLarge!.copyWith(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          removeIcon(rowIndex),
                          ...List.generate(widget.controllers[rowIndex].length, (colIndex) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(minWidth: 150),
                                  child: TextFormField(
                                    controller: widget.controllers[rowIndex][colIndex],
                                    keyboardType: widget.keyboardType,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: widget.fieldNames[rowIndex][colIndex],
                                    ),
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
            padding: const EdgeInsets.only(left: 32),
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

  removeIcon(index) => SizedBox(
    width: 40,
    child:
        (index < widget.minRows)
            ? const SizedBox()
            : IconButton(
              visualDensity: const VisualDensity(horizontal: -2),
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => setState(() => rows.removeAt(index)),
            ),
  );
}
