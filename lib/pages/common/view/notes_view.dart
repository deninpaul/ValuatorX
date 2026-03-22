import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:valuatorx/utils/common.dart';

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
      final delta = mdToDelta.convert(value);
      doc = Document.fromDelta(delta);
    } catch (e) {
      doc = Document()..insert(0, value);
    }

    final controller = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0), readOnly: true);

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: Material(
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Positioned.fill(
                  child: InkWell(
                    onTap: () => onPressed?.call(fieldName: title, fieldTab: tabIndex),
                    splashColor: colorScheme.surfaceContainerHigh,
                    highlightColor: colorScheme.surfaceContainerHigh,
                    hoverColor: colorScheme.surfaceContainerLow,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: QuillEditor.basic(
                    controller: controller,
                    config: QuillEditorConfig(
                      showCursor: false,
                      placeholder: "No notes",
                      scrollable: false,
                      customStyles: DefaultStyles(
                        paragraph: DefaultTextBlockStyle(
                          textTheme.bodyLarge!,
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(8, 8),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        lists: DefaultListBlockStyle(
                          textTheme.bodyLarge!,
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(8, 8),
                          const VerticalSpacing(0, 0),
                          null,
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
