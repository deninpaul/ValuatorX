import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/models/valuation.dart';
import 'package:valuatorx/pages/common/status_icon.dart';
import 'package:valuatorx/providers/valuation_provider.dart';

class GenerateDialog extends StatefulWidget {
  final Valuation valuation;
  const GenerateDialog({super.key, required this.valuation});

  @override
  State<GenerateDialog> createState() => _GenerateDialogState();
}

class _GenerateDialogState extends State<GenerateDialog> {
  String message = "Generating";
  Status status = Status.loading;

  onUpdateLoadingMessage(String newMessage, {Status newStatus = Status.loading}) {
    setState(() {
      status = newStatus;
      message = newMessage;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ValuationProvider>(context, listen: false);
      await provider.generateReport(context, widget.valuation, onUpdateLoadingMessage);
      if (status == Status.success) {
        await Future.delayed(Duration(seconds: 1, milliseconds: 200));
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text("Generating Report")),
              if (status != Status.loading) IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
          child: Row(
            spacing: 32,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  status == Status.loading ? "$message..." : message,
                  style: textTheme.bodyLarge!.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
              SizedBox(width: 32, height: 32, child: StatusIcon(status: status)),
            ],
          ),
        ),
      ),
    );
  }
}
