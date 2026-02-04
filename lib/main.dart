import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/routes/app_routes.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/datasources/seed_data.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/widgets/secure_app_wrapper.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("Firebase initialized successfully");
    }
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  try {
    await DatabaseSeeder.seed();
    debugPrint("Local database seeded successfully");
  } catch (e) {
    debugPrint("Database seeding error: $e");
  }

  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.requestPermissions();
    debugPrint("Notification service initialized successfully");
  } catch (e) {
    debugPrint("Notification initialization error: $e");
  }

  final prefs = await SharedPreferences.getInstance();
  final isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(ProviderScope(child: ExpenseTrackerApp(isOnboardingComplete: isOnboardingComplete)));
}

class ExpenseTrackerApp extends ConsumerWidget {
  final bool isOnboardingComplete;

  const ExpenseTrackerApp({super.key, required this.isOnboardingComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: isOnboardingComplete ? const SecureAppWrapper() : const OnboardingScreen(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
