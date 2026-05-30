import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:std/provider/app_state.dart';

class RefreshDatabase extends NavigatorObserver {
  Future<void> _refresh(Route<dynamic>? route) async {
    final context = navigator?.context;

    if (context == null) return;
    if (route == null) return;

    try {
      await context.read<AppState>().loadContentsFromDb();
    } catch (e) {
      debugPrint('페이지 이동 후 DB 새로고침 실패: $e');
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _refresh(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _refresh(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _refresh(newRoute);
  }
}