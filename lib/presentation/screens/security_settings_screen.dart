import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_providers.dart';
import '../../core/services/security_service.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final service = ref.read(securityServiceProvider);
    final available = await service.isBiometricsAvailable();
    setState(() => _biometricsAvailable = available);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appLockEnabled = ref.watch(appLockEnabledProvider);
    final authMethod = ref.watch(authMethodProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          // Premium Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [const Color(0xFF6C63FF), const Color(0xFF3F3D9E)]
                    : [theme.primaryColor, theme.primaryColor.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Security',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Protect your financial data',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // App Lock Card
                _buildPremiumCard(
                  isDark: isDark,
                  child: Column(
                    children: [
                      _buildSettingRow(
                        icon: Icons.lock_rounded,
                        iconColor: appLockEnabled ? Colors.green : (isDark ? Colors.white60 : Colors.grey),
                        title: 'App Lock',
                        subtitle: appLockEnabled ? 'Enabled' : 'Disabled',
                        isDark: isDark,
                        trailing: Switch.adaptive(
                          value: appLockEnabled,
                          activeColor: Colors.green,
                          onChanged: (value) async {
                            if (value) {
                              final success = await _showSetPinDialog();
                              if (success) {
                                ref.read(appLockEnabledProvider.notifier).setEnabled(true);
                              }
                            } else {
                              final verified = await _verifyCurrentPin();
                              if (verified) {
                                ref.read(appLockEnabledProvider.notifier).setEnabled(false);
                              }
                            }
                          },
                        ),
                      ),
                      if (appLockEnabled) ...[
                        Divider(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1), height: 1),
                        _buildSettingRow(
                          icon: Icons.fingerprint_rounded,
                          iconColor: const Color(0xFF6C63FF),
                          title: 'Authentication Method',
                          subtitle: _getAuthMethodLabel(authMethod),
                          isDark: isDark,
                          onTap: () => _showAuthMethodPicker(authMethod),
                        ),
                        Divider(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1), height: 1),
                        _buildSettingRow(
                          icon: Icons.dialpad_rounded,
                          iconColor: Colors.orange,
                          title: 'Change PIN',
                          subtitle: 'Update your security code',
                          isDark: isDark,
                          onTap: () => _showChangePinDialog(),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.info_rounded, color: Colors.blue, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'All security settings are stored locally on your device.',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.1),
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white24 : Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  String _getAuthMethodLabel(String method) {
    switch (method) {
      case 'biometric':
        return 'Biometric (Fingerprint/Face)';
      case 'both':
        return 'PIN + Biometric';
      default:
        return 'PIN Code';
    }
  }

  Future<bool> _showSetPinDialog() async {
    String pin = '';
    String confirmPin = '';
    bool isConfirming = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isConfirming ? 'Confirm PIN' : 'Set PIN'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isConfirming ? 'Re-enter your 4-digit PIN' : 'Enter a 4-digit PIN'),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (value) {
                      if (isConfirming) {
                        confirmPin = value;
                      } else {
                        pin = value;
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (!isConfirming && pin.length == 4) {
                      setState(() => isConfirming = true);
                    } else if (isConfirming && confirmPin.length == 4) {
                      if (confirmPin == pin) {
                        ref.read(securityServiceProvider).setPin(pin);
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PINs do not match')),
                        );
                      }
                    }
                  },
                  child: Text(isConfirming ? 'Confirm' : 'Next'),
                ),
              ],
            );
          },
        );
      },
    );
    return result ?? false;
  }

  Future<bool> _verifyCurrentPin() async {
    String enteredPin = '';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verify PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your current PIN to disable app lock'),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: const InputDecoration(counterText: ''),
                onChanged: (value) => enteredPin = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final verified = await ref.read(securityServiceProvider).verifyPin(enteredPin);
                if (verified) {
                  if (context.mounted) Navigator.pop(context, true);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect PIN')),
                    );
                  }
                }
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _showAuthMethodPicker(String currentMethod) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.dialpad),
                title: const Text('PIN Code'),
                trailing: currentMethod == 'pin' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  ref.read(authMethodProvider.notifier).setMethod('pin');
                  Navigator.pop(context);
                },
              ),
              if (_biometricsAvailable) ...[
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('Biometric'),
                  trailing: currentMethod == 'biometric' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    ref.read(authMethodProvider.notifier).setMethod('biometric');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('PIN + Biometric'),
                  trailing: currentMethod == 'both' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    ref.read(authMethodProvider.notifier).setMethod('both');
                    Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showChangePinDialog() async {
    final verified = await _verifyCurrentPin();
    if (verified) {
      await _showSetPinDialog();
    }
  }
}
