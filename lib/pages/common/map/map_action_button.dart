import 'package:flutter/material.dart';

class MapActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData icon;
  final double elevation;

  const MapActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.elevation = 2
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ElevatedButton(
      onPressed: !isLoading ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.surface,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        disabledBackgroundColor: colorScheme.surface,
        elevation: elevation
      ),
      child: isLoading
          ? SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 3,))
          : Icon(icon, color: colorScheme.onSurfaceVariant),
    );
  }
}