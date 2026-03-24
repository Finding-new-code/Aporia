import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:aporia/features/auth/presentation/pages/auth_splash_page.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:aporia/features/chat/presentation/dataflows/chat_dataflow.dart';
import 'package:aporia/features/discover/presentation/dataflows/discover_dataflow.dart';

import 'package:aporia/core/services/notification_service.dart';

void main() async {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  initChatDataflow();
  initDiscoverDataflow();
  await NotificationService().init();
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
