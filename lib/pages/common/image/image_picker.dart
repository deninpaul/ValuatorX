import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valuatorx/pages/common/image/image_editor.dart';
import 'package:valuatorx/pages/common/image/image_viewer.dart';
import 'package:valuatorx/providers/media_provider.dart';
import 'dart:io';
import 'package:valuatorx/utils/common.dart';

class ImagePickerField extends StatefulWidget {
  final bool editMode;
  final bool readOnly;
  final String? value;
  final VoidCallback? onEditAction;
  final TextEditingController? controller;
  const ImagePickerField({super.key, required this.editMode, this.controller, this.value, this.onEditAction, this.readOnly = false});

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> with AutomaticKeepAliveClientMixin {
  final ImagePicker picker = ImagePicker();
  late final TextEditingController controller;
  bool get editMode => widget.editMode;
  List<String> imageUrls = [];
  bool ready = false;

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await picker.pickImage(source: source, maxWidth: 1080, maxHeight: 1080, imageQuality: 80, requestFullMetadata: false);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileBytes = await pickedFile.readAsBytes();
        if (!mounted) return;
        final result = await Navigator.of(
          context,
        ).push<String>(MaterialPageRoute(builder: (context) => LocationDetailsScreen(file: file, fileBytes: fileBytes)));
        if (!mounted) return;
        if (result != null) {
          setState(() => ready = false);
          setState(() => widget.controller!.text += ",$result,");
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> onDeleteAction(int index) async {
    final confirmed = await showDialog<bool>(context: context, barrierDismissible: true, builder: (context) => const ConfirmDeleteDialog());
    if (confirmed == true) {
      final ids = parseStringtoArray(widget.controller!.text);
      widget.controller!.text = (ids..removeAt(index)).join(",");
      Navigator.of(context).pop();
    }
  }

  Future<void> onOpenAction(int index) async {
    final ids = parseStringtoArray(widget.value ?? "");
    final id = ids.removeAt(index);
    final provider = Provider.of<MediaProvider>(context, listen: false);
    final url = await provider.openImageUrl(context, id);
    if (!await launchUrl(Uri.parse(url))) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open image')));
    }
  }

  void showFullImage(String imageUrl, int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Image Preview",
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ImageViewer(
          image: imageUrl,
          index: index,
          editable: editMode,
          onDelete: () => onDeleteAction(index),
          onOpen: () => onOpenAction(index),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: CurvedAnimation(parent: animation, curve: Curves.easeInOut), child: child),
        );
      },
    );
  }

  List<String> parseStringtoArray(String string) {
    return string.split(',').where((s) => s.isNotEmpty).toList();
  }

  Future<void> getImages() async {
    setState(() => ready = false);
    final value = editMode ? widget.controller!.text : (widget.value ?? "");
    final ids = parseStringtoArray(value);

    if (ids.isEmpty) {
      setState(() {
        imageUrls = [];
        ready = true;
      });
      return;
    }

    final provider = Provider.of<MediaProvider>(context, listen: false);
    final result = await provider.getImages(context, ids);
    setState(() {
      imageUrls = result;
      ready = true;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getImages();
    if (editMode) {
      widget.controller!.addListener(getImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (editMode)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop(context) ? 200 : 0),
            child: Row(
              spacing: 16,
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Take photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: kIsWeb ? 20 : 16),
                      backgroundColor: colorScheme.secondaryContainer,
                      foregroundColor: colorScheme.onSecondaryContainer,
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
                      padding: const EdgeInsets.symmetric(vertical: kIsWeb ? 20 : 16),
                      backgroundColor: colorScheme.surfaceContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      textStyle: textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Container(
            padding:
                !editMode
                    ? EdgeInsets.symmetric(vertical: 16, horizontal: isDesktop(context) ? 64 : 16)
                    : EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), color: colorScheme.surface),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!editMode) TextButton(onPressed: !widget.readOnly ? widget.onEditAction : null, child: const Text('Edit images')),
                Expanded(
                  child:
                      ready
                          ? imageUrls.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_size_select_actual_outlined, size: 48, color: theme.disabledColor),
                                    const SizedBox(height: 15),
                                    Text(
                                      'No images selected\nTap the button above to add images',
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodyLarge!.copyWith(color: theme.disabledColor),
                                    ),
                                  ],
                                ),
                              )
                              : GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop(context) ? 4 : (isMobile(context) ? 2 : 3),
                                  crossAxisSpacing: 11,
                                  mainAxisSpacing: 11,
                                  childAspectRatio: 1,
                                ),
                                itemCount: imageUrls.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    clipBehavior: Clip.hardEdge,
                                    elevation: 0,
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () => showFullImage(imageUrls[index], index),
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: double.infinity,
                                            child: Hero(
                                              tag: "image_$index",
                                              child: Image.network(
                                                imageUrls[index],
                                                fit: BoxFit.cover,
                                                loadingBuilder:
                                                    (context, child, loadingProgress) =>
                                                        loadingProgress != null
                                                            ? Shimmer.fromColors(
                                                              baseColor: colorScheme.surfaceContainerHigh,
                                                              highlightColor: colorScheme.surfaceContainer,
                                                              child: Container(color: colorScheme.surfaceContainer),
                                                            )
                                                            : child,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: IconButton(
                                            onPressed: () => showFullImage(imageUrls[index], index),
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
                              )
                          : Center(child: CircularProgressIndicator()),
                ),
              ],
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
