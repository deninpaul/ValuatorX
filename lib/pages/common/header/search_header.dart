import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget {
  final ValueChanged<String>? onSearch;
  final String name;
  final List<PopupMenuItem> actions;
  const SearchHeader({super.key, this.onSearch, required this.name, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onSearch != null)
          Expanded(
            child: SearchBar(
              onChanged: onSearch,
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceBright),
              hintText: "Search in ${name.toLowerCase()}s",
              leading: Padding(padding: const EdgeInsets.only(left: 8), child: Icon(Icons.search, color: theme.hintColor)),
            ),
          ),
        const SizedBox(width: 8),
        PopupMenuButton(offset: const Offset(0, 48), itemBuilder: (ctx) => [...actions]),
      ],
    );
  }
}
