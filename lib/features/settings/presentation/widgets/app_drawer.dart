import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:aporia/core/services/notification_service.dart';
import 'package:aporia/features/settings/presentation/pages/settings_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundBlack,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            // Search Bar Area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLightGray.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.white.withValues(alpha: 0.6),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Search',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Close/Hide button placeholder
                  Icon(Icons.edit_square, color: Colors.white, size: 24),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildDrawerItem(Icons.chat_bubble_outline, 'New chat'),
                  // _buildDrawerItem(Icons.image_outlined, 'Library'),
                  _buildDrawerItem(Icons.grid_view_rounded, 'Library'),
                  const SizedBox(height: 16),
                  _buildDrawerItem(
                    Icons.create_new_folder_outlined,
                    'New project',
                  ),
                  // _buildDrawerItem(
                  //   Icons.psychology_alt_outlined,
                  //   'Humanizer',
                  //   color: Colors.purpleAccent,
                  // ),
                  // _buildDrawerItem(
                  //   Icons.edit_document,
                  //   'Writing',
                  //   color: Colors.purpleAccent,
                  // ),
                  const SizedBox(height: 16),

                  // Projects Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'All projects',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // History Items
                  _buildHistoryItem('Cynerza Investor Pitch Draft'),
                  _buildHistoryItem('Fonoster Overview'),
                  _buildHistoryItem('India HealthTech Architecture'),
                  _buildHistoryItem('App Installation Conflict Fix'),
                  _buildHistoryItem('Sarvam Arya Overview'),
                  const Divider(color: Colors.white24),
                  _buildDrawerItem(
                    Icons.notifications_active_outlined,
                    'Test Notification',
                    onTap: () async {
                      debugPrint('Triggering Test Notification...');
                      await NotificationService().showNotification(
                        id: (DateTime.now().millisecondsSinceEpoch % 1000000)
                            .toInt(),
                        title: 'Aporia Test',
                        body: 'This is a test notification from Aporia.',
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom Profile Section
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.backgroundBlack,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade400,
                      radius: 16,
                      child: const Text(
                        'SN',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Satya Prakash Nayak',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.expand_more, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title, {
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      dense: true,
      onTap: onTap ?? () {},
    );
  }

  Widget _buildHistoryItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
