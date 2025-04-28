import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/providers/land_rate_provider.dart';

class SaveButton extends StatelessWidget {
  final Function onSubmit;
  final GlobalKey<FormState> formKey;
  final bool enabled;
  const SaveButton({super.key, required this.formKey, required this.onSubmit, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<LandRateProvider>(context, listen: true);

    return TextButton(
      onPressed: enabled ? () async {
        if (formKey.currentState!.validate() && !provider.isCreating) {
          await onSubmit();
          Navigator.of(context).pop();
        }
      } : null,
      style:
       TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        backgroundColor: theme.colorScheme.primary,
        disabledBackgroundColor: theme.disabledColor
      ),
      child:
          provider.isCreating
              ? Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 3),
              )
              : Text("Save", style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onPrimary)),
    );
  }
}
