import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final File image;
  final int index;
  final VoidCallback onDelete;

  const ImageViewer({super.key, required this.image, required this.index, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(48, 48, 48, 48),
      child: Hero(
        tag: "image_$index",
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: InteractiveViewer(
                    child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(image, fit: BoxFit.contain)),
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
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete image'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        backgroundColor: colorScheme.errorContainer,
                        foregroundColor: colorScheme.error,
                        textStyle: textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 40, child: VerticalDivider()),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
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
