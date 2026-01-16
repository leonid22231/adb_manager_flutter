import 'package:flutter/material.dart';

extension StateExtension on State {
  void setStateIfMounted([VoidCallback? fn]) {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(fn ?? () {});
    }
  }
}

extension ColorExtension on Color {
  Color setOpacity(double opacity) {
    return withAlpha((255.0 * opacity).round());
  }
}

extension DateTimeExtension on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 5) {
      return 'сейчас';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds}c назад';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}м назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}ч назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}д назад';
    } else {
      return '$month/$day/$year';
    }
  }
}
