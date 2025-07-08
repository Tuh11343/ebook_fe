import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebook_tuh/views/user_profile/user_cubit.dart';
import 'package:ebook_tuh/views/user_profile/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  final _formKey = GlobalKey<FormState>();

  File? _selectedAvatarFile;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controllers rỗng. Chúng sẽ được điền dữ liệu khi UserLoaded state được phát ra.
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Hàm chọn ảnh avatar
  Future<void> _pickNewAvatar() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _selectedAvatarFile = File(pickedFile.path);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ảnh đã được chọn, nhấn "Lưu" để tải lên.'),duration: Duration(milliseconds: 500),),
        );
      }
    } else {
      print('Người dùng đã hủy chọn ảnh.');
    }
  }

  // Hàm lưu thông tin profile
  void _saveProfile(User currentUser) async {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<UserCubit>().updateUserProfile(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            avatarFile: _selectedAvatarFile,
            // Gửi file đã chọn (nếu có)
          );
    }
  }

  // // Hàm để xóa ảnh đại diện
  // void _removeAvatar() {
  //   setState(() {
  //     _selectedAvatarFile = null; // Xóa file đang chọn
  //   });
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Ảnh đại diện sẽ được xóa, nhấn "Lưu".')),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Chỉnh sửa tài khoản',
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
            if (state is UserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            } else if (state is UserLoaded) {
              // Cập nhật controllers khi dữ liệu người dùng được tải hoặc cập nhật thành công
              _nameController.text = state.user.name ?? '';
              _phoneController.text = state.user.phone ?? '';
              _emailController.text = state.user.email ?? '';
              // Reset các cờ và file tạm sau khi cập nhật thành công
              _selectedAvatarFile = null;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cập nhật thành công'),duration: Duration(milliseconds: 500)),
              );
              // Navigator.pop(context, true); // Tùy chọn: tự động pop sau khi lưu thành công
            }
          },
          builder: (context, state) {
            if (state is UserLoading || state is UserInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserLoaded) {
              final currentUser = state.user;
              // Nếu controllers chưa được điền dữ liệu, điền vào từ currentUser
              if (_nameController.text.isEmpty && currentUser.name != null) {
                _nameController.text = currentUser.name!;
              }
              if (_phoneController.text.isEmpty && currentUser.phone != null) {
                _phoneController.text = currentUser.phone!;
              }
              if (_emailController.text.isEmpty && currentUser.email != null) {
                _emailController.text = currentUser.email!;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfileHeader(
                        context,
                        currentUser.name,
                        _selectedAvatarFile != null
                            ? _selectedAvatarFile!.path
                            : state.signedUrl,
                      ),
                      const SizedBox(height: 30),

                      _buildTextField(
                        controller: _nameController,
                        labelText: 'Full name',
                        hintText: 'Enter your full name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full name cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Trường số điện thoại với nút xóa
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneController,
                              labelText: 'Phone number',
                              hintText: 'e.g., +84 901 234 567',
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value != null &&
                                    value.trim().isNotEmpty &&
                                    !RegExp(r'^\+?[0-9\s-()]{7,20}$')
                                        .hasMatch(value.trim())) {
                                  return 'Enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                          // if (_phoneController.text.isNotEmpty ||
                          //     _clearPhone) // Hiển thị nút xóa nếu có số hoặc đang trong trạng thái xóa
                          //   IconButton(
                          //     icon: const Icon(Icons.clear, color: Colors.red),
                          //     onPressed: _removePhone,
                          //   ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'your.email@example.com',
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        // Email thường không cho phép chỉnh sửa
                        validator: (value) {
                          if (value != null &&
                              value.trim().isNotEmpty &&
                              !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: state is UserLoading
                              ? null
                              : () => _saveProfile(currentUser),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: state is UserLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Lưu',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is UserError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    ElevatedButton(
                      onPressed: () => context.read<UserCubit>().loadUser(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // --- Các Widget con hỗ trợ ---

  // Header với ảnh đại diện và nút camera
  // Thay đổi trong _buildProfileHeader
  Widget _buildProfileHeader(
      BuildContext context, String? userName, String? avatarUrl) {
    // avatarUrlFromServer là URL từ server (tức là currentUser.avatarUrl)

    // Xác định nguồn ảnh sẽ hiển thị
    Widget avatarWidget;
    if (_selectedAvatarFile != null) {
      // Nếu có file avatar mới được chọn, hiển thị nó từ bộ nhớ cục bộ
      avatarWidget = ClipOval(
        // Sử dụng ClipOval để ảnh có hình tròn
        child: Image.file(
          _selectedAvatarFile!,
          fit: BoxFit.cover,
          width: 120, // Đảm bảo kích thước khớp với Container
          height: 120, // Đảm bảo kích thước khớp với Container
        ),
      );
    } else {
      // Nếu không có file mới được chọn, hiển thị ảnh từ server (nếu có)
      avatarWidget = ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              const Icon(Icons.person, size: 60, color: Colors.grey),
        ),
      );
    }

    return Column(children: [
      Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: avatarWidget, // <-- Sử dụng widget đã chọn ở trên
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'pick') {
                  _pickNewAvatar();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'pick',
                  child: Row(
                    children: [
                      Icon(Icons.photo_library),
                      SizedBox(width: 8),
                      Text('Choose from Gallery'),
                    ],
                  ),
                ),
                // Giữ nguyên phần "Remove Avatar" nếu bạn muốn tính năng đó
                if (avatarUrl != null &&
                    avatarUrl.isNotEmpty)
                  const PopupMenuItem<String>(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remove Avatar',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 15),
      Text(
        userName ?? 'Guest User',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        _emailController.text.isNotEmpty
            ? '@${_emailController.text.split('@').first}'
            : '@no_username',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
    ]);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false, // Thêm tham số readOnly
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      // Sử dụng tham số readOnly
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      cursorColor: Colors.black,
    );
  }
}
