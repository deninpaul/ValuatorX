import 'package:flutter/material.dart';

class DeleteDialog extends StatefulWidget {
  final Function onDelete;
  const DeleteDialog({super.key, required this.onDelete});

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isMatching = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text('Confirm Deletion'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: const EdgeInsets.only(right: 64.0), child: Text('Type DELETE to confirm deletion')),
          SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(border: OutlineInputBorder()),
            onChanged: (value) {
              setState(() {
                _isMatching = value.trim() == "DELETE";
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel')),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            backgroundColor: colorScheme.primary,
          ),
          onPressed: () async {
            if (_isMatching) {
              setState(() => _loading = true);
              await widget.onDelete();
              Navigator.of(context).pop(true);
            }
          },
          child:
              _loading
                  ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2.5),
                  )
                  : Text("Delete", style: textTheme.bodyMedium!.copyWith(color: colorScheme.onPrimary)),
        ),
      ],
    );
  }
}
