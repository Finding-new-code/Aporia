import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:aporia/features/chat/presentation/dataflows/chat_dataflow.dart';

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
              _buildTopOption(
                context,
                Icons.camera_alt_outlined,
                'Camera',
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null && context.mounted) {
                    AddAttachmentAction(
                      Attachment(
                        name: image.name,
                        path: image.path,
                        type: 'camera',
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
              _buildTopOption(
                context,
                Icons.image_outlined,
                'Photos',
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null && context.mounted) {
                    AddAttachmentAction(
                      Attachment(
                        name: image.name,
                        path: image.path,
                        type: 'image',
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
              _buildTopOption(
                context,
                Icons.attach_file,
                'Files',
                onTap: () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles();
                  if (result != null && context.mounted) {
                    final platformFile = result.files.first;
                    AddAttachmentAction(
                      Attachment(
                        name: platformFile.name,
                        path: platformFile.path ?? '',
                        type: 'file',
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // List Options
          _buildListOption(
            icon: Icons.all_inclusive,
            title: 'Model',
            subtitle: 'Aporia-X',
          ),
          // _buildListOption(
          //   icon: Icons.brush_outlined,
          //   title: 'Create image',
          //   subtitle: 'Visualize anything',
          // ),
          _buildListOption(
            icon: Icons.biotech,
            title: 'Deep research',
            subtitle: 'The research tool is a tool that allows you to per...',
          ),
          // _buildListOption(
          //   icon: Icons.shopping_bag_outlined,
          //   title: 'Shopping research',
          //   subtitle: 'Get an in-depth guide',
          // ),
        ],
      ),
    );
  }

  Widget _buildTopOption(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLightGray.withValues(alpha: 0.4),
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
