import 'package:flutter/material.dart';
import 'package:valuatorx/utils/common.dart';

class DropdownField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> options;
  final IconData? icon;
  final String name;
  final bool required;
  final bool isChild;
  final String focusField;
  final bool allowCustomValues;
  final bool enabled;
  final void Function(String) onComplete;

  const DropdownField({
    super.key,
    required this.name,
    required this.controller,
    required this.options,
    this.icon,
    this.required = false,
    this.isChild = false,
    this.focusField = "",
    this.enabled = true,
    this.allowCustomValues = true,
    this.onComplete = _defaultOnComplete
  });

  static void _defaultOnComplete(String val) {}

  @override
  State<DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  late List<String> _allOptions;

  @override
  void initState() {
    super.initState();
    _allOptions = [...widget.options, if (widget.allowCustomValues) "Other (Custom)"];
  }

  void showCustomInputDialog() {
    showDialog(
      context: context,
      builder:
          (context) => CustomOptionDialog(
            label: widget.name,
            onSubmit: (value) {
              widget.controller.text = value;
              setState(() {});
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    bool isCustomValue = widget.controller.text.isNotEmpty && !widget.options.contains(widget.controller.text);

    return Row(
      spacing: 24,
      children: [
        if (widget.isChild) const SizedBox(width: 20),
        if (widget.icon != null) Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Icon(widget.icon)),
        Expanded(
          child: DropdownButtonFormField<String>(
            autofocus: widget.name == widget.focusField,
            value: isCustomValue ? "Other (Custom)" : (widget.controller.text.isEmpty ? null : widget.controller.text),
            items:
                _allOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        option == "Other (Custom)" && isCustomValue ? "Other: ${widget.controller.text}" : formatCamelCase(option),
                        style: textTheme.bodyLarge!.copyWith(height: 1.3, color: widget.enabled ? theme.colorScheme.onSurface : theme.disabledColor),
                      ),
                    ),
                  );
                }).toList(),
            onChanged: widget.enabled ? (newValue) {
              if (newValue == "Other (Custom)") {
                showCustomInputDialog();
              } else if (newValue != null) {
                widget.controller.text = newValue;
                widget.onComplete(newValue);
                setState(() {});
              }
            } : null,
            decoration: InputDecoration(labelText: widget.name, border: const OutlineInputBorder()),
            validator: (v) => widget.required && (widget.controller.text.isEmpty) ? 'Required' : null,
            isExpanded: true,
          ),
        ),
      ],
    );
  }
}

class CustomOptionDialog extends StatefulWidget {
  final String label;
  final void Function(String) onSubmit;
  const CustomOptionDialog({super.key, required this.label, required this.onSubmit});

  @override
  State<CustomOptionDialog> createState() => _CustomOptionDialogState();
}

class _CustomOptionDialogState extends State<CustomOptionDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter custom option'),
      content: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: SizedBox(
          width: 320,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: widget.label, border: const OutlineInputBorder()),
            autofocus: true,
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSubmit(_controller.text);
            }
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
