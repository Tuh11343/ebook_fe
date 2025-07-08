


import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../constants/app_font_size.dart';

class AppDialog {
  AppDialog._();

  static void show(
      BuildContext context, {
        required String title,
        required String content,
        bool canCancel = false,
        required String primaryButtonTitle,
        required Function() onPrimaryTap,
        Future<bool> Function()? onWillPop,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: onWillPop ??
                  () async {
                return true;
              },
          child: AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(content),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: onPrimaryTap,
                child: Text(primaryButtonTitle),
              ),
              if (canCancel)
                TextButton(
                  child: const Text('Hủy'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  static void showLoading(BuildContext context, {required String content}) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
              Text(
                content,
                style: const TextStyle(
                  fontSize: AppFontSize.normal,
                ),
              )
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
        );
      },
    );
  }

  static Future showWidget(
      BuildContext context, {
        String? title,
        required Widget child,
        required String primaryButtonTitle,
        required Function() onPrimaryTap,
        bool canCancel = false,
      }) async {
    double width = MediaQuery.of(context).size.width;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          titlePadding: const EdgeInsets.all(10),
          scrollable: true,
          title: title != null
              ? Text(
            title,
            style: const TextStyle(
              fontSize: AppFontSize.medium,
            ),
          )
              : null,
          content: child,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actionsOverflowButtonSpacing: 5,
          actionsPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary, minimumSize: Size(width, 50),
                side: const BorderSide(color: AppColors.lightGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: onPrimaryTap,
              child: Text(
                primaryButtonTitle,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppFontSize.medium,
                ),
              ),
            ),
            canCancel
                ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(width, 50),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppColors.primary,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppFontSize.medium,
                ),
              ),
            )
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  static void showSimpleDialog(BuildContext context,
      {required List<Widget> children}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          titlePadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          children: children,
        );
      },
    );
  }


  static Future<bool> showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Tiêu đề của dialog
          title: const Text(
            'Xác nhận thoát',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple, // Màu sắc cho tiêu đề
            ),
          ),
          // Nội dung của dialog
          content: const Text(
            'Bạn có chắc chắn muốn thoát ứng dụng không?',
            style: TextStyle(fontSize: 16),
          ),
          // Các hành động (nút) trong dialog
          actions: <Widget>[
            // Nút "Hủy"
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Trả về false (không thoát)
              },
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            // Nút "Thoát"
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Màu nền cho nút
                foregroundColor: Colors.white, // Màu chữ cho nút
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bo góc cho nút
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // Trả về true (thoát)
              },
              child: const Text(
                'Thoát',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
          // Thiết lập thêm cho AlertDialog (tùy chọn)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Bo góc cho dialog
          ),
          elevation: 8, // Độ nổi của dialog
          backgroundColor: Colors.white, // Màu nền của dialog
        );
      },
    ) ?? false; // ?? false để đảm bảo giá trị trả về không phải là null nếu dialog bị đóng mà không chọn gì
  }
}