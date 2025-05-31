import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

class NotesViewer extends StatelessWidget {
  final String title;
  final String value;
  final Function({String fieldName, int fieldTab})? onPressed;
  final int tabIndex;

  const NotesViewer({super.key, required this.title, required this.value, this.tabIndex = 0, this.onPressed});

  @override
  Widget build(BuildContext context) {
    Document doc;
    try {
      final json = jsonDecode(value);
      doc = Document.fromJson(json);
    } catch (e) {
      doc = Document()..insert(0, value);
    }
    final QuillController controller = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0), readOnly: true);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => onPressed != null ? onPressed!(fieldName: title, fieldTab: tabIndex) : () {},
        splashColor: colorScheme.surfaceContainerHigh,
        highlightColor: colorScheme.surfaceContainerHigh,
        child: IgnorePointer(
          child: QuillEditor.basic(
            controller: controller,
            config: QuillEditorConfig(
              placeholder: "No notes",
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              scrollable: false,
              customStyles: DefaultStyles(
                paragraph: DefaultTextBlockStyle(
                  textTheme.bodyLarge!,
                  const HorizontalSpacing(0, 0),
                  const VerticalSpacing(8, 8), // More space between paragraphs
                  const VerticalSpacing(0, 0),
                  null,
                ),
                placeHolder: DefaultTextBlockStyle(
                  textTheme.bodyLarge!.copyWith(color: colorScheme.outline),
                  HorizontalSpacing.zero,
                  VerticalSpacing.zero,
                  VerticalSpacing.zero,
                  null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
