import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';
import 'package:apidash/consts.dart';

class SendButton extends StatelessWidget {
  const SendButton({
    super.key,
    required this.isWorking,
    required this.onTap,
    this.onCancel,
  });

  final bool isWorking;
  final void Function() onTap;
  final void Function()? onCancel;

  @override
  Widget build(BuildContext context) {
    return ADFilledButton(
      onPressed: isWorking ? onCancel : onTap,
      isTonal: isWorking ? true : false,
      buttonStyle: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 2,
        )),
        minimumSize: WidgetStatePropertyAll(
          Size(24, 24),
        ),
      ),
      items: isWorking
          ? const [
              Icon(
                size: 16,
                Icons.close,
              ),
            ]
          : const [
              Icon(
                size: 16,
                Icons.send,
              ),
            ],
    );
  }
}
