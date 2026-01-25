import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/security_service.dart';
import '../providers/security_providers.dart';

class LockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({super.key, required this.onUnlocked});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _enteredPin = '';
  bool _isLoading = false;
  String _errorMessage = '';
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final service = ref.read(securityServiceProvider);
    final authMethod = await service.getAuthMethod();
    final bioAvailable = await service.isBiometricsAvailable();

    setState(() {
      _biometricsAvailable = bioAvailable && (authMethod == 'biometric' || authMethod == 'both');
    });

    // Auto-trigger biometric if it's the primary or only method
    if (_biometricsAvailable && authMethod == 'biometric') {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() => _isLoading = true);
    final service = ref.read(securityServiceProvider);
    final success = await service.authenticateWithBiometrics();
    setState(() => _isLoading = false);

    if (success) {
      ref.read(isAuthenticatedProvider.notifier).state = true;
      widget.onUnlocked();
    } else {
      setState(() => _errorMessage = 'Biometric authentication failed');
    }
  }

  Future<void> _verifyPin() async {
    if (_enteredPin.length != 4) return;

    setState(() => _isLoading = true);
    final service = ref.read(securityServiceProvider);
    final success = await service.verifyPin(_enteredPin);
    setState(() => _isLoading = false);

    if (success) {
      ref.read(isAuthenticatedProvider.notifier).state = true;
      widget.onUnlocked();
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN';
        _enteredPin = '';
      });
      HapticFeedback.heavyImpact();
    }
  }

  void _onNumberTap(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _errorMessage = '';
      });
      HapticFeedback.lightImpact();
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(
              Icons.lock_outline,
              size: 64,
              color: theme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Enter PIN',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your 4-digit PIN to unlock',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? theme.primaryColor : Colors.transparent,
                    border: Border.all(
                      color: isFilled ? theme.primaryColor : (isDark ? Colors.white38 : Colors.grey),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
              ),
            if (_isLoading) const CircularProgressIndicator(),
            const Spacer(),
            // Number pad
            _buildNumberPad(isDark),
            const SizedBox(height: 24),
            // Biometric button
            if (_biometricsAvailable)
              TextButton.icon(
                onPressed: _authenticateWithBiometrics,
                icon: const Icon(Icons.fingerprint, size: 28),
                label: const Text('Use Fingerprint'),
              ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad(bool isDark) {
    final buttons = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'backspace'],
    ];

    return Column(
      children: buttons.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((item) {
            if (item.isEmpty) {
              return const SizedBox(width: 80, height: 80);
            }
            if (item == 'backspace') {
              return _buildPadButton(
                child: const Icon(Icons.backspace_outlined),
                onTap: _onBackspace,
                isDark: isDark,
              );
            }
            return _buildPadButton(
              child: Text(
                item,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              onTap: () => _onNumberTap(item),
              isDark: isDark,
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildPadButton({required Widget child, required VoidCallback onTap, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
