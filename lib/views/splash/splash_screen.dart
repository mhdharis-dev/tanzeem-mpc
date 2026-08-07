// Library: splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Auto navigate after 2.6 seconds using GoRouter
    Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        context.go(appState.isLoggedIn ? '/' : '/login');
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF064E3B),
      body: Stack(
        children: [
          // Background Gradient & Glow Spheres
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFF0F766E), const Color(0xFF042F2E)],
                ),
              ),
            ),
          ),

          // Glowing Concentric Rings behind Logo
          Center(
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  width: 180 + (_glowController.value * 20),
                  height: 180 + (_glowController.value * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withAlpha((30 + (_glowController.value * 25)).toInt()),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withAlpha((50 + (_glowController.value * 40)).toInt()),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Main Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container with Glassmorphism Border & Shadow
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withAlpha(60), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      'assets/images/tanzeem_logo.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.mosque_rounded,
                        size: 70,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 600.ms),

                const SizedBox(height: 28),

                // English Brand Title: TANZEEM
                Text(
                  'TANZEEM',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 6,
                    shadows: [
                      Shadow(
                        color: AppColors.primary.withAlpha(150),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 6),

                // Arabic Title: تنظيم
                Text(
                  'تنظيم',
                  style: GoogleFonts.amiri(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 600.ms)
                    .scale(delay: 500.ms, duration: 600.ms),

                const SizedBox(height: 12),

                // Tagline: Smart Meelad Program Management
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(30)),
                  ),
                  child: Text(
                    'Smart Meelad Program Management',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withAlpha(220),
                      letterSpacing: 0.5,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 600.ms)
                    .slideY(begin: 0.4, end: 0, delay: 700.ms, duration: 600.ms),
              ],
            ),
          ),

          // Bottom Loading Bar & Status text
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: Colors.white12,
                      color: AppColors.accent,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 400.ms),
                const SizedBox(height: 12),
                Text(
                  'Initializing Meelad Engine...',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withAlpha(160),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
