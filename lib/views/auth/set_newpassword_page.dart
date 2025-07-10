import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/text_input.dart';
import 'auth_cubit.dart';
import 'auth_state.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const SetNewPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
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
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lại mật khẩu',style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.black,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.actionType == AuthActionType.resetPassword) {
              if (state.status == AuthStatus.success) {
                _showSnackBar(context, state.successMessage!, Colors.green);
                Navigator.pop(context);
                context.read<AuthCubit>().clearActionAndMessages();
              } else if (state.status == AuthStatus.failure) {
                _showSnackBar(context, state.errorMessage!, Colors.red);
                context.read<AuthCubit>().clearActionAndMessages();
              }
            }
          },
          builder: (context, state) {
            bool isLoading = state.status == AuthStatus.loading &&
                state.actionType == AuthActionType.resetPassword;
            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Nhập mật khẩu mới của bạn.',
                      style: TextStyle(fontSize: AppFontSize.normal, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                      controller: _newPasswordController,
                      labelText: 'Mật khẩu mới',
                      obscureText: true,
                      isNumber: false,
                      prefixIcon: 'assets/icons/icon_lock_50.png',
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
                    MyTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Xác nhận mật khẩu mới',
                      obscureText: true,
                      prefixIcon: 'assets/icons/icon_lock_50.png',
                      isNumber: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu.';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự.';
                        }
                        if(value!=_confirmPasswordController.text){
                          return 'Mật khẩu không trùng khớp';
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
                                context.read<AuthCubit>().resetPassword(
                                    widget.email,
                                    widget.otp,
                                    _newPasswordController.text);
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
                              'Đặt lại mật khẩu',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
