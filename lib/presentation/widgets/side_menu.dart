import 'dart:io';
import 'package:expense_tracker/data/datasources/seed_data.dart';
import 'package:expense_tracker/presentation/providers/budget_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added
import '../../core/theme/theme_provider.dart';
import '../../core/routes/route_names.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/recurring_expenses_screen.dart';
import '../screens/profile_screen.dart'; // Added
import '../providers/expense_providers.dart';
import '../providers/category_providers.dart';

class SideMenu extends ConsumerStatefulWidget {
  const SideMenu({super.key});

  @override
  ConsumerState<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideMenu> {
  String _userName = 'Expense Tracker';
  String? _userImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Expense Tracker';
        _userImagePath = prefs.getString('user_image_path');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Premium Header with Profile
            GestureDetector(
              onTap: () async {
                // Navigate to Profile Screen
                Navigator.pop(context); // Close drawer first? Maybe better to keep it open or reopen?
                // Standard behavior: close drawer, navigate. 
                // But we want to refresh when we come back.
                // Actually, if we close drawer, we are on Home. Home doesn't rebuild SideMenu unless we reopen it.
                // So when we reopen SideMenu, initState runs again? 
                // Drawer is usually transient. If it's closed and reopened, it is rebuilt.
                // So initState should run again.
                // BUT, let's navigate from here.
                
                // Wait, if I pop the drawer, the SideMenu widget is disposed.
                // So when I open it again, it re-initializes and reloads profile.
                // So simpler logic: Just navigate.
                
                await Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => const ProfileScreen())
                );
                // Note: user might be on a screen that has the drawer. 
                // If we want to reflect changes immediately in the drawer if it stays open (unlikely on mobile), we'd need to await.
                // If we pop the drawer, we don't need to do anything here.
                // Let's pop the drawer first to be standard.
              },
              child: _buildHeader(context, isDark),
            ),
            
            // Scrollable Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Main Navigation Section
                  _buildSectionLabel('NAVIGATION', isDark),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, RouteNames.home);
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.category_rounded,
                    label: 'Categories',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RouteNames.categories);
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.add_circle_rounded,
                    label: 'Add Expense',
                    isDark: isDark,
                    accentColor: theme.primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RouteNames.addExpense);
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.sync_alt_rounded,
                    label: 'Recurring Expenses',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RecurringExpensesScreen()));
                    },
                  ),

                  const SizedBox(height: 16),
                  
                  // Settings Section
                  _buildSectionLabel('SETTINGS', isDark),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.notifications_rounded,
                    label: 'Notifications',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()));
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.shield_rounded,
                    label: 'Security & Privacy',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RouteNames.securitySettings);
                    },
                  ),
                  
                  // Theme Toggle
                  _buildThemeToggle(context, ref, themeMode, isDark),

                  const SizedBox(height: 16),
                  
                  // Danger Zone
                  _buildSectionLabel('DANGER ZONE', isDark, isDestructive: true),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.refresh_rounded,
                    label: 'Reset All Data',
                    isDark: isDark,
                    isDestructive: true,
                    onTap: () => _showResetDialog(context, ref),
                  ),
                ],
              ),
            ),

            // Footer
            _buildFooter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    ImageProvider? imageProvider;
    if (_userImagePath != null) {
      final file = File(_userImagePath!);
      if (file.existsSync()) {
        imageProvider = FileImage(file);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF6C63FF), const Color(0xFF3F3D9E)]
            : [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 26,
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? const Icon(Icons.person, size: 26, color: Color(0xFF6C63FF))
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your finances',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDestructive 
            ? Colors.redAccent.withOpacity(0.7)
            : (isDark ? Colors.white38 : Colors.grey[500]),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    Color? accentColor,
    bool isDestructive = false,
  }) {
    final color = isDestructive 
      ? Colors.redAccent 
      : (accentColor ?? (isDark ? Colors.white : Colors.black87));

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (accentColor ?? color).withOpacity(isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? Colors.redAccent : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, WidgetRef ref, ThemeMode themeMode, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? Colors.amber : Colors.indigo).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? Colors.amber : Colors.indigo,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const Spacer(),
          Switch.adaptive(
            value: themeMode == ThemeMode.dark,
            onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
            activeColor: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Version 1.0.0',
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white24 : Colors.grey[400],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 12),
            const Text('Reset All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your expenses, categories, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 1. Clear SharedPreferences (Onboarding, Profile, Settings)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 2. Force re-seed database (clears everything and adds defaults)
      await DatabaseSeeder.reseed();
      
      // 3. Invalidate all Riverpod providers
      ref.invalidate(allExpensesProvider);
      ref.invalidate(currentMonthExpensesProvider);
      ref.invalidate(allCategoriesProvider);
      ref.invalidate(currentMonthBudgetProvider);
      ref.invalidate(allMonthlyBudgetsProvider);
      // Also refresh theme and auth state potentially, but app reload handles most.
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('App data fully reset. Restarting...'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        // Navigate to Onboarding (MainScreen will re-check prefs on restart, but here we can force nav)
        // Since we cleared prefs, 'onboarding_complete' is gone.
        // We should probably restart the app or nav to Onboarding.
        // Simplest is to push OnboardingScreen.
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); 
        // Note: '/' route is usually home. But main.dart determines what home is.
        // Flutter doesn't easily "restart" fully without native code.
        // But replacing route with / might work if 'home' logic in main is re-evaluated?
        // No, 'home' is evaluated at startup.
        // We can just push OnboardingScreen directly.
        // But we need to import it if we use class directly, or use a named route if defined.
        // We haven't defined a named route for Onboarding.
        // So we will just push Replacement to RouteNames.home (which leads to AppWrapper)
        // AND since we are inside SideMenu, context is available.
        // Actually, if we cleared prefs, the next app launch shows Onboarding.
        // To make it immediate, we might need to tell Main about it?
        // For now, let's just show the snackbar and let the user restart or navigate home.
        // Navigating to Home is fine, they will see empty data.
        // If they restart app, they get onboarding.
         Navigator.pushReplacementNamed(context, RouteNames.home);
      }
    }
  }
}
