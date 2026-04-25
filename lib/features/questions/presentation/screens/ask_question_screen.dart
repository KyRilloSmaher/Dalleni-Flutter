import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/ask_question_controller.dart';
import '../../data/models/category_model.dart';

class AskQuestionScreen extends ConsumerStatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  ConsumerState<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends ConsumerState<AskQuestionScreen> {
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final FocusNode _queryFocusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();
  String? _selectedCategoryId;

  // Static suggestions as per user request (until a specific endpoint is provided)
  final List<String> _suggestions = [
    'كيف أجدد رخصة القيادة؟',
    'ما هي خطوات نقل ملكية المركبة؟',
    'إصدار سجل تجاري جديد',
  ];

  @override
  void dispose() {
    _queryController.dispose();
    _descController.dispose();
    _queryFocusNode.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final title = _queryController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.translate('askErrorNoTitle') ?? 'Please enter a title',
          ),
        ),
      );
      return;
    }

    final state = ref.read(askQuestionControllerProvider);
    final categoryId =
        _selectedCategoryId ??
        (state.categories.isNotEmpty ? state.categories[0].id : '');

    ref
        .read(askQuestionControllerProvider.notifier)
        .submitQuestion(
          title: title,
          content: _descController.text.trim(),
          categoryId: categoryId,
          tags: [], // Could be expanded later
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final state = ref.watch(askQuestionControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    // Success and Error listeners
    ref.listen(askQuestionControllerProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('askSuccessMessage') ?? 'Success'),
            backgroundColor: Colors
                .green, // Fix: Use theme colors if available, but SnackBar defaults are often handled by scaffoldMessenger
          ),
        );
        _queryController.clear();
        _descController.clear();
        ref.read(askQuestionControllerProvider.notifier).resetSuccess();
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      drawer: const AnimatedFunkyDrawer(),
      appBar: CommonGlassAppBar(title: l10n.translate('navAsk') ?? 'Ask'),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withOpacity(0.15),
              ),
            ),
          ),

          SafeArea(
            child: state.isLoading
                ? const AppLoadingState()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroSection(colors, textTheme, l10n),
                        const SizedBox(height: 32),

                        AppTextField(
                          controller: _queryController,
                          focusNode: _queryFocusNode,
                          hintText:
                              l10n.translate('askQueryHint') ??
                              'What are you looking for?',
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),

                        const SizedBox(height: 24),
                        _buildSmartSuggestions(colors, textTheme, l10n),

                        const SizedBox(height: 24),
                        _buildCategoryChips(colors, state),

                        const SizedBox(height: 24),
                        AppTextField(
                          controller: _descController,
                          focusNode: _descFocusNode,
                          hintText:
                              l10n.translate('askDetailsHint') ??
                              'Add more details...',
                          prefixIcon: const Icon(Icons.description_outlined),
                          maxLines: 4,
                        ),

                        const SizedBox(height: 48),
                        AppButton(
                          label: state.isSubmitting
                              ? (l10n.translate('askSubmitting') ??
                                    'Sending...')
                              : (l10n.translate('askSubmitButton') ?? 'Submit'),
                          isLoading: state.isSubmitting,
                          icon: state.isSubmitting
                              ? null
                              : Icon(
                                  Icons.send_rounded,
                                  color: colors.onPrimary,
                                  size: 20,
                                ),
                          onPressed: _handleSubmit,
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    DalleniColors colors,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.primary.withOpacity(0.3)),
          ),
          child: Text(
            l10n.translate('askHeroBadge') ?? 'ASSISTANT',
            style: textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.translate('askHeroTitle') ?? "Ask about any service...",
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.translate('askHeroSubtitle') ??
              "We are here to simplify procedures and guide you step by step.",
          style: textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant.withOpacity(0.8),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSmartSuggestions(
    DalleniColors colors,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 18, color: colors.primary),
            const SizedBox(width: 8),
            Text(
              l10n.translate('askSmartSuggestions') ?? "Smart Suggestions",
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: _suggestions.map((suggestion) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.outlineVariant.withOpacity(0.2),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  highlightColor: colors.primary.withOpacity(0.1),
                  splashColor: colors.primary.withOpacity(0.2),
                  onTap: () {
                    setState(() {
                      _queryController.text = suggestion;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            suggestion,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(DalleniColors colors, AskQuestionState state) {
    if (state.categories.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: state.categories.map((category) {
          final isSelected =
              _selectedCategoryId == category.id ||
              (_selectedCategoryId == null &&
                  state.categories.indexOf(category) == 0);
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8.0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryId = category.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary
                      : colors.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? colors.primary
                        : colors.outlineVariant.withOpacity(0.3),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
