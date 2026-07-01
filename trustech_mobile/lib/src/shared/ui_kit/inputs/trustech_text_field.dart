import 'package:flutter/material.dart';

import '../../../core/constants/app_typography.dart';

/// App-wide text field. Renders a label above a themed [TextFormField],
/// with built-in password visibility toggle, prefix/suffix slots and
/// validation error display. Colours come from the active [InputDecorationTheme].
class TrustechTextField extends StatefulWidget {
  const TrustechTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.errorText,
    this.enabled = true,
    this.autofillHints,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final String? errorText;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final int maxLines;

  @override
  State<TrustechTextField> createState() => _TrustechTextFieldState();
}

class _TrustechTextFieldState extends State<TrustechTextField> {
  late bool _obscure = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final suffix = widget.suffixIcon ??
        (widget.obscureText
            ? IconButton(
                onPressed: widget.enabled
                    ? () => setState(() => _obscure = !_obscure)
                    : null,
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
              )
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TrustechTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          autofillHints: widget.autofillHints,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          style: TextStyle(fontFamily: TrustechTypography.fontFamily, color: cs.onSurface),
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20)
                : null,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
