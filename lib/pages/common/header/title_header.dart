import 'package:flutter/material.dart';

class TitleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;
  final double expandedHeight;
  final List<Widget> actions;
  final bool readOnly;

  const TitleHeader({super.key, required this.title, required this.onBackPressed, this.expandedHeight = 100, this.actions = const [], this.readOnly = false });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      backgroundColor: colorScheme.surfaceContainer,
      surfaceTintColor: colorScheme.surfaceContainer,
      scrolledUnderElevation: 0,
      leading: IconButton(onPressed: onBackPressed, icon: Icon(Icons.arrow_back_outlined), padding: EdgeInsets.zero),
      automaticallyImplyLeading: false,
      actions: !readOnly ? actions : null,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        expandedTitleScale: 1.175,
        title: Container(
          width: MediaQuery.of(context).size.width * (!readOnly ? 0.44 : 0.55),
          padding: const EdgeInsets.only(top: 15.0),
          alignment: Alignment.bottomCenter,
          child: Text(
            title,
            style: textTheme.bodyLarge,
            overflow: TextOverflow.fade,
            softWrap: false,
            textWidthBasis: TextWidthBasis.longestLine,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
