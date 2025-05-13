import 'package:flutter/material.dart';

class TitleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;
  final double expandedHeight;

  const TitleHeader({super.key, required this.title, required this.onBackPressed, this.expandedHeight = 96});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      backgroundColor: colorScheme.surfaceContainer,
      shadowColor: colorScheme.surfaceContainer,
      surfaceTintColor: colorScheme.surfaceContainer,
      scrolledUnderElevation: 0,
      leading: IconButton(onPressed: onBackPressed, icon: Icon(Icons.arrow_back_outlined)),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        expandedTitleScale: 1.35,
        title: Container(
          width: MediaQuery.of(context).size.width * 0.35,
          padding: const EdgeInsets.only(top: 16.0),
          alignment: Alignment.bottomCenter,
          child: Text(
            title,
            style: textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
            textWidthBasis: TextWidthBasis.longestLine,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
