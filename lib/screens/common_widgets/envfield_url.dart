import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';
import 'package:apidash/consts.dart';
import 'env_trigger_field.dart';

class EnvURLField extends StatelessWidget {
  const EnvURLField({
    super.key,
    required this.selectedId,
    this.initialValue,
    this.onChanged,
    this.onFieldSubmitted,
  });

  final String selectedId;
  final String? initialValue;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 64),
      child: EnvironmentTriggerField(
        keyId: "url-$selectedId",
        initialValue: initialValue,
        style: const TextStyle(fontSize: 14),
        maxLines: null,
        decoration: InputDecoration(
          hintText: kHintTextUrlCard,
          hintStyle: kCodeStyle.copyWith(
            color: Theme.of(context).colorScheme.outline.withOpacity(
                  kHintOpacity,
                ),
          ),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        optionsWidthFactor: 1,
      ),
    );
  }
}
