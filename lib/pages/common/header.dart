import 'package:flutter/material.dart';
import 'package:valuatorx/modals/tab.dart';

class Header extends StatelessWidget {
  final TabItem item;
  final TextEditingController searchController;
  const Header({super.key, required this.item, required this.searchController});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item.title, style: textTheme.titleLarge?.copyWith(color: colorScheme.primary)),
          const SizedBox(width: 80),
          Row(
            children: [
              item.onSearch != null
                  ? SizedBox(
                    width: size.width * 0.45,
                    child: SearchBar(
                      controller: searchController,
                      onSubmitted: item.onSearch,
                      elevation: WidgetStatePropertyAll(0),
                      backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceBright),
                      hintText: "Search ${item.name.toLowerCase()}",
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(Icons.search, color: theme.hintColor),
                      ),
                    ),
                  )
                  : Center(),

              const SizedBox(width: 8),
              IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_rounded)),
            ],
          ),
        ],
      ),
    );
  }
}
