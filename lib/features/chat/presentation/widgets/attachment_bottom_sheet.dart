import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';

class AttachmentBottomSheet extends StatelessWidget {
  const AttachmentBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundBlack,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          _buildActionItem(Icons.image_outlined, 'Photos'),
          _buildActionItem(Icons.camera_alt_outlined, 'Camera'),
          _buildActionItem(Icons.attach_file, 'Files'),
          _buildActionItem(Icons.language, 'Web search'),
          _buildActionItem(Icons.menu_book_outlined, 'Study and learn'),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title) {
    return InkWell(
      onTap: () {}, // Handle action tap
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
