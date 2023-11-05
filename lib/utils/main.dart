import 'package:flutter/foundation.dart';

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
