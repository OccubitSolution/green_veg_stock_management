import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';
import '../../theme/app_theme.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D9668), // Deep emerald
              Color(0xFF10B981), // Emerald
              Color(0xFF34D399), // Light emerald
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background Pattern
            _buildBackgroundPattern(context),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container
                  Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 56,
                          color: AppTheme.primaryColor,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        curve: Curves.elasticOut,
                        duration: 800.ms,
                      ),

                  const SizedBox(height: 32),

                  // App Name
                  Text(
                        'GreenVeg',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                      )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .slideY(begin: 0.3, curve: Curves.easeOutCubic),

                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                        'stock_management'.tr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 400.ms)
                      .slideY(begin: 0.3),

                  const SizedBox(height: 64),

                  // Loading Indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(
                        Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                ],
              ),
            ),

            // Bottom Version
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Obx(() => Text(
                'v${controller.appVersion.value}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              )).animate().fadeIn(delay: 800.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Top right circle
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ).animate().fadeIn(duration: 800.ms).slideX(begin: 0.5),

        // Bottom left circle
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.5),

        // Center floating circles
        Positioned(
              top: screenHeight * 0.2,
              left: 40,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .moveY(begin: 0, end: 20, duration: 2000.ms)
            .fadeIn(delay: 500.ms),

        Positioned(
              top: screenHeight * 0.35,
              right: 60,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .moveY(begin: 0, end: -15, duration: 1800.ms)
            .fadeIn(delay: 600.ms),

        Positioned(
              bottom: screenHeight * 0.25,
              right: 80,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .moveY(begin: 0, end: 12, duration: 2200.ms)
            .fadeIn(delay: 700.ms),
      ],
    );
  }
}
