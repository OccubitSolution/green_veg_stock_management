/// PIN Setup View — redirects to dashboard (PIN removed)
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class PinSetupView extends StatelessWidget {
  const PinSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(AppRoutes.dashboard);
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
