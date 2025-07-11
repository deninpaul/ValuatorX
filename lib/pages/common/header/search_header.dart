import 'package:flutter/material.dart';

class SearchHeader extends StatefulWidget {
  final ValueChanged<String>? onSearch;
  final String name;
  final List<PopupMenuItem> actions;
  final String query;
  const SearchHeader({super.key, this.onSearch, required this.name, required this.query, this.actions = const []});

  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.query;
    super.initState();
  }

  onClear() {
    widget.onSearch!("");
    controller.text = "";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: widget.query.isEmpty,
      onPopInvokedWithResult: (didPop, result) => onClear(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.onSearch != null)
            Expanded(
              child: SearchBar(
                controller: controller,
                onChanged: widget.onSearch,
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceBright),
                hintText: "Search in ${widget.name.toLowerCase()}s",
                leading: Padding(padding: const EdgeInsets.only(left: 8), child: Icon(Icons.search, color: theme.hintColor)),
                trailing: [if (controller.text.isNotEmpty) IconButton(onPressed: onClear, icon: Icon(Icons.close, color: theme.hintColor))],
              ),
            ),
          const SizedBox(width: 8),
          PopupMenuButton(offset: const Offset(0, 48), itemBuilder: (ctx) => [...widget.actions]),
        ],
      ),
    );
  }
}
