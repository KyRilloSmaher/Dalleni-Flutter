import 'package:dalleni/features/profile/presentation/widgets/prifile_Avatar_picker.dart';
import 'package:dalleni/features/profile/presentation/widgets/profie_info_card.dart';
import 'package:dalleni/features/profile/presentation/widgets/profile_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _userNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(profileControllerProvider);

    _firstNameController = TextEditingController(text: state.firstName);
    _lastNameController = TextEditingController(text: state.lastName);
    _userNameController = TextEditingController(text: state.userName);
    _phoneController = TextEditingController(text: state.phoneNumber);
    _bioController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).clearSelectedImage();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = ref.read(profileControllerProvider.notifier);
    final l10n = context.l10n;

    final success = await controller.saveProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      userName: _userNameController.text,
      phoneNumber: _phoneController.text,
      bio: _bioController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('profileUpdateSuccess')),
          backgroundColor: context.dalleniColors.primary,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    final colors = context.dalleniColors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.translate('updateProfileButton')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error banner
                if (state.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(color: colors.onErrorContainer),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Profile Image Selection
                ProfileAvatarPicker(
                  state: state,
                  onPickImage: controller.pickProfileImage,
                ),
                const SizedBox(height: 32),

                // Form Section
                ProfileFormFields(
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  userNameController: _userNameController,
                  phoneController: _phoneController,
                  bioController: _bioController,
                  controller: controller,
                ),

                const SizedBox(height: 32),

                // Submit Button
                AppButton(
                  label: l10n.translate('saveChangesButton'),
                  isLoading: state.isLoading,
                  onPressed: state.isLoading ? null : _handleSave,
                ),

                const SizedBox(height: 16),

                // Info Card
                const ProfileInfoCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

