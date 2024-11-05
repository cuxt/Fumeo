import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import "package:flutter/material.dart";

class Util {
  static void showSnackBar({
    required Text content,
    required BuildContext context,
    Duration duration = const Duration(milliseconds: 800),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: content,
        duration: duration,
        behavior: behavior,
        dismissDirection: DismissDirection.down,
      ),
    );
  }

  static void showAwesomebar(
      BuildContext context, String type, String title, String message,
      {durationSeconds = 2}) {
    ContentType contentType;
    switch (type.toLowerCase()) {
      case 'success':
        contentType = ContentType.success;
        break;
      case 'failure':
        contentType = ContentType.failure;
        break;
      case 'warning':
        contentType = ContentType.warning;
        break;
      case 'help':
        contentType = ContentType.help;
        break;
      default:
        contentType = ContentType.help;
    }

    final materialBanner = MaterialBanner(
      elevation: 0,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        inMaterialBanner: true,
        contentType: contentType,
      ),
      actions: [SizedBox.shrink()],
    );

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);

    Future.delayed(Duration(seconds: durationSeconds), () {
      messenger.hideCurrentMaterialBanner();
    });
  }

  static String _keepTwo(int n) => n.toString().padLeft(2, "0");

  static String formatDateTime(DateTime time) {
    return "${_keepTwo(time.month)}-${_keepTwo(time.day)} "
        "${_keepTwo(time.hour)}:${_keepTwo(time.minute)}";
  }
}
