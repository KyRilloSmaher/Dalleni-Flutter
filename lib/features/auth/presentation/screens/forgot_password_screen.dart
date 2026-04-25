import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/forgot_password_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/login_screen_actions.dart';
import 'confirm_reset_code_screen.dart';

/// Screen 1 of the forgot-password flow.
/// Accepts an email and calls POST /api/auth/send-reset-code.
/// On success it pushes [ConfirmResetCodeScreen].
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(forgotPasswordControllerProvider.notifier).submit();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final state = ref.watch(forgotPasswordControllerProvider);

    // ─── Navigation listener ─────────────────────────────────────────────
    ref.listen<ForgotPasswordState>(forgotPasswordControllerProvider, (
      previous,
      next,
    ) {
      if (previous != null && !previous.didSucceed && next.didSucceed) {
        // Reset flag so re-entering the screen works cleanly
        ref.read(forgotPasswordControllerProvider.notifier).resetSuccess();

        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ConfirmResetCodeScreen(email: state.email),
          ),
        );
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
                    // ── top bar (language / theme toggles) ──────────────
                    const LoginScreenActions(),
                    const SizedBox(height: 32),

                    // ── logo + title ────────────────────────────────────
                    const AuthHeader(
                      titleKey: 'forgotPasswordTitle',
                      subtitleKey: 'forgotPasswordSubtitle',
                    ),
                    const SizedBox(height: 24),

                    // ── form card ───────────────────────────────────────
                    AppCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // ── error banner ──────────────────────────
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

                            // ── email field ───────────────────────────
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autocorrect: false,
                              onChanged: ref
                                  .read(
                                    forgotPasswordControllerProvider.notifier,
                                  )
                                  .setEmail,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: context.l10n.translate('emailLabel'),
                                hintText: context.l10n.translate('emailHint'),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return context.l10n.translate(
                                    'validationEmailRequired',
                                  );
                                }
                                final emailRegex = RegExp(
                                  r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$',
                                );
                                if (!emailRegex.hasMatch(value.trim())) {
                                  return context.l10n.translate(
                                    'validationEmailInvalid',
                                  );
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // ── submit button ─────────────────────────
                            AppButton(
                              label: context.l10n.translate(
                                'sendResetCodeButton',
                              ),
                              isLoading: state.isSubmitting,
                              onPressed: state.isSubmitting ? null : _submit,
                            ),

                            const SizedBox(height: 16),

                            // ── back to login ─────────────────────────
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  context.l10n.translate('backToLogin'),
                                  style: TextStyle(color: colors.primary),
                                ),
                              ),
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
