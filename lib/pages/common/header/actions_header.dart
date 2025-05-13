import 'package:flutter/material.dart';
import 'package:valuatorx/pages/common/action_button.dart';

class ActionsHeader extends StatelessWidget implements PreferredSizeWidget {
  final List<ActionButton> actions;
  final double expandedHeight;
  final double collapsedHeight;
  final bool pinned;

  const ActionsHeader({
    super.key,
    required this.actions,
    this.expandedHeight = 148,
    this.collapsedHeight = 56,
    this.pinned = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: pinned,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      clipBehavior: Clip.none,
      backgroundColor: colorScheme.surfaceContainer,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: actions,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
