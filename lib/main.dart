import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/buyer/home_screen.dart';

void main() {
  runApp(const PineappleApp());
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
