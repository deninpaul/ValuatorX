import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final Function onSubmit;
  final GlobalKey<FormState> formKey;
  final bool enabled;
  final bool creating;
  const SaveButton({super.key, required this.formKey, required this.onSubmit, this.enabled = true, this.creating = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed:
          enabled
              ? () async {
                if (formKey.currentState!.validate() && !creating) {
                  await onSubmit();
                  Navigator.of(context).pop();
                }
              }
              : null,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: kIsWeb ? 12 : 0),
        backgroundColor: theme.colorScheme.primary,
        disabledBackgroundColor: theme.disabledColor,
      ),
      child:
          creating
              ? Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                width: 16,
                height: 16,
                child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 3),
              )
              : Text("Save", style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onPrimary)),
    );
  }
}
