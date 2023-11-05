import 'package:flutter/material.dart';
import 'package:perf_tracker/utils/main.dart';

enum PageTransitionDirection {
  left,
  right,
  top,
  bottom,
}

class PageTransition {
  static Future<T?> _transition<T>(BuildContext context, Widget page,
      {Offset begin = const Offset(1.0, 0.0),
      Offset? end = Offset.zero,
      Curve curve = Curves.easeInOut}) async {
    final String pageName = page.toStringShort();

    final String from = context.toString().splitMapJoin(
          RegExp(r'\(.*?\)'), // regex
          onMatch: (m) => '', // replace
          onNonMatch: (n) => n,
        );

    printDebug(
      "pushing $pageName page from $from",
      after: "*",
      before: "*",
    );

    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        settings: RouteSettings(name: page.toStringShort()),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  static Future<T?> fromLeft<T>(BuildContext context, Widget page) async {
    return _transition<T>(
      context,
      page,
      begin: const Offset(-1.0, 0.0),
    );
  }

  static Future<T?> fromRight<T>(BuildContext context, Widget page) async {
    return _transition<T>(
      context,
      page,
      begin: const Offset(1.0, 0.0),
    );
  }

  static Future<T?> fromTop<T>(BuildContext context, Widget page) async {
    return _transition<T>(
      context,
      page,
      begin: const Offset(0.0, -1.0),
    );
  }

  static Future<T?> fromBottom<T>(BuildContext context, Widget page) async {
    return _transition<T>(
      context,
      page,
      begin: const Offset(0.0, 1.0),
    );
  }

  static Future<T?> from<T>(
    PageTransitionDirection direction,
    BuildContext context,
    Widget page,
  ) async {
    switch (direction) {
      case PageTransitionDirection.left:
        return fromLeft<T>(context, page);
      case PageTransitionDirection.right:
        return fromRight<T>(context, page);
      case PageTransitionDirection.top:
        return fromTop<T>(context, page);
      case PageTransitionDirection.bottom:
        return fromBottom<T>(context, page);
    }
  }
}
