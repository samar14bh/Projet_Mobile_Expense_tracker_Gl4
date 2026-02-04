import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_providers.dart';
import '../screens/lock_screen.dart';
import '../screens/main_screen.dart';

/// Wraps the app with a security layer that shows LockScreen if enabled.
class SecureAppWrapper extends ConsumerStatefulWidget {
  const SecureAppWrapper({super.key});

  @override
  ConsumerState<SecureAppWrapper> createState() => _SecureAppWrapperState();
}

class _SecureAppWrapperState extends ConsumerState<SecureAppWrapper> with WidgetsBindingObserver {
  bool _isLocked = true;
  bool _isCheckingLock = true;
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialLockState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkInitialLockState() async {
    final service = ref.read(securityServiceProvider);
    final isEnabled = await service.isAppLockEnabled();
    
    setState(() {
      _isLocked = isEnabled;
      _isCheckingLock = false;
    });

    if (!isEnabled) {
      ref.read(isAuthenticatedProvider.notifier).state = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _handleAppResume();
    }
  }

  Future<void> _handleAppResume() async {
    final service = ref.read(securityServiceProvider);
    final isEnabled = await service.isAppLockEnabled();
    
    if (!isEnabled) return;

    final timeout = await service.getInactivityTimeout();
    final pausedTime = _pausedTime;

    if (pausedTime != null) {
      final elapsed = DateTime.now().difference(pausedTime).inSeconds;
      if (elapsed > timeout) {
        setState(() => _isLocked = true);
        ref.read(isAuthenticatedProvider.notifier).state = false;
      }
    }
  }

  void _onUnlocked() {
    setState(() => _isLocked = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingLock) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isLocked) {
      return LockScreen(onUnlocked: _onUnlocked);
    }

    return const MainScreen();
  }
}
