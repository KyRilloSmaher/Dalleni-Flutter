import 'package:flutter/material.dart';
import '../theme/dalleni_theme.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.controller,
    required this.hintText,
    super.key,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.maxLines = 1,
    this.focusNode,
    this.autofillHints,
    this.enableObscureToggle = false,
  });

  final TextEditingController controller;
  final String? labelText;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final bool enableObscureToggle;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _effectiveFocusNode;
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveFocusNode.addListener(_handleFocusChange);
    _isObscured = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    } else {
      _effectiveFocusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final isFocused = _effectiveFocusNode.hasFocus;
    final showSuffix = widget.suffixIcon != null || widget.enableObscureToggle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCirc,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh.withValues(
              alpha: isFocused ? 0.94 : 0.78,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFocused ? colors.primary : colors.outlineVariant,
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                colors.surfaceContainerHighest.withValues(alpha: 0.95),
                colors.surfaceContainerLow.withValues(alpha: 0.86),
              ],
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: colors.primaryGlow,
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _effectiveFocusNode,
            obscureText: _isObscured,
            autofillHints: widget.autofillHints,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            onFieldSubmitted: widget.onSubmitted,
            onChanged: widget.onChanged,
            maxLines: widget.maxLines,
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: colors.onSurfaceVariant.withValues(alpha: 0.72),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        bottom: widget.maxLines > 1 ? 70.0 : 0,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          color: isFocused
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                        child: widget.prefixIcon!,
                      ),
                    )
                  : null,
              suffixIcon: showSuffix
                  ? Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: widget.enableObscureToggle
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                              icon: Icon(
                                _isObscured
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: isFocused
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                              ),
                            )
                          : IconTheme(
                              data: IconThemeData(
                                color: isFocused
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                              ),
                              child: widget.suffixIcon!,
                            ),
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: colors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: colors.error, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: widget.maxLines > 1 ? 18 : 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
