import 'package:flutter/material.dart';
import 'package:std/constants.dart';

void showCustomSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
  Duration duration = const Duration(seconds: 1),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.close : Icons.check,
            color: isError ? AppColors.mainRed : AppColors.iconGreen,
            size: 32,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.snackbar,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(6),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
    ),
  );
}
