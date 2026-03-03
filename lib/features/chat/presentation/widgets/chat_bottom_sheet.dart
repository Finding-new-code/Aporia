import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';

class ChatBottomSheet extends StatelessWidget {
  const ChatBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundDarkGray, // Slightly lighter than background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        24,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Camera, Photos, Files
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTopOption(context, Icons.camera_alt_outlined, 'Camera'),
              _buildTopOption(context, Icons.image_outlined, 'Photos'),
              _buildTopOption(context, Icons.attach_file, 'Files'),
            ],
          ),
          const SizedBox(height: 24),

          // List Options
          _buildListOption(
            icon: Icons.all_inclusive,
            title: 'Model',
            subtitle: 'Aporia-X',
          ),
          _buildListOption(
            icon: Icons.brush_outlined,
            title: 'Create image',
            subtitle: 'Visualize anything',
          ),
          _buildListOption(
            icon: Icons.biotech,
            title: 'Deep research',
            subtitle: 'The research tool is a tool that allows you to per...',
          ),
          _buildListOption(
            icon: Icons.shopping_bag_outlined,
            title: 'Shopping research',
            subtitle: 'Get an in-depth guide',
          ),
        ],
      ),
    );
  }

  Widget _buildTopOption(BuildContext context, IconData icon, String label) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLightGray.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListOption({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textGray,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
