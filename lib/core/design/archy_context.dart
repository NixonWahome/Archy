import 'package:flutter/material.dart';
import 'archy_tokens.dart';

/// Convenience accessor: `context.archy` returns the active Archy palette based
/// on the current theme brightness. Lets screens pull tokens without threading
/// `isDarkMode` through constructors.
extension ArchyContext on BuildContext {
  ArchyColors get archy => Theme.of(this).brightness == Brightness.dark
      ? ArchyColors.dark
      : ArchyColors.light;
}
