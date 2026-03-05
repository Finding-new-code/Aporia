import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:aporia/features/chat/presentation/pages/home_page.dart';
import 'package:aporia/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

class AuthSplashPage extends StatefulWidget {
  const AuthSplashPage({super.key});

  @override
  State<AuthSplashPage> createState() => _AuthSplashPageState();
}

class _AuthSplashPageState extends State<AuthSplashPage>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVideoInitialized = false;

  void _skipToHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _videoController =
        VideoPlayerController.asset(
            'assets/videos/onboard.mp4',
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
          ..initialize().then((_) {
            setState(() {
              _isVideoInitialized = true;
            });
            _videoController.play();
          });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player
          if (_isVideoInitialized)
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 24,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: _skipToHome,
                child: Text(
                  'Skip',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.accentYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Sheet Area
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 32,
                    bottom: 48,
                    left: 24,
                    right: 24,
                  ),
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundBlack,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Google Button
                      ElevatedButton(
                        onPressed: _skipToHome,
                        style: ElevatedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/svg/github.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Continue with Github',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sign up button
                      ElevatedButton(
                        onPressed: _skipToHome,
                        style: ElevatedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: const Color(
                            0xFFC4C4C4,
                          ), // Gray color
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Sign up',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Log in button
                      OutlinedButton(
                        onPressed: () {
                          // Navigate to Login Page
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Colors.white24,
                            width: 1,
                          ),
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Log in',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
