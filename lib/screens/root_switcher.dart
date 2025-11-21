import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'onboarding_screen.dart';
import 'main_layout.dart';

class RootSwitcher extends StatelessWidget {
  const RootSwitcher({super.key});
  @override
  Widget build(BuildContext context) {
    var isLoggedIn = context.select<AppState, bool>((s) => s.isLoggedIn);
    return isLoggedIn ? const MainLayout() : const OnboardingScreen();
  }
}