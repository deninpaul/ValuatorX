import 'package:flutter/material.dart';
import 'package:valuatorx/models/valuation.dart';

class Tag extends StatefulWidget {
  final String text;
  final bool isLoading;
  final bool isEditable;
  final bool disabled;
  final Function(String) onStatusChange;

  const Tag({
    super.key,
    required this.text,
    this.onStatusChange = _defaultOnStatusChange,
    this.isEditable = false,
    this.isLoading = false,
    this.disabled = false,
  });
  static _defaultOnStatusChange(String s) {}

  @override
  State<Tag> createState() => _TagState();
}

class _TagState extends State<Tag> {
  static const statusOptions = Valuation.statusOptions;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    Color tagColor() {
      switch (widget.text) {
        case "Backlog":
        case "In progress":
          return colorScheme.secondaryContainer;
        case "Draft":
          return colorScheme.tertiaryContainer;
        default:
          return widget.isEditable ? colorScheme.surface : colorScheme.surfaceContainer;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), color: tagColor()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isEditable)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child:
                  !widget.isLoading
                      ? DropdownButtonHideUnderline(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: 80),
                          child: DropdownButton<String>(
                            value: widget.text,
                            dropdownColor: colorScheme.surface,
                            style: textTheme.bodyMedium,
                            icon: Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.expand_more, size: 21)),
                            elevation: 0,
                            padding: EdgeInsets.only(left: 4),
                            isDense: true,
                            onChanged: (newStatus) {
                              if (newStatus != null && newStatus != widget.text) {
                                widget.onStatusChange(newStatus);
                              }
                            },
                            items:
                                {if (!widget.disabled) ...statusOptions, widget.text}.map((status) {
                                  return DropdownMenuItem<String>(value: status, child: Text(status));
                                }).toList(),
                          ),
                        ),
                      )
                      : Container(
                        width: 15,
                        height: 15,
                        margin: EdgeInsets.symmetric(horizontal: 47, vertical: 2),
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
            )
          else
            Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0), child: Text(widget.text, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
