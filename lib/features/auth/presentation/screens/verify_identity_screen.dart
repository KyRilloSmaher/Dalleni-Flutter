import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/otp_controller.dart';
import '../widgets/auth_header.dart';
import '../../../../core/widgets/language_theme_bar.dart';
import 'auth_flow_screen.dart';

class VerifyIdentityScreen extends ConsumerStatefulWidget {
  const VerifyIdentityScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyIdentityScreen> createState() =>
      _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends ConsumerState<VerifyIdentityScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _otpController;

  /// ================= TIMER =================
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;

  /// ================= ANIMATION =================
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();

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

  void _triggerErrorAnimation() {
    _shakeController.forward(from: 0);
  }

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

  void _verifyOtp() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final otp = _otpController.text;

    ref.read(otpControllerProvider.notifier).setCode(otp);

    ref.read(otpControllerProvider.notifier).verify(email: widget.email);
  }

  void _resendOtp() {
    // TODO: call resend API
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final otpState = ref.watch(otpControllerProvider);

    /// ================= LISTENER =================
    ref.listen<OtpState>(otpControllerProvider, (previous, next) {
      /// SUCCESS
      if (previous != null &&
          previous.isSubmitting &&
          !next.isSubmitting &&
          next.errorMessage == null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthFlowScreen()),
          (_) => false,
        );
      }

      /// ERROR → trigger animation
      if (next.errorMessage != null) {
        _triggerErrorAnimation();
      }
    });

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
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
                  children: [
                    const LanguageThemeBar(),
                    const SizedBox(height: 32),

                    const AuthHeader(
                      titleKey: 'verifyIdentityTitle',
                      subtitleKey: 'verifyIdentitySubtitle',
                    ),

                    const SizedBox(height: 24),

                    AppCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// ================= ERROR =================
                            if (otpState.errorMessage != null) ...[
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
                                    otpState.errorMessage!,
                                    style: TextStyle(
                                      color: colors.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            /// ================= OTP INPUT (SHAKE) =================
                            AnimatedBuilder(
                              animation: _shakeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(_shakeAnimation.value, 0),
                                  child: child,
                                );
                              },
                              child: PinCodeTextField(
                                appContext: context,
                                length: 6,
                                controller: _otpController,
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

                                onCompleted: (_) => _verifyOtp(),
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// ================= RESEND =================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  context.l10n.translate('didNotReceiveCode'),
                                ),
                                TextButton(
                                  onPressed: _canResend ? _resendOtp : null,
                                  child: Text(
                                    _canResend
                                        ? context.l10n.translate('resend')
                                        : '$_secondsRemaining s',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            /// ================= VERIFY BUTTON =================
                            AppButton(
                              label: context.l10n.translate('verifyButton'),
                              isLoading: otpState.isSubmitting,
                              onPressed: _otpController.text.length == 6
                                  ? _verifyOtp
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
