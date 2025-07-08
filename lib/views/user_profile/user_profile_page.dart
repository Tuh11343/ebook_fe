import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebook_tuh/constants/asset_images.dart';
import 'package:ebook_tuh/views/home/home_bloc.dart';
import 'package:ebook_tuh/views/home/home_event.dart';
import 'package:ebook_tuh/views/main_wrapper/main_wrapper_cubit.dart';
import 'package:ebook_tuh/views/user_profile/user_cubit.dart';
import 'package:ebook_tuh/views/user_profile/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Hồ sơ người dùng',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if(state is UserSigningOut){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đăng xuất thành công'),
                backgroundColor: Colors.green,
              ),
            );

            context.read<HomeBloc>().add(const UpdateUserEvent());
            context.read<UserCubit>().loadUser();
            context.read<MainWrapperCubit>().onBottomNavBarButtonPressed(0);

          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          if (state is UserLoaded) {
            final User currentUser = state.user; // Lấy user từ state

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildProfileHeader(context, currentUser,state.signedUrl), // Truyền currentUser vào
                    const SizedBox(height: 30),
                    _buildOptionList(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink(); // Trường hợp state không xác định
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user,String? signedUrl) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: signedUrl ?? AssetImages.defaultBookHolder, // Sử dụng avatarUrl từ User
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.person, size: 60, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '@${user.name}', // Hoặc user.username nếu có
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              context.pushNamed('editProfilePage');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Chỉnh sửa hồ sơ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            context,
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            onTap: () {
              // TODO: Điều hướng đến trang Settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đi đến Settings')),
              );
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.list_alt,
            title: 'Lịch sử thanh toán',
            onTap: () {
              // TODO: Điều hướng đến trang My Orders
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đi đến My Orders')),
              );
            },
          ),
          // _buildOptionTile(
          //   context,
          //   icon: Icons.location_on_outlined,
          //   title: 'Address',
          //   onTap: () {
          //     // TODO: Điều hướng đến trang Address
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Đi đến Address')),
          //     );
          //   },
          // ),
          _buildOptionTile(
            context,
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            onTap: () {
              // TODO: Điều hướng đến trang Change Password
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đi đến Change Password')),
              );
            },
          ),
          Divider(indent: 20, endIndent: 20, color: Colors.grey.shade200, height: 30),
          _buildOptionTile(
            context,
            icon: Icons.help_outline,
            title: 'Dịch vụ & Hỗ trợ',
            onTap: () {
              // TODO: Điều hướng đến trang Help & Support
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đi đến Help & Support')),
              );
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.logout,
            title: 'Đăng xuất',
            isDestructive: true,
            onTap: () async {
              context.read<UserCubit>().logOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        VoidCallback? onTap,
        bool isDestructive = false,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.redAccent : Colors.black87,
              size: 24,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDestructive ? Colors.redAccent : Colors.black87,
                  fontWeight: isDestructive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
