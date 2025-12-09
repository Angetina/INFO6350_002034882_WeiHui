// lib/yes_no_selection.dart

import 'package:flutter/material.dart';

import 'app_state.dart';

class YesNoSelection extends StatelessWidget {
  const YesNoSelection({
    super.key,
    required this.state,
    required this.onSelection,
  });

  /// 目前出席狀態
  final Attending state;

  /// 使用者按下 YES / NO 時要做的事
  final void Function(Attending selection) onSelection;

  @override
  Widget build(BuildContext context) {
    // 依照目前狀態，把其中一個按鈕畫成「比較亮」
    switch (state) {
      case Attending.yes:
        return _buildRow(
          yesButton: FilledButton(
            onPressed: () => onSelection(Attending.yes),
            child: const Text('YES'),
          ),
          noButton: TextButton(
            onPressed: () => onSelection(Attending.no),
            child: const Text('NO'),
          ),
        );

      case Attending.no:
        return _buildRow(
          yesButton: TextButton(
            onPressed: () => onSelection(Attending.yes),
            child: const Text('YES'),
          ),
          noButton: FilledButton(
            onPressed: () => onSelection(Attending.no),
            child: const Text('NO'),
          ),
        );

      case Attending.unknown:
      default:
        return _buildRow(
          yesButton: OutlinedButton(
            onPressed: () => onSelection(Attending.yes),
            child: const Text('YES'),
          ),
          noButton: OutlinedButton(
            onPressed: () => onSelection(Attending.no),
            child: const Text('NO'),
          ),
        );
    }
  }

  Widget _buildRow({required Widget yesButton, required Widget noButton}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [yesButton, const SizedBox(width: 8), noButton]),
    );
  }
}
