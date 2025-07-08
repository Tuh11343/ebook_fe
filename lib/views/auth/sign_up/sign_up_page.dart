import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:ebook_tuh/views/home/home_event.dart';
import 'package:ebook_tuh/widgets/text_input.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_color.dart';
import '../../home/home_bloc.dart';
import '../../main_wrapper/main_wrapper_cubit.dart';
import '../../user_profile/user_cubit.dart';
import '../auth_cubit.dart';
import '../auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>(); // <-- Thêm GlobalKey cho Form
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý validation tổng thể và gửi đăng ký
  void _performSignUp() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Ẩn bàn phím
      context.read<AuthCubit>().signUp(
        _fullNameController.text,
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (previous, current) {
          return (current.status == AuthStatus.success ||
                  current.status == AuthStatus.failure) &&
              current.actionType == AuthActionType.signUp;
        },
        listener: (context, state) {
          if (state.status == AuthStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'Đăng ký thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<HomeBloc>().add(const UpdateUserEvent());
            context.read<UserCubit>().loadUser();
            Navigator.pop(context);
            context.read<MainWrapperCubit>().onBottomNavBarButtonPressed(0);
          } else if (state.status == AuthStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Đăng ký thất bại.'),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
          context.read<AuthCubit>().clearActionAndMessages();
        },
        buildWhen: (previous, current) {
          return (current.actionType == AuthActionType.signUp &&
              (current.status == AuthStatus.loading ||
                  current.status == AuthStatus.success ||
                  current.status == AuthStatus.failure));
        },
        builder: (context, state) {
          bool isLoading = state.status == AuthStatus.loading &&
              state.actionType == AuthActionType.signUp;

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 48.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/signup_illustration.png',
                              height: 150,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Đăng Ký',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Input Full name
                            MyTextField(
                              // <-- SỬ DỤNG MyTextFormField (Xem phần giải thích bên dưới)
                              labelText: 'Họ tên',
                              controller: _fullNameController,
                              obscureText: false,
                              isNumber: false,
                              prefixIcon: 'assets/icons/icon_email_100.png',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Không được để trống';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Input Email address
                            MyTextField(
                              // <-- SỬ DỤNG MyTextFormField
                              labelText: 'Email',
                              controller: _emailController,
                              obscureText: false,
                              isNumber: false,
                              prefixIcon: 'assets/icons/icon_email_100.png',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Không được để trống';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Địa chỉ email không hợp lệ.';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Input Password
                            MyTextField(
                              // <-- SỬ DỤNG MyTextFormField
                              labelText: 'Mật khẩu',
                              controller: _passwordController,
                              obscureText: true,
                              isNumber: false,
                              prefixIcon: 'assets/icons/icon_lock_50.png',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Không được để trống';
                                }
                                if (value.length < 6) {
                                  return 'Mật khẩu phải có ít nhất 6 ký tự.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Điều khoản & Điều kiện
                            Text.rich(
                              TextSpan(
                                text: 'Bằng việc đăng ký, bạn đồng ý với ',
                                // Dịch: By signing up, you are agree to our
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textColor.withOpacity(0.7),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Điều khoản & Điều kiện',
                                    // Dịch: Terms & Conditions
                                    style: const TextStyle(
                                        color: AppColors.linkBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Tính năng đang được phát triển'),
                                            duration: Duration(
                                                seconds:
                                                    1), // Thời gian hiển thị
                                          ),
                                        );
                                      },
                                  ),
                                  const TextSpan(text: ' và '),
                                  // Giữ nguyên ' and '
                                  TextSpan(
                                    text: 'Chính sách bảo mật',
                                    // Dịch: Privacy Policy
                                    style: const TextStyle(
                                        color: AppColors.linkBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Tính năng đang được phát triển'),
                                            duration: Duration(
                                                seconds:
                                                    1), // Thời gian hiển thị
                                          ),
                                        );
                                      },
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),

                            // Create Account Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _performSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  elevation: 5,
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Tạo tài khoản',
                                        style: TextStyle(
                                            fontSize: AppFontSize.normal,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Already have an Account? Sign in
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Đã có tài khoản? ",
                                  style: TextStyle(
                                      color:
                                          AppColors.textColor.withOpacity(0.7),
                                      fontSize: AppFontSize.small),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.pushReplacement('/loginPage');
                                    context
                                        .read<AuthCubit>()
                                        .clearActionAndMessages();
                                  },
                                  child: const Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                        color: AppColors.linkBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppFontSize.small),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -15,
                      right: -15,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          context.read<AuthCubit>().clearActionAndMessages();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
