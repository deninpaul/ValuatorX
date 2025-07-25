import 'package:flutter/material.dart';

class FilterPill extends StatelessWidget {
  final String text;
  final String selectedText;
  final Function(String) onSelected;
  const FilterPill({super.key, required this.text, this.selectedText = "", required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      selected: selectedText == text,
      showCheckmark: false,
      label: Text(text, style: TextStyle(fontWeight: FontWeight.normal),),
      onSelected: (bool val) {
        if (val == true) {
          onSelected(text);
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      selectedColor: colorScheme.primaryContainer,
    );
  }
}
