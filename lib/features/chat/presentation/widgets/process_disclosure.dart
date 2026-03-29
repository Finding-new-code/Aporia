import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';

class ProcessDisclosure extends StatefulWidget {
  final String statusText;

  const ProcessDisclosure({
    super.key,
    required this.statusText,
  });

  @override
  State<ProcessDisclosure> createState() => _ProcessDisclosureState();
}

class _ProcessDisclosureState extends State<ProcessDisclosure>
    with SingleTickerProviderStateMixin {
  late AnimationController _animeController;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _animeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _opacityAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animeController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _opacityAnim,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnim.value,
                child: child,
              );
            },
            child: Image.asset(
              'assets/images/logo.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.statusText,
            style: TextStyle(
              color: AppTheme.textGray.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
