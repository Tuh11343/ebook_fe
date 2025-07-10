import 'package:ebook_tuh/views/home/home_bloc.dart';
import 'package:ebook_tuh/views/home/home_event.dart';
import 'package:ebook_tuh/views/main_wrapper/main_wrapper_cubit.dart';
import 'package:ebook_tuh/views/user_profile/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_color.dart';
import '../../../widgets/text_input.dart';
import '../auth_cubit.dart';
import '../auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  // Hàm để xử lý logic đăng nhập
  void _performLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // Nếu form hợp lệ, gọi hàm login của AuthCubit
      context.read<AuthCubit>().login(
        _usernameController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Đóng bàn phím khi chạm ra ngoài
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: BlocConsumer<AuthCubit, AuthState>(
          // QUAN TRỌNG: listenWhen chỉ cho phép listener chạy nếu...
          listenWhen: (previous, current) {
            // ...trạng thái hiện tại là success HOẶC failure
            // VÀ hành động đi kèm là signIn.
            return (current.status == AuthStatus.success || current.status == AuthStatus.failure) &&
                current.actionType == AuthActionType.signIn;
          },
          listener: (context, state) {
            if (state.status == AuthStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage ?? 'Đăng nhập thành công!'),
                  backgroundColor: Colors.green, // Sử dụng AppColors
                ),
              );
              context.read<HomeBloc>().add(const UpdateUserEvent());
              context.read<UserCubit>().loadUser();
              Navigator.pop(context);
              context.read<MainWrapperCubit>().onBottomNavBarButtonPressed(0);
              // Sau khi đăng nhập thành công, bạn có thể điều hướng đến trang chính
              // Ví dụ:
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));

            } else if (state.status == AuthStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Đăng nhập thất bại.'),
                  backgroundColor: AppColors.errorRed, // Sử dụng AppColors
                ),
              );
              debugPrint('Lỗi:${state.errorMessage}');
            }
            // Rất quan trọng: Xóa thông báo và actionType sau khi đã xử lý
            context.read<AuthCubit>().clearActionAndMessages();
          },
          // buildWhen: Chỉ rebuild UI (ví dụ: nút loading) nếu...
          buildWhen: (previous, current) {
            // ...trạng thái loading thay đổi liên quan đến hành động signIn
            // HOẶC trạng thái success/failure liên quan đến hành động signIn (để ẩn loading)
            return (current.actionType == AuthActionType.signIn &&
                (current.status == AuthStatus.loading ||
                    current.status == AuthStatus.success ||
                    current.status == AuthStatus.failure));
          },
          builder: (context, state) {
            // Chỉ hiển thị loading trên nút Login nếu actionType là signIn và status là loading
            bool isLoading = state.status == AuthStatus.loading && state.actionType == AuthActionType.signIn;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Container(
                  padding: const EdgeInsets.only(top: 10, right: 24, left: 24, bottom: 24),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Clear trạng thái AuthCubit khi đóng trang
                                context.read<AuthCubit>().clearActionAndMessages();
                              },
                              icon: const Icon(FontAwesomeIcons.deleteLeft, color: AppColors.primaryBlue), // Thay thế icon cho phù hợp
                            )
                          ],
                        ),
                        // Image minh họa (đảm bảo có assets/images/login_illustration.png)
                        Image.asset(
                          'assets/images/login_illustration.png',
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Đăng Nhập',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Input User name
                        MyTextField(
                          labelText: 'Tên đăng nhập',
                          controller: _usernameController,
                          obscureText: false,
                          isNumber: false,
                          prefixIcon: 'assets/icons/icon_email_100.png', // Thay thế bằng icon thực tế
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tên đăng nhập.';
                            }
                            // Thêm các quy tắc kiểm tra khác nếu cần
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Input Password
                        MyTextField(
                          labelText: 'Mật khẩu',
                          controller: _passwordController,
                          obscureText: true,
                          isNumber: false,
                          prefixIcon: 'assets/icons/icon_lock_50.png', // Thay thế bằng icon thực tế
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu.';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự.';
                            }
                            // Thêm các quy tắc kiểm tra khác nếu cần
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Forget Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.read<MainWrapperCubit>().setBottomNavigationVisibility(false);
                              context.push('/requestResetPassword');
                            },
                            child: Text(
                              'Quên mật khẩu',
                              style: TextStyle(color: AppColors.linkBlue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading // Vô hiệu hóa nút khi đang tải
                                ? null
                                : _performLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 5,
                            ),
                            child: isLoading // Hiển thị indicator khi đang tải
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              'Đăng Nhập',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Or Continue with
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppColors.borderGrey, thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'Hoặc tiếp tục với',
                                style: TextStyle(color: AppColors.textColor.withOpacity(0.7)),
                              ),
                            ),
                            const Expanded(child: Divider(color: AppColors.borderGrey, thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Social Login Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildSocialButton(
                                icon: FontAwesomeIcons.google,
                                label: 'Google',
                                onPressed: () {
                                  print('Google login pressed');
                                  // Gọi AuthCubit để xử lý đăng nhập Google
                                  context.read<AuthCubit>().googleSignIn();
                                },
                              ),
                            ),
                            const SizedBox(width: 20,),
                            Expanded(
                              child: _buildSocialButton(
                                icon: FontAwesomeIcons.facebook,
                                label: 'Facebook',
                                onPressed: () {
                                  print('Facebook login pressed');
                                  // Gọi AuthCubit để xử lý đăng nhập Facebook
                                  // context.read<AuthCubit>().signInWithFacebook();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Haven't any account? Sign up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Chưa có tài khoản? ",
                              style: TextStyle(color: AppColors.textColor.withOpacity(0.7)),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.pushReplacement('/registerPage');
                                // Rất quan trọng: Clear trạng thái AuthCubit khi điều hướng sang trang khác
                                // để trang mới có thể bắt đầu với trạng thái "sạch"
                                context.read<AuthCubit>().clearActionAndMessages();
                              },
                              child: Text(
                                'Đăng ký',
                                style: TextStyle(
                                  color: AppColors.linkBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget helper cho nút đăng nhập bằng mạng xã hội (Giữ nguyên)
  Widget _buildSocialButton({
    required String label,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.borderGrey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: AppColors.textColor), // Sử dụng AppColors
            const SizedBox(width: 10,),
            Text(
              label,
              style: TextStyle(color: AppColors.textColor, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}