import 'package:chatty/common/routes/routes.dart';
import 'package:chatty/common/store/store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RouteAuthMiddleware extends GetMiddleware {
  @override
  int? priority = 0;

  RouteAuthMiddleware({required this.priority});

  @override
  RouteSettings? redirect(String? route) {
    if (UserStore.to.isLogin ||
        route == AppRoutes.signIn ||
        route == AppRoutes.initial) {
      return null;
    } else {
      Future.delayed(
        const Duration(seconds: 2),
        () => Get.snackbar("Tips", "Login expired, please login again!"),
      );
      return const RouteSettings(
        name: AppRoutes.signIn,
      );
    }
  }
}
