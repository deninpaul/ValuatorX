import 'package:flutter/material.dart';

class DiscardDialog extends StatefulWidget {
  final Map<String, Function> actions;
  const DiscardDialog({super.key, this.actions = const {}});

  @override
  State<DiscardDialog> createState() => _DiscardDialogState();
}

class _DiscardDialogState extends State<DiscardDialog> {
  String loadingAction = "";

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text("Discard changes?"),
      content: Text("Your changes have not been saved", style: textTheme.bodyLarge),
      actions: [
        if (widget.actions.entries.length < 2) TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ...widget.actions.entries.map(
          (action) => TextButton(
            onPressed: () async {
              setState(() => loadingAction = action.key);
              await action.value();
              setState(() => loadingAction = "");
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: loadingAction != action.key ? Text(action.key) : Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
            ),
          ),
        ),
      ],
    );
  }
}
