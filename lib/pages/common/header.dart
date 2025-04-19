import 'package:flutter/material.dart';
import 'package:valuatorx/modals/tab.dart';

class Header extends StatelessWidget {
  final TabItem item;
  final TextEditingController searchController;
  const Header({super.key, required this.item, required this.searchController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;
    final onMobile = size.width < 600;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!onMobile)
            Row(
              children: [
                const SizedBox(width: 12),
                Text(item.title, style: textTheme.bodyLarge?.copyWith(color: colorScheme.primary, fontSize: 18)),
              ],
            ),
          Spacer(),
          if (item.onSearch != null)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: !onMobile ? 256 : size.width - 160),
              child: SearchBar(
                controller: searchController,
                onSubmitted: item.onSearch,
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceBright),
                hintText: "Search",
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.search, color: theme.hintColor),
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
        ],
      ),
    );
  }
}
