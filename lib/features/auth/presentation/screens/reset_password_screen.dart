import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/reset_password_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/login_screen_actions.dart';
import 'login_screen.dart';

/// Screen 3 — the final step of the forgot-password flow.
/// Accepts [newPassword] + [confirmPassword] (UI-only) then calls
/// POST /api/auth/reset-password.  On success, pops the entire flow
/// and returns to [AuthFlowScreen] (login).
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  /// Email carried forward from Screen 1 — sent to the API.
  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(resetPasswordControllerProvider.notifier)
        .submit(email: widget.email);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final state = ref.watch(resetPasswordControllerProvider);

    // ─── Navigation listener ─────────────────────────────────────────────
    ref.listen<ResetPasswordState>(resetPasswordControllerProvider, (
      previous,
      next,
    ) {
      if (previous != null && !previous.didSucceed && next.didSucceed) {
        ref.read(resetPasswordControllerProvider.notifier).resetSuccess();

        // Show a brief success snackbar then navigate all the way to login.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.translate('passwordResetSuccess')),
            backgroundColor: colors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
          (_) => false,
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
                    // ── top bar ──────────────────────────────────────────
                    const LoginScreenActions(),
                    const SizedBox(height: 32),

                    // ── logo + title ─────────────────────────────────────
                    const AuthHeader(
                      titleKey: 'resetPasswordTitle',
                      subtitleKey: 'resetPasswordSubtitle',
                    ),
                    const SizedBox(height: 24),

                    // ── form card ────────────────────────────────────────
                    AppCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // ── error banner ─────────────────────────────
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

                            // ── new password ─────────────────────────────
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: state.obscurePassword,
                              textInputAction: TextInputAction.next,
                              onChanged: ref
                                  .read(
                                    resetPasswordControllerProvider.notifier,
                                  )
                                  .setNewPassword,
                              decoration: InputDecoration(
                                labelText: context.l10n.translate(
                                  'newPasswordLabel',
                                ),
                                hintText: context.l10n.translate(
                                  'newPasswordHint',
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: colors.onSurfaceVariant,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    state.obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  onPressed: ref
                                      .read(
                                        resetPasswordControllerProvider
                                            .notifier,
                                      )
                                      .toggleObscurePassword,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return context.l10n.translate(
                                    'validationPasswordRequired',
                                  );
                                }
                                if (value.length < 6) {
                                  return context.l10n.translate(
                                    'validationPasswordMinLength',
                                  );
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── confirm password ─────────────────────────
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: state.obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onChanged: ref
                                  .read(
                                    resetPasswordControllerProvider.notifier,
                                  )
                                  .setConfirmPassword,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: context.l10n.translate(
                                  'confirmPasswordLabel',
                                ),
                                hintText: context.l10n.translate(
                                  'confirmPasswordHint',
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: colors.onSurfaceVariant,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    state.obscureConfirm
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  onPressed: ref
                                      .read(
                                        resetPasswordControllerProvider
                                            .notifier,
                                      )
                                      .toggleObscureConfirm,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return context.l10n.translate(
                                    'validationPasswordRequired',
                                  );
                                }
                                if (value != _newPasswordController.text) {
                                  return context.l10n.translate(
                                    'validationPasswordMismatch',
                                  );
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // ── submit button ─────────────────────────────
                            AppButton(
                              label: context.l10n.translate(
                                'resetPasswordButton',
                              ),
                              isLoading: state.isSubmitting,
                              onPressed: state.isSubmitting ? null : _submit,
                            ),

                            const SizedBox(height: 16),

                            // ── back to login ─────────────────────────────
                            Center(
                              child: TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                      (_) => false,
                                    ),
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
