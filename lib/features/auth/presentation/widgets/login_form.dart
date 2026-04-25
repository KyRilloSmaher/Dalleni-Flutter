import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/login_provider.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    required this.state,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
    required this.onGoogleLogin,
    this.onShowSignUp,
    this.onForgotPassword,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final LoginFormState state;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;
  final VoidCallback onGoogleLogin;
  final VoidCallback? onShowSignUp;
  final VoidCallback? onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppTextField(
              controller: emailController,
              labelText: context.l10n.translate('emailLabel'),
              hintText: context.l10n.translate('emailHint'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[
                AutofillHints.username,
                AutofillHints.email,
              ],
              onChanged: onEmailChanged,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.translate('validationEmailRequired');
                }
                return null;
              },
              prefixIcon: Icon(
                Icons.alternate_email_rounded,
                color: colors.tertiary,
              ),
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: passwordController,
              labelText: context.l10n.translate('passwordLabel'),
              hintText: context.l10n.translate('passwordHint'),
              obscureText: true,
              enableObscureToggle: true,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.password],
              onChanged: onPasswordChanged,
              onSubmitted: (_) => onSubmit(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.translate('validationPasswordRequired');
                }
                if (value.length < 6) {
                  return context.l10n.translate('validationPasswordMinLength');
                }
                return null;
              },
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: colors.tertiary,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onForgotPassword,
                child: Text(context.l10n.translate('forgotPassword')),
              ),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: context.l10n.translate('loginButton'),
              isLoading: state.isSubmitting,
              onPressed: onSubmit,
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(child: Divider(color: colors.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    context.l10n.translate('orDivider'),
                    style: textTheme.bodyMedium,
                  ),
                ),
                Expanded(child: Divider(color: colors.outlineVariant)),
              ],
            ),
            const SizedBox(height: 24),
            AppButton(
              label: context.l10n.translate('googleLoginButton'),
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
              glowColor: colors.error.withValues(alpha: 0.24),
              icon: _GoogleBadge(colors: colors, textTheme: textTheme),
              onPressed: state.isSubmitting ? null : onGoogleLogin,
            ),
            const SizedBox(height: 18),
            Text(
              context.l10n.translate('registerPrompt'),
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: onShowSignUp,
              child: Text(context.l10n.translate('registerAction')),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleBadge extends StatelessWidget {
  const _GoogleBadge({
    required this.colors,
    required this.textTheme,
  });

  final DalleniColors colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.onError, shape: BoxShape.circle),
      child: Text(
        'G',
        style: textTheme.titleMedium?.copyWith(
          color: colors.error,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
