import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/config/app_images.dart';
import 'package:hyper_local/router/app_routes.dart';
import '../../config/colors.dart';
import '../../config/global.dart';
import '../../utils/notification_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start navigation after ensuring minimum splash duration
    _initAndNavigate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initAndNavigate() async {
    final startTime = DateTime.now();

    try {
      // Parallelize any remaining async checks (e.g. auth status)
      // Note: Firebase, Notifications, Hive, etc. are already handled in main.dart
      final results = await Future.wait([
        Global.getUserToken(),
        // Add any other necessary checks here
      ]);

      final String? token = results[0] as String?;

      // Ensure splash screen shows for at least 1.5 seconds for branding
      final elapsed = DateTime.now().difference(startTime);
      final remaining = const Duration(milliseconds: 1500) - elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }

      if (!mounted) return;

      if (token != null) {
        log('✅ SPLASH SCREEN: User authenticated, navigating to dashboard');
        GoRouter.of(context).pushReplacement(AppRoutes.dashboard);
      } else {
        log('ℹ️ SPLASH SCREEN: User not authenticated, navigating to login');
        GoRouter.of(context).pushReplacement(AppRoutes.login);
      }
    } catch (e) {
      log('❌ SPLASH SCREEN: Navigation error: $e');
      if (mounted) {
        GoRouter.of(context).pushReplacement(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Animation
            // Lottie.asset(
            //   'assets/lottie/Food Courier.json',
            //   width: 150.w,
            //   height: 150.h,
            //   fit: BoxFit.contain,
            //   repeat: true,
            //   animate: true,
            // ),
            // Image.asset(
            //   AppImages.splashLogo,
            //   width: 200.w,
            //   height: 200.h,
            //   fit: BoxFit.contain,
            // ),
            Image.asset(
              'assets/app/Logo-DriverApp.png',
              height: 180,
              width: 250,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
