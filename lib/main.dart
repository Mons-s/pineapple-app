import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'services/buyer_profile.dart';
import 'theme.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/buyer/home_screen.dart';
import 'screens/buyer/buyer_profile_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  if (!isDesktop) FcmService.registerBackgroundHandler();

  ({String name, String phone})? profile;
  if (!isDesktop) profile = await BuyerProfile.load();
  if (profile != null) FcmService.init(profile.phone);

  final hasProfile = isDesktop ? true : profile != null;

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: PineappleApp(isDesktop: isDesktop, hasProfile: hasProfile),
    ),
  );
}

class PineappleApp extends StatelessWidget {
  final bool isDesktop;
  final bool hasProfile;
  const PineappleApp({super.key, required this.isDesktop, required this.hasProfile});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshPine',
      theme: AppTheme.theme(),
      debugShowCheckedModeBanner: false,
      home: isDesktop
          ? const AdminShell()
          : (hasProfile ? const HomeScreen() : const BuyerProfileScreen()),
    );
  }
}
