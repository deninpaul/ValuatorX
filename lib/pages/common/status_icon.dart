import 'package:flutter/material.dart';

enum Status { error, success, loading }

class StatusIcon extends StatelessWidget {
  final Status status;
  const StatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case Status.success:
        return SizedBox(
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
            child: Icon(Icons.check, size: 20, color: colorScheme.onPrimary),
          ),
        );
      case Status.error:
        return SizedBox(
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(color: colorScheme.error, shape: BoxShape.circle),
            child: Icon(Icons.close, size: 20, color: colorScheme.onError),
          ),
        );
      case Status.loading:
        return Padding(padding: EdgeInsets.all(4), child: CircularProgressIndicator());
    }
  }
}
