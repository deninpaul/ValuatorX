import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:valuatorx/modals/tab.dart';

class CreateButton extends StatelessWidget {
  final TabItem item;
  const CreateButton({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return (item.createPage != null)
        ? Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: OpenContainer(
            transitionType: ContainerTransitionType.fade,
            openBuilder: (context, _) => item.createPage ?? Center(),
            closedColor: colorScheme.primaryContainer,
            closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            closedElevation: 6,
            closedBuilder:
                (context, openContainer) => FloatingActionButton.extended(
                  onPressed: openContainer,
                  icon: const Icon(Icons.add),
                  elevation: 0,
                  label: Text("${item.createText}", style: textTheme.bodyMedium),
                ),
          ),
        )
        : SizedBox();
  }
}
