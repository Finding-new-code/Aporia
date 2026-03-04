import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:aporia/features/chat/presentation/pages/guest_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();

  void _continueToGuestHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const GuestHomePage()));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLightGray.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Aporia Logo (Re-using the animated circle concept for the logo)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundBlack,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.textWhite, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentYellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title "Log in or sign up"
              Text(
                'Log in or sign up',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'You\'ll get smarter responses and can upload\nfiles, images and more.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textWhite,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              // Email Input Field
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundBlack,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.surfaceLightGray),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: AppTheme.textGray.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Continue Button
              ElevatedButton(
                onPressed: _continueToGuestHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textWhite,
                  foregroundColor: AppTheme.backgroundBlack,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),

              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppTheme.surfaceLightGray.withOpacity(0.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: AppTheme.textGray.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppTheme.surfaceLightGray.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Continue with Google Button
              _buildAlternativeLoginButton(
                icon: Icons.g_mobiledata,
                iconColor: Colors.blue,
                label: 'Continue with Google',
                onPressed: _continueToGuestHome,
              ),
              const SizedBox(height: 12),

              // Continue with phone Button
              _buildAlternativeLoginButton(
                icon: Icons.phone_outlined,
                iconColor: AppTheme.textWhite,
                label: 'Continue with phone',
                onPressed: _continueToGuestHome,
              ),

              const Spacer(),

              // Text at bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Terms of Use',
                    style: TextStyle(
                      color: AppTheme.textGray.withOpacity(0.8),
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Text(
                    ' · ',
                    style: TextStyle(
                      color: AppTheme.textGray.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: AppTheme.textGray.withOpacity(0.8),
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeLoginButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textWhite,
        side: BorderSide(
          color: AppTheme.surfaceLightGray.withOpacity(0.8),
          width: 1,
        ),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(icon, color: iconColor, size: 24),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
