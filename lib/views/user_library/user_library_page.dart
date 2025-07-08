import 'package:ebook_tuh/views/user_library/user_library_cubit.dart';
import 'package:ebook_tuh/views/user_library/user_library_state.dart';
import 'package:ebook_tuh/widgets/book_list_vertical.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_color.dart';

class UserLibraryPage extends StatefulWidget {
  const UserLibraryPage({super.key});

  @override
  State<UserLibraryPage> createState() => _UserLibraryPageState();
}

class _UserLibraryPageState extends State<UserLibraryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Tải sách thư viện người dùng khi trang được khởi tạo
    context.read<UserLibraryCubit>().loadUserLibraryBooks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Hàm này sẽ được gọi khi người dùng kéo xuống để làm mới
  Future<void> _onRefresh() async {
    await context.read<UserLibraryCubit>().loadUserLibraryBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện của tôi', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3E5151).withOpacity(0.8),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sách đã thích'),
            Tab(text: 'Sách đã mua'),
          ],
          labelColor: Colors.white,
          labelStyle: const TextStyle(
            fontSize: 16, // Kích thước chữ cho tab được chọn
          ),
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      backgroundColor: Colors.white.withOpacity(0.3),
      body: BlocBuilder<UserLibraryCubit, UserLibraryState>(
        builder: (context, state) {
          if (state.status == UserLibraryStatus.loading && state.favoriteBooks.isEmpty && state.purchasedBooks.isEmpty) {
            // Chỉ hiển thị loading indicator nếu chưa có dữ liệu nào được tải
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == UserLibraryStatus.error) {
            return Center(
              child: Text(
                'Lỗi: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          // Khi đã tải xong hoặc đang tải nhưng đã có dữ liệu cũ, hiển thị TabBarView
          return TabBarView(
            controller: _tabController,
            children: [
              // Tab Sách đã thích
              RefreshIndicator( // Bọc nội dung tab bằng RefreshIndicator
                onRefresh: _onRefresh,
                child: state.favoriteBooks.isEmpty
                    ? ListView( // Sử dụng ListView để RefreshIndicator hoạt động ngay cả khi danh sách rỗng
                  children: const [
                    SizedBox(height: 100), // Khoảng trống để kéo xuống
                    Center(
                      child: Text(
                        'Bạn chưa thích cuốn sách nào.',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                )
                    : Padding(padding: const EdgeInsets.all(20),child: ListBookVertical(books: state.favoriteBooks)),
              ),

              // Tab Sách đã mua
              RefreshIndicator( // Bọc nội dung tab bằng RefreshIndicator
                onRefresh: _onRefresh,
                child: state.purchasedBooks.isEmpty
                    ? ListView( // Sử dụng ListView để RefreshIndicator hoạt động ngay cả khi danh sách rỗng
                  children: const [
                    SizedBox(height: 100), // Khoảng trống để kéo xuống
                    Center(
                      child: Text(
                        'Bạn chưa mua cuốn sách nào.',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                )
                    : Padding(padding:const EdgeInsets.all(20),child: ListBookVertical(books: state.purchasedBooks)),
              ),
            ],
          );
        },
      ),
    );
  }
}