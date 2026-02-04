import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static const _keyAppLockEnabled = 'app_lock_enabled';
  static const _keyAuthMethod = 'auth_method'; // 'pin', 'biometric', 'both'
  static const _keyPin = 'user_pin';
  static const _keyPrivacyModeEnabled = 'privacy_mode_enabled';
  static const _keyInactivityTimeout = 'inactivity_timeout_seconds';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // ===================== APP LOCK =====================

  Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAppLockEnabled) ?? false;
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAppLockEnabled, enabled);
  }

  // ===================== AUTH METHOD =====================

  Future<String> getAuthMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthMethod) ?? 'pin';
  }

  Future<void> setAuthMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthMethod, method);
  }

  // ===================== PIN MANAGEMENT =====================

  Future<bool> hasPin() async {
    final pin = await _secureStorage.read(key: _keyPin);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    await _secureStorage.write(key: _keyPin, value: pin);
  }

  Future<bool> verifyPin(String enteredPin) async {
    final storedPin = await _secureStorage.read(key: _keyPin);
    return storedPin == enteredPin;
  }

  Future<void> clearPin() async {
    await _secureStorage.delete(key: _keyPin);
  }

  // ===================== BIOMETRICS =====================

  Future<bool> isBiometricsAvailable() async {
    try {
      final canCheckBio = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBio && isDeviceSupported;
    } catch (e) {
      debugPrint('Biometrics check failed: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Failed to get biometrics: $e');
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics({String reason = 'Authenticate to access the app'}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow device PIN as fallback
        ),
      );
    } catch (e) {
      debugPrint('Biometric authentication failed: $e');
      return false;
    }
  }

  // ===================== PRIVACY MODE =====================

  Future<bool> isPrivacyModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPrivacyModeEnabled) ?? false;
  }

  Future<void> setPrivacyModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrivacyModeEnabled, enabled);
  }

  // ===================== INACTIVITY TIMEOUT =====================

  Future<int> getInactivityTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyInactivityTimeout) ?? 60; // Default 60 seconds
  }

  Future<void> setInactivityTimeout(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyInactivityTimeout, seconds);
  }
}
