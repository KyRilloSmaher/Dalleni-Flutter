import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_text_field.dart';

class HomeFeedSearchBarWidget extends StatelessWidget {
  const HomeFeedSearchBarWidget({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return SliverToBoxAdapter(
      child: Container(
        color: colors.surface,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: AppTextField(
          controller: controller,
          labelText: context.l10n.translate('homeSearchLabel'),
          hintText: context.l10n.translate('homeSearchHint'),
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: onClearSearch,
                )
              : null,
          onChanged: onSearchChanged,
        ),
      ),
    );
  }
}
