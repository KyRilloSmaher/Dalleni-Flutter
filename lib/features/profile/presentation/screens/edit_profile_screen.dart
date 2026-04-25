import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../user/data/models/update_user_model.dart';
import '../providers/profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _userNameController;
  late TextEditingController _phoneController;
  // Note: Bio is currently not in the PUT endpoint UpdateUserAccount body, but we simulate it.
  late TextEditingController _bioController;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).profile;

    // Attempting to split FullName for FirstName/LastName if not natively provided that way by the GET endpoint
    final nameParts = profile?.fullName.split(' ') ?? [];
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _userNameController = TextEditingController(text: profile?.userName ?? '');
    _phoneController = TextEditingController(text: profile?.phoneNumber ?? '');
    _bioController = TextEditingController();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
      // Trigger upload right away so it behaves snappily, or wait for save?
      // Requirment says "Submit changes to backend". The API has a separated image upload endpoint.
      // We will do it together on save.
    }
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = ref.read(profileControllerProvider.notifier);
    final profile = ref.read(profileControllerProvider).profile;
    final l10n = context.l10n;

    if (profile == null) return;

    // Upload Image if changed
    if (_selectedImage != null) {
      final successImage = await controller.updateProfileImage(_selectedImage!);
      if (!successImage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Update Profile Information
    final updateRequest = UpdateUserAccount(
      id: profile.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      userName: _userNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    final successProfile = await controller.updateProfile(updateRequest);

    if (successProfile && mounted) {
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
    final colors = context.dalleniColors;
    final l10n = context.l10n;

    final profileImageUrl = state.profile?.profileImageUrl;

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
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: colors.surfaceContainerHighest,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!) as ImageProvider
                            : (profileImageUrl != null &&
                                      profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : null),
                        child:
                            _selectedImage == null &&
                                (profileImageUrl == null ||
                                    profileImageUrl.isEmpty)
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: colors.onSurfaceVariant,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.background,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: colors.onPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Form Section
                AppCard(
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _firstNameController,
                        labelText: l10n.translate('firstNameLabel'),
                        hintText: l10n.translate('firstNameHint'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.translate(
                              'validationFirstNameRequired',
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _lastNameController,
                        labelText: l10n.translate('lastNameLabel'),
                        hintText: l10n.translate('lastNameHint'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.translate('validationLastNameRequired');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Username Field
                      AppTextField(
                        controller: _userNameController,
                        labelText: l10n.translate('userNameLabel'),
                        hintText: l10n.translate('userNameHint'),
                        textInputAction: TextInputAction.next,
                        //prefixText: '@',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.translate('validationUserNameRequired');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Phone Number Field
                      AppTextField(
                        controller: _phoneController,
                        labelText: l10n.translate('phoneNumberLabel'),
                        hintText: l10n.translate('phoneNumberHint'),
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bio Field
                      AppTextField(
                        controller: _bioController,
                        labelText: l10n.translate('bioLabel'),
                        hintText: l10n.translate('bioHint'),
                        textInputAction: TextInputAction.done,
                        //maxLines: 3,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                AppButton(
                  label: l10n.translate('saveChangesButton'),
                  isLoading: state.isLoading,
                  onPressed: state.isLoading ? null : _onSave,
                ),

                const SizedBox(height: 16),

                // Info Card
                AppCard(
                  //  color: colors.primaryContainer.withOpacity(0.3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.translate('updateProfileInfoTitle'),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.translate('updateProfileInfoDesc'),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
