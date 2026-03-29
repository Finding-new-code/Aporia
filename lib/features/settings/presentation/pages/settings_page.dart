import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:aporia/features/auth/presentation/dataflows/auth_dataflow.dart';
import 'package:aporia/features/chat/presentation/pages/guest_home_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundBlack,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLightGray.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Profile Section
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade600,
                child: const Text(
                  'SN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Satya Prakash Nayak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'satyaprakashnayak007',
                style: TextStyle(color: AppTheme.textGray, fontSize: 14),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  minimumSize: const Size(0, 40),
                ),
                child: const Text(
                  'Edit profile',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 32),

              // My Aporia Section
              _buildSectionTitle('My Aporia'),
              _buildSectionCard([
                _buildListTile(
                  Icons.sentiment_satisfied_alt,
                  'Personalization',
                  true,
                ),
                _buildDivider(),
                _buildListTile(Icons.grid_view_rounded, 'Apps', false),
              ]),
              const SizedBox(height: 24),

              // Account Section
              _buildSectionTitle('Account'),
              _buildSectionCard([
                _buildListTile(
                  Icons.work_outline,
                  'Workspace',
                  true,
                  subtitle: 'Personal',
                ),
                _buildDivider(),
                _buildListTile(
                  Icons.add_box_outlined,
                  'Subscription',
                  true,
                  subtitle: 'Go',
                ),
                _buildDivider(),
                _buildListTile(
                  Icons.family_restroom,
                  'Parental controls',
                  true,
                ),
                _buildDivider(),
                _buildListTile(
                  Icons.mail_outline,
                  'Email',
                  true,
                  subtitle: 'satyaprakashnayak007@gmail.com',
                ),
                _buildDivider(),
                _buildListTile(
                  Icons.phone_outlined,
                  'Phone number',
                  false,
                  subtitle: '+917325834880',
                ),
              ]),
              
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  await LogoutAction().execute();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const GuestHomePage()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLightGray.withValues(alpha: 0.3),
        // Dark grey background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.white12,
      height: 1,
      indent: 56,
      endIndent: 0,
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title,
    bool hasArrow, {
    String? subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: AppTheme.textGray, fontSize: 14),
            )
          : null,
      trailing: hasArrow
          ? const Icon(Icons.chevron_right, color: AppTheme.textGray, size: 24)
          : null,
      onTap: () {},
      minVerticalPadding: 16,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
