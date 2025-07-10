import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/text_input.dart';
import 'auth_cubit.dart';
import 'auth_state.dart';

class EnterOtpScreen extends StatefulWidget {
  EnterOtpScreen({super.key,required this.email});

  String email;

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập mã OTP',style: TextStyle(color: Colors.black),),
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
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.actionType == AuthActionType.verifyOtp) {
              if (state.status == AuthStatus.success) {
                _showSnackBar(context, state.successMessage!, Colors.green);
                context.pushReplacement('/setNewPassword',extra: {'email':widget.email,'otp':_otpController.text});
                context.read<AuthCubit>().clearActionAndMessages();
              } else if (state.status == AuthStatus.failure) {
                _showSnackBar(context, state.errorMessage!, Colors.red);
                context.read<AuthCubit>().clearActionAndMessages();
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Mã OTP đã được gửi đến email ${widget.email ?? 'của bạn'}. Vui lòng kiểm tra.',
                  style: const TextStyle(fontSize: AppFontSize.normal, color: Colors.black),
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: _otpController,
                  labelText: 'Mã OTP (6 chữ số)',
                  obscureText: false,
                  prefixIcon: 'assets/icons/icon_lock_50.png',
                  isNumber: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập otp';
                    }
                    return null;
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthCubit>().verifyOtp(widget.email, _otpController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Xác nhận OTP',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}