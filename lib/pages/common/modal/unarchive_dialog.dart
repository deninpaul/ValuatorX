import 'package:flutter/material.dart';

class UnArchiveDialog extends StatefulWidget {
  final Function onUnarchive;

  const UnArchiveDialog({super.key, required this.onUnarchive});

  @override
  State<UnArchiveDialog> createState() => _UnArchiveDialogState();
}

class _UnArchiveDialogState extends State<UnArchiveDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      title: const Text('Unarchive Valuation'),
      content: const Text('Are you sure you want to unarchive this valuation?'),
      actions: [
        TextButton(onPressed: _loading ? null : () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            backgroundColor: colorScheme.primary,
            disabledBackgroundColor: theme.disabledColor,
          ),
          onPressed:
              _loading
                  ? null
                  : () async {
                    setState(() => _loading = true);
                    await widget.onUnarchive();
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
          child:
              _loading
                  ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2.5),
                  )
                  : Text('Unarchive', style: textTheme.bodyMedium!.copyWith(color: colorScheme.onPrimary)),
        ),
      ],
    );
  }
}
