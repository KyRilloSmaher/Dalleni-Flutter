import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/sign_up_provider.dart';
import 'profile_image_picker.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.userNameController,
    required this.emailController,
    required this.passwordController,
    required this.phoneNumberController,
    required this.state,
    required this.onFirstNameChanged,
    required this.onLastNameChanged,
    required this.onUserNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onPhoneNumberChanged,
    required this.onPickImage,
    required this.onSubmit,
    required this.onShowLogin,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneNumberController;
  final SignUpFormState state;
  final ValueChanged<String> onFirstNameChanged;
  final ValueChanged<String> onLastNameChanged;
  final ValueChanged<String> onUserNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onPhoneNumberChanged;
  final VoidCallback onPickImage;
  final VoidCallback onSubmit;
  final VoidCallback onShowLogin;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: AppTextField(
                  controller: firstNameController,
                  labelText: context.l10n.translate('firstNameLabel'),
                  hintText: context.l10n.translate('firstNameHint'),
                  textInputAction: TextInputAction.next,
                  onChanged: onFirstNameChanged,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.translate(
                        'validationFirstNameRequired',
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: lastNameController,
                  labelText: context.l10n.translate('lastNameLabel'),
                  hintText: context.l10n.translate('lastNameHint'),
                  textInputAction: TextInputAction.next,
                  onChanged: onLastNameChanged,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.translate(
                        'validationLastNameRequired',
                      );
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: userNameController,
            labelText: context.l10n.translate('userNameLabel'),
            hintText: context.l10n.translate('userNameHint'),
            textInputAction: TextInputAction.next,
            onChanged: onUserNameChanged,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return context.l10n.translate('validationUserNameRequired');
              }
              return null;
            },
            prefixIcon: Icon(Icons.badge_outlined, color: colors.tertiary),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: emailController,
            labelText: context.l10n.translate('emailLabel'),
            hintText: context.l10n.translate('emailHint'),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: onEmailChanged,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return context.l10n.translate('validationEmailRequired');
              }

              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegex.hasMatch(value.trim())) {
                return context.l10n.translate('validationEmailInvalid');
              }

              return null;
            },
            prefixIcon: Icon(
              Icons.alternate_email_rounded,
              color: colors.tertiary,
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: passwordController,
            labelText: context.l10n.translate('passwordLabel'),
            hintText: context.l10n.translate('passwordHint'),
            obscureText: true,
            textInputAction: TextInputAction.next,
            onChanged: onPasswordChanged,
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
          const SizedBox(height: 16),
          AppTextField(
            controller: phoneNumberController,
            labelText: context.l10n.translate('phoneNumberLabel'),
            hintText: context.l10n.translate('phoneNumberHint'),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onChanged: onPhoneNumberChanged,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return null;
              }

              final phoneRegex = RegExp(r'^[0-9+\-\s]{7,20}$');
              if (!phoneRegex.hasMatch(value.trim())) {
                return context.l10n.translate('validationPhoneNumberInvalid');
              }

              return null;
            },
            prefixIcon: Icon(Icons.phone_outlined, color: colors.tertiary),
          ),
          const SizedBox(height: 16),
          ProfileImagePicker(
            imagePath: state.profileImagePath,
            onPickImage: onPickImage,
          ),
          const SizedBox(height: 20),
          AppButton(
            label: context.l10n.translate('signUpButton'),
            isLoading: state.isSubmitting,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.translate('loginPrompt'),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: onShowLogin,
            child: Text(context.l10n.translate('loginAction')),
          ),
        ],
      ),
    );
  }
}
