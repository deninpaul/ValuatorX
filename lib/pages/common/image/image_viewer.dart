import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:valuatorx/utils/common.dart';

class ImageViewer extends StatelessWidget {
  final String image;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onOpen;
  final bool editable;

  const ImageViewer({
    super.key,
    required this.image,
    required this.index,
    required this.onDelete,
    required this.onOpen,
    this.editable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      alignment: Alignment.center,
      padding: isMobile(context) ? EdgeInsets.fromLTRB(16, 48, 16, 48) : EdgeInsets.fromLTRB(48, 48, 48, 48),
      child: Hero(
        tag: "image_$index",
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: Container(color: Colors.transparent)),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 64),
                  child: InteractiveViewer(
                    child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(image, fit: BoxFit.contain)),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  spacing: 16,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (editable)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete image'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: kIsWeb ? 24 : 16, horizontal: 32),
                          backgroundColor: colorScheme.errorContainer,
                          foregroundColor: colorScheme.error,
                          textStyle: textTheme.bodyMedium,
                        ),
                      ),
                    if (!editable)
                      TextButton.icon(
                        onPressed: onOpen,
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open image'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: kIsWeb ? 24 : 16, horizontal: 32),
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                          textStyle: textTheme.bodyMedium,
                        ),
                      ),
                    const SizedBox(height: 40, child: VerticalDivider()),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: kIsWeb ? 24 : 16, horizontal: 32),
                        backgroundColor: colorScheme.surface,
                        foregroundColor: colorScheme.onSurface,
                        textStyle: textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
