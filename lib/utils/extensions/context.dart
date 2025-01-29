import 'package:apidash/generated/l10n.dart';
import 'package:flutter/widgets.dart';

extension ContextExt on BuildContext {
  Localization get strings =>
      Localization.maybeOf(this) ?? Localization.current;
}
