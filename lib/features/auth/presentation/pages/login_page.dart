import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:aporia/features/chat/presentation/pages/guest_home_page.dart';
import 'package:aporia/features/auth/presentation/dataflows/auth_dataflow.dart';
import 'package:aporia/features/auth/presentation/pages/signup_page.dart';
import 'package:aporia/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:flutter_svg/svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  bool _isPasswordStep = false;

  void _handleContinue() {
    if (!_isPasswordStep) {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        setState(() => _errorMessage = 'Please enter your email.');
        return;
      }
      setState(() {
        _isPasswordStep = true;
        _errorMessage = null;
      });
    } else {
      _login();
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final action = LoginAction(email: email, password: password);
      await action.execute();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GuestHomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLightGray.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPasswordStep ? Icons.arrow_back : Icons.arrow_back,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            if (_isPasswordStep) {
              setState(() {
                _isPasswordStep = false;
                _errorMessage = null;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/space.jpg'),
            fit: BoxFit.cover,
            opacity: 0.4,
            isAntiAlias: true,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Aporia Logo (Re-using the animated circle concept for the logo)
              Image.asset('assets/images/logo.png', width: 128, height: 128),
              // const SizedBox(height: 32),

              // Title "Log in or sign up"
              Text(
                _isPasswordStep ? 'Welcome back' : 'Log in or sign up',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                _isPasswordStep
                    ? 'Enter your password to continue.'
                    : 'You\'ll get smarter responses and can upload\nfiles, images and more.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textWhite,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: !_isPasswordStep
                    ? TextFormField(
                        key: const ValueKey('email_field'),
                        controller: _emailController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppTheme.textGray,
                          ),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: AppTheme.textGray.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: AppTheme.surfaceLightGray,
                            ),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          // contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.comfortable,
                        ),
                        onFieldSubmitted: (_) => _handleContinue(),
                      )
                    : TextFormField(
                        key: const ValueKey('password_field'),
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppTheme.textGray,
                          ),
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: AppTheme.textGray.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: AppTheme.surfaceLightGray,
                            ),
                          ),
                          visualDensity: VisualDensity.comfortable,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          // contentPadding: EdgeInsets.zero,
                        ),
                        onFieldSubmitted: (_) => _handleContinue(),
                      ),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ),

              if (_isPasswordStep) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textWhite,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                const SizedBox(height: 24),
              ],

              // Continue Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textWhite,
                  foregroundColor: AppTheme.backgroundBlack,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppTheme.backgroundBlack,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isPasswordStep ? 'Log in' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // OR Divider
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppTheme.surfaceLightGray.withValues(alpha: 0.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: AppTheme.textGray.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppTheme.surfaceLightGray.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Continue with Google Button
              _buildAlternativeLoginButton(
                svgIcon: 'assets/svg/github.svg',
                iconColor: const Color.fromARGB(255, 245, 246, 247),
                label: 'Continue with Github',
                onPressed: () {}, // TODO: Implement Github login
              ),
              const SizedBox(height: 12),

              // // Continue with phone Button
              // _buildAlternativeLoginButton(
              //   icon: Icons.phone_outlined,
              //   iconColor: AppTheme.textWhite,
              //   label: 'Continue with phone',
              //   onPressed: _continueToGuestHome,
              // ),
              // Signup link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: TextStyle(
                      color: AppTheme.textWhite.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SignupPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Text at bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Terms of Use',
                    style: TextStyle(
                      color: AppTheme.textGray.withValues(alpha: 0.8),
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Text(
                    ' · ',
                    style: TextStyle(
                      color: AppTheme.textGray.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: AppTheme.textGray.withValues(alpha: 0.8),
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
    required String svgIcon,
    required Color iconColor,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textWhite,
        side: BorderSide(
          color: AppTheme.surfaceLightGray.withValues(alpha: 0.8),
          width: 1,
        ),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              svgIcon,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
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
