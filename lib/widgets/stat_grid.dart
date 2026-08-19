import 'package:flutter/material.dart';

/// Lays out [StatCard]s (or similar KPI tiles) in a 2-column grid.
///
/// Deliberately does NOT use `GridView` with a fixed/derived row height —
/// that requires guessing a pixel height that fits the content, which
/// breaks the moment a label wraps to another line or the device uses a
/// larger text scale (this is what caused the earlier overflow bugs).
/// Instead each row is a plain [Row] of [Expanded] children wrapped in
/// [IntrinsicHeight], so row height is always exactly whatever the tallest
/// card in that row needs.
class StatGrid extends StatelessWidget {
  final List<Widget> children;

  const StatGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      final hasSecond = i + 1 < children.length;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: 12),
              Expanded(child: hasSecond ? children[i + 1] : const SizedBox.shrink()),
            ],
          ),
        ),
      );
      if (i + 2 < children.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }
}
