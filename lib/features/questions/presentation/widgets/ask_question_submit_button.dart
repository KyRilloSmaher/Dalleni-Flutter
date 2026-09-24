import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_button.dart';

class AskQuestionSubmitButton extends StatelessWidget {
  const AskQuestionSubmitButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AppButton(
        label: isSubmitting
            ? l10n.translate('askSubmitting')
            : l10n.translate('askSubmitButton'),
        isLoading: isSubmitting,
        icon: isSubmitting
            ? null
            : Icon(
                Icons.send_rounded,
                color: colors.onPrimary,
                size: 20,
              ),
        onPressed: onPressed,
      ),
    );
  }
}
