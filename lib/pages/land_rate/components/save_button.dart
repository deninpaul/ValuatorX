import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/providers/land_rate_provider.dart';

class SaveButton extends StatelessWidget {
  final Function onSubmit;
  final GlobalKey<FormState> formKey;
  const SaveButton({super.key, required this.formKey, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<LandRateProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: TextButton(
        onPressed: () async {
          if (formKey.currentState!.validate() && !provider.isLoading) {
            await onSubmit();
            Navigator.of(context).pop();
          }
        },

        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
          backgroundColor: theme.colorScheme.primary,
        ),
        child:
            provider.isLoading
                ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 3),
                )
                : Text("Save", style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onPrimary)),
      ),
    );
  }
}
