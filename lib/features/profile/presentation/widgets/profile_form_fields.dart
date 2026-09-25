

import 'package:dalleni/core/localization/app_localizations.dart';
import 'package:dalleni/core/theme/dalleni_theme.dart';
import 'package:dalleni/core/widgets/app_card.dart';
import 'package:dalleni/core/widgets/app_text_field.dart';
import 'package:dalleni/features/profile/presentation/providers/profile_controller.dart';
import 'package:flutter/material.dart';

class ProfileFormFields extends StatelessWidget {
  const ProfileFormFields({
    required this.firstNameController,
    required this.lastNameController,
    required this.userNameController,
    required this.phoneController,
    required this.bioController,
    required this.controller,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController userNameController;
  final TextEditingController phoneController;
  final TextEditingController bioController;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        children: [
          AppTextField(
            controller: firstNameController,
            labelText: l10n.translate('firstNameLabel'),
            hintText: l10n.translate('firstNameHint'),
            textInputAction: TextInputAction.next,
            validator: (value) {
              final errorKey = controller.validateFirstName(value);
              return errorKey != null ? l10n.translate(errorKey) : null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: lastNameController,
            labelText: l10n.translate('lastNameLabel'),
            hintText: l10n.translate('lastNameHint'),
            textInputAction: TextInputAction.next,
            validator: (value) {
              final errorKey = controller.validateLastName(value);
              return errorKey != null ? l10n.translate(errorKey) : null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: userNameController,
            labelText: l10n.translate('userNameLabel'),
            hintText: l10n.translate('userNameHint'),
            textInputAction: TextInputAction.next,
            validator: (value) {
              final errorKey = controller.validateUserName(value);
              return errorKey != null ? l10n.translate(errorKey) : null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: phoneController,
            labelText: l10n.translate('phoneNumberLabel'),
            hintText: l10n.translate('phoneNumberHint'),
            textInputAction: TextInputAction.next,
            prefixIcon: Icon(
              Icons.phone_outlined,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: bioController,
            labelText: l10n.translate('bioLabel'),
            hintText: l10n.translate('bioHint'),
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}
