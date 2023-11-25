import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void printDebug(dynamic message, {String before = "", String after = ""}) {
  if (kDebugMode) {
    if (before != "") {
      print(before * 50);
    }

    print(message);

    if (after != "") {
      print(after * 50);
    }
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
  ScaffoldMessengerState scaffoldMessenger,
  ThemeData theme,
  String message, {
  isError = false,
}) {
  return scaffoldMessenger.showSnackBar(
    SnackBar(
      backgroundColor:
          isError ? theme.colorScheme.error : theme.colorScheme.primary,
      content: Text(
        message,
        style: TextStyle(
          color: theme.colorScheme.onError,
        ),
      ),
    ),
  );
}
