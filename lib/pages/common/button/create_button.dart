import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:valuatorx/utils/common.dart';

class CreateButton extends StatelessWidget {
  final Widget createPage;
  final String label;

  const CreateButton({super.key, required this.createPage, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile(context) ? 8 : 24),
      child: OpenContainer(
        transitionType: ContainerTransitionType.fade,
        openBuilder: (context, _) => createPage,
        closedColor: colorScheme.primaryContainer,
        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        closedElevation: 6,
        closedBuilder:
            (context, openContainer) => FloatingActionButton.extended(
              onPressed: openContainer,
              icon: const Icon(Icons.add, size: 16),
              elevation: 0,
              label: Text(label, style: TextStyle(fontWeight: FontWeight.normal),),
            ),
      ),
    );
  }
}
