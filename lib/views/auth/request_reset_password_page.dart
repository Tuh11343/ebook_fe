import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/text_input.dart';
import 'auth_cubit.dart';
import 'auth_state.dart';

class RequestPasswordResetScreen extends StatefulWidget {
  const RequestPasswordResetScreen({super.key});

  @override
  State<RequestPasswordResetScreen> createState() =>
      _RequestPasswordResetScreenState();
}

class _RequestPasswordResetScreenState
    extends State<RequestPasswordResetScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm tài khoản của bạn',style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.actionType == AuthActionType.requestPasswordReset) {
            if (state.status == AuthStatus.success) {
              _showSnackBar(context, state.successMessage!, Colors.green);
              //Đi tới trang tiếp theo
              context.pushReplacement('/enterOtpPage',extra: _emailController.text);
              context.read<AuthCubit>().clearActionAndMessages();
            } else if (state.status == AuthStatus.failure) {
              _showSnackBar(context, state.errorMessage!, Colors.red);
              context.read<AuthCubit>().clearActionAndMessages();
            }
          }
        },
        builder: (context, state) {
          bool isLoading = state.status == AuthStatus.loading &&
              state.actionType == AuthActionType.requestPasswordReset;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              print('test');
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Nhập email, số điện thoại hoặc tên người dùng liên kết với tài khoản để thay đổi mật khẩu của bạn.',
                      style: TextStyle(fontSize: AppFontSize.normal, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                      controller: _emailController,
                      labelText: 'Email, số điện thoại hoặc tên người dùng',
                      isNumber: false,
                      obscureText: false,
                      prefixIcon: 'assets/icons/icon_email_100.png',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập địa chỉ email.';
                        }
                        final emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                        if (value.contains('@')) {
                          if (!emailRegex.hasMatch(value)) {
                            return 'Địa chỉ email không hợp lệ.';
                          }
                        }
                        return null;
                      },
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context
                                    .read<AuthCubit>()
                                    .requestPasswordReset(_emailController.text);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              'Tiếp theo',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
