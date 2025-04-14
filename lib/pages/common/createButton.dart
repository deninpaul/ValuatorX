import 'package:flutter/material.dart';
import 'package:valuatorx/modals/tab.dart';

class CreateButton extends StatelessWidget {
  final TabItem item;
  const CreateButton({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return (item.onCreate != null && item.createText != null)
        ? Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 24),
          child: FloatingActionButton.extended(
            onPressed: item.onCreate,
            icon: const Icon(Icons.add),
            label: Text("${item.createText}", style: textTheme.bodyLarge),
          ),
        )
        : SizedBox();
  }
}
