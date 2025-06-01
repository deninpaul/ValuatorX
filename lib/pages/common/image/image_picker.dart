import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:valuatorx/pages/common/image/image_editor.dart';
import 'package:valuatorx/pages/common/image/image_viewer.dart';
import 'dart:io';

class ImagePickerField extends StatefulWidget {
  const ImagePickerField({super.key});

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  final List<File> _images = [];
  final ImagePicker picker = ImagePicker();

  pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await picker.pickImage(source: source, maxWidth: 1800, maxHeight: 1800, imageQuality: 85);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final result = await Navigator.of(context).push<File>(MaterialPageRoute(builder: (context) => LocationDetailsScreen(file: file)));
        if (result != null) {
          setState(() => _images.add(result));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  onDeleteAction(int index) async {
    final confirmed = await showDialog<bool>(context: context, barrierDismissible: true, builder: (context) => const ConfirmDeleteDialog());
    if (confirmed == true) {
      setState(() => _images.removeAt(index));
      Navigator.of(context).pop();
    }
  }

  void showFullImage(File image, int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Image Preview",
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ImageViewer(image: image, index: index, onDelete: () => onDeleteAction(index));
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: CurvedAnimation(parent: animation, curve: Curves.easeInOut), child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      spacing: 16,
      children: [
        Row(
          spacing: 16,
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take photo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  textStyle: textTheme.bodyMedium,
                ),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: () => pickImage(ImageSource.gallery),
                icon: const Icon(Icons.folder_outlined),
                label: const Text('Import from gallery'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  textStyle: textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            margin: EdgeInsets.only(top: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: colorScheme.surface),
            child:
                _images.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_size_select_actual_outlined, size: 48, color: theme.disabledColor),
                          const SizedBox(height: 16),
                          Text(
                            'No images selected\nTap the button above to add images',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge!.copyWith(color: theme.disabledColor),
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () => showFullImage(_images[index], index),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Hero(tag: "image_$index", child: Image.file(_images[index], fit: BoxFit.cover)),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  onPressed: () => showFullImage(_images[index], index),
                                  icon: const Icon(Icons.open_in_full_outlined, size: 20),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(theme.splashColor),
                                    foregroundColor: WidgetStateProperty.all(colorScheme.onError),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ),
      ],
    );
  }
}

class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Delete Image'),
      content: const Text('Are you sure you want to delete this image?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
