import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/security_service.dart';

/// Provider for the SecurityService singleton.
final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService();
});

/// State notifier for app lock enabled status.
class AppLockNotifier extends StateNotifier<bool> {
  final SecurityService _service;

  AppLockNotifier(this._service) : super(false) {
    _loadState();
  }

  Future<void> _loadState() async {
    state = await _service.isAppLockEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    await _service.setAppLockEnabled(enabled);
    state = enabled;
  }
}

final appLockEnabledProvider = StateNotifierProvider<AppLockNotifier, bool>((ref) {
  final service = ref.watch(securityServiceProvider);
  return AppLockNotifier(service);
});

/// State notifier for privacy mode.
class PrivacyModeNotifier extends StateNotifier<bool> {
  final SecurityService _service;

  PrivacyModeNotifier(this._service) : super(false) {
    _loadState();
  }

  Future<void> _loadState() async {
    state = await _service.isPrivacyModeEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    await _service.setPrivacyModeEnabled(enabled);
    state = enabled;
  }
}

final privacyModeProvider = StateNotifierProvider<PrivacyModeNotifier, bool>((ref) {
  final service = ref.watch(securityServiceProvider);
  return PrivacyModeNotifier(service);
});

/// State notifier for authentication method.
class AuthMethodNotifier extends StateNotifier<String> {
  final SecurityService _service;

  AuthMethodNotifier(this._service) : super('pin') {
    _loadState();
  }

  Future<void> _loadState() async {
    state = await _service.getAuthMethod();
  }

  Future<void> setMethod(String method) async {
    await _service.setAuthMethod(method);
    state = method;
  }
}

final authMethodProvider = StateNotifierProvider<AuthMethodNotifier, String>((ref) {
  final service = ref.watch(securityServiceProvider);
  return AuthMethodNotifier(service);
});

/// Tracks whether the user is currently authenticated in this session.
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

/// Tracks temporary reveal state for privacy mode (e.g., tap-and-hold).
final temporaryRevealProvider = StateProvider<bool>((ref) => false);
