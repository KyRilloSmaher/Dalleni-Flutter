import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../providers/login_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/login_form.dart';
import '../../../../core/app/app_entry_controller.dart';
import '../../../../core/widgets/language_theme_bar.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.onShowSignUp});

  final VoidCallback? onShowSignUp;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final currentState =
        ref.read(loginControllerProvider).valueOrNull ??
        LoginFormState.initial();
    _emailController = TextEditingController(text: currentState.email);
    _passwordController = TextEditingController(text: currentState.password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final colors = context.dalleniColors;

    ref.listen(loginControllerProvider, (previous, next) {
      if (next.valueOrNull?.session != null) {
        ref.read(appEntryControllerProvider.notifier).completeLogin();
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
          child: loginState.when(
            loading: AppLoadingState.new,
            error: (_, _) => AppErrorState(
              message: context.l10n.translate('genericError'),
              onRetry: () => ref.invalidate(loginControllerProvider),
            ),
            data: (state) {
              if (!state.isReady) {
                return AppEmptyState(
                  title: context.l10n.translate('loginEmptyTitle'),
                  subtitle: context.l10n.translate('loginEmptySubtitle'),
                );
              }

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const LanguageThemeBar(),
                        const SizedBox(height: 32),
                        const AuthHeader(
                          titleKey: 'loginTitle',
                          subtitleKey: 'loginSubtitle',
                        ),
                        const SizedBox(height: 24),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              if (state.errorMessage != null) ...<Widget>[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colors.errorContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    state.errorMessage!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colors.onErrorContainer,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              LoginForm(
                                emailController: _emailController,
                                passwordController: _passwordController,
                                formKey: _formKey,
                                state: state,
                                onEmailChanged: (value) {
                                  ref
                                      .read(loginControllerProvider.notifier)
                                      .setEmail(value);
                                },
                                onPasswordChanged: (value) {
                                  ref
                                      .read(loginControllerProvider.notifier)
                                      .setPassword(value);
                                },
                                onSubmit: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    ref
                                        .read(loginControllerProvider.notifier)
                                        .submit(
                                          context,
                                          identifier: _emailController.text,
                                          password: _passwordController.text,
                                        );
                                  }
                                },
                                onGoogleLogin: () {
                                  ref
                                      .read(loginControllerProvider.notifier)
                                      .loginWithGoogle(context);
                                },
                                onShowSignUp: widget.onShowSignUp,
                                onForgotPassword: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
