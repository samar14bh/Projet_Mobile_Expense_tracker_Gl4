import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/security_providers.dart';

/// A widget that wraps sensitive content and masks it when privacy mode is enabled.
/// Users can tap-and-hold to temporarily reveal the content using biometric authentication.
class PrivacyWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final String? placeholder;
  final bool isSensitive;

  const PrivacyWrapper({
    super.key,
    required this.child,
    this.placeholder,
    this.isSensitive = true,
  });

  @override
  ConsumerState<PrivacyWrapper> createState() => _PrivacyWrapperState();
}

class _PrivacyWrapperState extends ConsumerState<PrivacyWrapper> {
  bool _isTemporarilyRevealed = false;

  Future<void> _onLongPress() async {
    final service = ref.read(securityServiceProvider);
    final success = await service.authenticateWithBiometrics(reason: 'Authenticate to reveal data');
    
    if (success) {
      setState(() => _isTemporarilyRevealed = true);
      HapticFeedback.lightImpact();
      
      // Auto-hide after 5 seconds
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        setState(() => _isTemporarilyRevealed = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final privacyMode = ref.watch(privacyModeProvider);
    final temporaryReveal = ref.watch(temporaryRevealProvider);

    // Show child if privacy mode is off, or if temporarily revealed
    if (!privacyMode || !widget.isSensitive || _isTemporarilyRevealed || temporaryReveal) {
      return widget.child;
    }

    // Show masked content
    return GestureDetector(
      onLongPress: _onLongPress,
      child: widget.placeholder != null
          ? Text(
              widget.placeholder!,
              style: DefaultTextStyle.of(context).style,
            )
          : _buildBlurredContent(),
    );
  }

  Widget _buildBlurredContent() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Blurred/masked overlay
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white.withOpacity(0.1) 
                : Colors.grey.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Opacity(
            opacity: 0,
            child: widget.child,
          ),
        ),
        // Hint text
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility_off,
              size: 16,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white38 
                  : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              'Hold to reveal',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white38 
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A simple masked text widget for amounts like "$***.**"
class MaskedAmount extends StatelessWidget {
  final String prefix;
  final TextStyle? style;

  const MaskedAmount({super.key, this.prefix = '\$', this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$prefix***.**',
      style: style ?? DefaultTextStyle.of(context).style,
    );
  }
}
