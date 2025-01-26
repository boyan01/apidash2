import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';
import 'env_trigger_field.dart';

class EnvCellField extends StatelessWidget {
  const EnvCellField({
    super.key,
    required this.keyId,
    this.initialValue,
    this.hintText,
    this.onChanged,
    this.colorScheme,
  });

  final String keyId;
  final String? initialValue;
  final String? hintText;
  final void Function(String)? onChanged;
  final ColorScheme? colorScheme;

  @override
  Widget build(BuildContext context) {
    var clrScheme = colorScheme ?? Theme.of(context).colorScheme;
    return EnvironmentTriggerField(
      keyId: keyId,
      initialValue: initialValue,
      style: TextStyle(
        color: clrScheme.onSurface,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintStyle: TextStyle(
          color: clrScheme.outline.withValues(
            alpha: kHintOpacity,
          ),
        ),
        hintText: hintText,
        contentPadding: const EdgeInsets.only(bottom: 12),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: clrScheme.primary.withValues(
              alpha: kHintOpacity,
            ),
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: clrScheme.surfaceContainerHighest,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
