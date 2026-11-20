import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'theme.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/buyer/home_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const PineappleApp(),
    ),
  );
}

class PineappleApp extends StatelessWidget {
  const PineappleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;

    return MaterialApp(
      title: 'FreshPine',
      theme: AppTheme.theme(),
      debugShowCheckedModeBanner: false,
      home: isDesktop ? const AdminShell() : const HomeScreen(),
    );
  }
}
