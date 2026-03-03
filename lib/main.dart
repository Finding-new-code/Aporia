import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:aporia/features/auth/presentation/pages/auth_splash_page.dart';

import 'package:aporia/features/chat/presentation/dataflows/chat_dataflow.dart';

void main() {
  initChatDataflow();
  runApp(const AporiaApp());
}

class AporiaApp extends StatelessWidget {
  const AporiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aporia',
      theme: AppTheme.darkTheme,
      home: const AuthSplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
