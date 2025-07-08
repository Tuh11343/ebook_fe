import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_color.dart';

class LoginPromptScreen extends StatelessWidget {
  const LoginPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E5151).withOpacity(0.8),
      // backgroundColor: Colors.grey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 5, // Độ nổi của card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Bo góc card
            ),
            color: Colors.white, // Màu nền của card
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Giúp Column không chiếm hết chiều cao
                children: [
                  // Icon người dùng
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300, // Màu viền icon
                        width: 2,
                      ),
                      color: Colors.white, // Nền icon nếu muốn khác
                    ),
                    child: Icon(
                      Icons.person_outline, // Icon người dùng
                      size: 50,
                      color: Colors.grey.shade400, // Màu icon
                    ),
                  ),
                  const SizedBox(height: 30), // Khoảng cách
                  // Text nhắc nhở đăng nhập
                  const Text(
                    'Chưa có tài khoản',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFontSize.large,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Màu chữ
                    ),
                  ),
                  const SizedBox(height: 30), // Khoảng cách
                  // Nút Đăng nhập
                  SizedBox(
                    width: double.infinity, // Nút chiếm hết chiều ngang
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Xử lý sự kiện khi nhấn nút "Đăng nhập"
                        // Ví dụ: Điều hướng đến trang đăng nhập
                        context.push('/loginPage'); // Thay '/loginPage' bằng route của bạn
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whiteGrayContainer, // Màu nền nút (light blue)
                        foregroundColor: Colors.black, // Màu chữ nút
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25), // Bo góc nút
                        ),
                        elevation: 0, // Bỏ đổ bóng
                      ),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Khoảng cách
                  // Text "Tạo tài khoản mới"
                  GestureDetector(
                    onTap: () {
                      // TODO: Xử lý sự kiện khi nhấn "Tạo tài khoản mới"
                      // Ví dụ: Điều hướng đến trang đăng ký
                      context.push('/registerPage'); // Thay '/registerPage' bằng route của bạn
                    },
                    child: const Text(
                      'Tạo tài khoản mới',
                      style: TextStyle(
                        fontSize: AppFontSize.normal,
                        color: Colors.black, // Màu chữ
                        decoration: TextDecoration.underline, // Gạch chân
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}