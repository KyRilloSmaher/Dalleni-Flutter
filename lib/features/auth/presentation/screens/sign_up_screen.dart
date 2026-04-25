import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../providers/sign_up_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/login_screen_actions.dart';
import '../widgets/sign_up_form.dart';
import 'verify_identity_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key, this.onShowLogin});

  final VoidCallback? onShowLogin;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _userNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    final currentState =
        ref.read(signUpControllerProvider).valueOrNull ??
        SignUpFormState.initial();
    _firstNameController = TextEditingController(text: currentState.firstName);
    _lastNameController = TextEditingController(text: currentState.lastName);
    _userNameController = TextEditingController(text: currentState.userName);
    _emailController = TextEditingController(text: currentState.email);
    _passwordController = TextEditingController(text: currentState.password);
    _phoneNumberController = TextEditingController(
      text: currentState.phoneNumber,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SignUpFormState>>(signUpControllerProvider, (
      previous,
      next,
    ) async {
      final state = next.valueOrNull;
      if (state == null || !state.didComplete || !mounted) {
        return;
      }

      ref.read(signUpControllerProvider.notifier).resetCompletion();
      final localizations = AppLocalizations.of(context);
      final navigator = Navigator.of(context);

      await showDialog<void>(
        context: navigator.context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(localizations.translate('otpSentDialogTitle')),
            content: Text(localizations.translate('otpSentDialogMessage')),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(localizations.translate('okButton')),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => VerifyIdentityScreen(email: state.email),
        ),
      );
    });

    final signUpState = ref.watch(signUpControllerProvider);
    final colors = context.dalleniColors;

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
          child: signUpState.when(
            loading: AppLoadingState.new,
            error: (_, _) => AppErrorState(
              message: context.l10n.translate('genericError'),
              onRetry: () => ref.invalidate(signUpControllerProvider),
            ),
            data: (state) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const LoginScreenActions(),
                        const SizedBox(height: 32),
                        const AuthHeader(
                          titleKey: 'signUpTitle',
                          subtitleKey: 'signUpSubtitle',
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
                                    _resolveMessage(
                                      context,
                                      state.errorMessage!,
                                    ),
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
                              SignUpForm(
                                formKey: _formKey,
                                firstNameController: _firstNameController,
                                lastNameController: _lastNameController,
                                userNameController: _userNameController,
                                emailController: _emailController,
                                passwordController: _passwordController,
                                phoneNumberController: _phoneNumberController,
                                state: state,
                                onFirstNameChanged: (value) {
                                  ref
                                      .read(signUpControllerProvider.notifier)
                                      .setFirstName(value);
                                },
                                onLastNameChanged: (value) {
                                  ref
                                      .read(signUpControllerProvider.notifier)
                                      .setLastName(value);
                                },
                                onUserNameChanged: (value) {
                                  ref
                                      .read(signUpControllerProvider.notifier)
                                      .setUserName(value);
                                },
                                onEmailChanged: (value) {
                                  ref
                                      .read(signUpControllerProvider.notifier)
                                      .setEmail(value);
                                },
                                onPasswordChanged: (value) {
                                  ref
                                      .read(signUpControllerProvider.notifier)
                                      .setPassword(value);
                                },
                                onPhoneNumberChanged: (value) {
                                  ref
                                      .read(signUpControllerProvider.notifier)
                                      .setPhoneNumber(value);
                                },
                                onPickImage: () {
                                  ref
                                      .read(signUpControllerProvider.notifier)
                                      .pickProfileImage(context);
                                },
                                onSubmit: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    ref
                                        .read(signUpControllerProvider.notifier)
                                        .submit();
                                  }
                                },
                                onShowLogin: widget.onShowLogin ?? () {},
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

  String _resolveMessage(BuildContext context, String message) {
    const localizableKeys = <String>{
      'genericError',
      'networkTimeout',
      'profileImagePickerError',
    };

    if (localizableKeys.contains(message)) {
      return context.l10n.translate(message);
    }

    return message;
  }
}
