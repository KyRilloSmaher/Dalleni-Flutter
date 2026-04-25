import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/confirm_reset_code_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/login_screen_actions.dart';
import 'reset_password_screen.dart';

/// Screen 2 of the forgot-password flow.
/// User enters the 6-digit code received via email.
/// Calls POST /api/auth/confirm-reset-password-code.
/// Resend calls POST /api/auth/resend-reset-code (enabled after 60 s).
class ConfirmResetCodeScreen extends ConsumerStatefulWidget {
  const ConfirmResetCodeScreen({super.key, required this.email});

  /// The email used in Screen 1 — forwarded to the API and to Screen 3.
  final String email;

  @override
  ConsumerState<ConfirmResetCodeScreen> createState() =>
      _ConfirmResetCodeScreenState();
}

class _ConfirmResetCodeScreenState extends ConsumerState<ConfirmResetCodeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pinController = TextEditingController();

  // ─── Timer ───────────────────────────────────────────────────────────────
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;

  // ─── Shake animation ─────────────────────────────────────────────────────
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initShakeAnimation();
  }

  void _initShakeAnimation() {
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _triggerShake() => _shakeController.forward(from: 0);

  void _startTimer() {
    _secondsRemaining = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  void _confirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(confirmResetCodeControllerProvider.notifier)
        .confirm(email: widget.email);
  }

  void _resend() {
    ref
        .read(confirmResetCodeControllerProvider.notifier)
        .resend(email: widget.email);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final state = ref.watch(confirmResetCodeControllerProvider);

    // ─── Navigation / side-effect listener ───────────────────────────────
    ref.listen<ConfirmResetCodeState>(confirmResetCodeControllerProvider, (
      previous,
      next,
    ) {
      // Shake on error
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        _triggerShake();
      }

      // Navigate forward on success
      if (previous != null && !previous.didSucceed && next.didSucceed) {
        ref.read(confirmResetCodeControllerProvider.notifier).resetSuccess();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ResetPasswordScreen(email: widget.email),
          ),
        );
      }

      // Restart timer when resend succeeded
      if (next.resendSucceeded && !(previous?.resendSucceeded ?? false)) {
        ref.read(confirmResetCodeControllerProvider.notifier).resetResend();
        _startTimer();
      }
    });

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              colors.background,
              colors.surfaceContainerLow,
              colors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // ── top bar ──────────────────────────────────────────
                    const LoginScreenActions(),
                    const SizedBox(height: 32),

                    // ── logo + title ─────────────────────────────────────
                    const AuthHeader(
                      titleKey: 'confirmResetCodeTitle',
                      subtitleKey: 'confirmResetCodeSubtitle',
                    ),

                    // ── email chip ───────────────────────────────────────
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colors.primary.withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          widget.email,
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── form card ────────────────────────────────────────
                    AppCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // ── error banner ────────────────────────────
                            if (state.errorMessage != null) ...<Widget>[
                              AnimatedOpacity(
                                opacity: 1,
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.errorContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    context.l10n.translate(state.errorMessage!),
                                    style: TextStyle(
                                      color: colors.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // ── PIN input with shake ─────────────────────
                            AnimatedBuilder(
                              animation: _shakeAnimation,
                              builder: (context, child) => Transform.translate(
                                offset: Offset(_shakeAnimation.value, 0),
                                child: child,
                              ),
                              child: PinCodeTextField(
                                appContext: context,
                                length: 6,
                                controller: _pinController,
                                keyboardType: TextInputType.number,
                                animationType: AnimationType.fade,
                                enableActiveFill: true,
                                cursorColor: colors.primary,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(12),
                                  fieldHeight: 52,
                                  fieldWidth: 48,
                                  activeColor: colors.primary,
                                  selectedColor: colors.primary,
                                  inactiveColor: colors.outlineVariant,
                                  activeFillColor: colors.surfaceContainerLow,
                                  selectedFillColor: colors.surfaceContainerLow,
                                  inactiveFillColor: colors.surfaceContainerLow,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return context.l10n.translate(
                                      'validationOtpRequired',
                                    );
                                  }
                                  if (value.length != 6) {
                                    return context.l10n.translate(
                                      'validationOtpLength',
                                    );
                                  }
                                  return null;
                                },
                                onChanged: (value) => ref
                                    .read(
                                      confirmResetCodeControllerProvider
                                          .notifier,
                                    )
                                    .setCode(value),
                                onCompleted: (_) => _confirm(),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── resend row ───────────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  context.l10n.translate('didNotReceiveCode'),
                                ),
                                state.isResending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: _canResend ? _resend : null,
                                        child: Text(
                                          _canResend
                                              ? context.l10n.translate('resend')
                                              : '$_secondsRemaining s',
                                        ),
                                      ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── confirm button ───────────────────────────
                            AppButton(
                              label: context.l10n.translate(
                                'confirmCodeButton',
                              ),
                              isLoading: state.isSubmitting,
                              onPressed: _pinController.text.length == 6
                                  ? _confirm
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
