import 'package:flutter/material.dart';

class MapActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData icon;

  const MapActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ElevatedButton(
      onPressed: !isLoading ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.surface,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        disabledBackgroundColor: colorScheme.surface,
      ),
      child: isLoading
          ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
          : Icon(icon, color: colorScheme.onSurfaceVariant, size: 24),
    );
  }
}