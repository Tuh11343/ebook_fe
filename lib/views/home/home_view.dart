


import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebook_tuh/data/dummy.dart';
import 'package:ebook_tuh/widgets/app_dialog.dart';
import 'package:ebook_tuh/widgets/author_horizontal_list.dart';
import 'package:ebook_tuh/widgets/book_horizontal_list.dart';
import 'package:ebook_tuh/widgets/daily_quotes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_color.dart';
import '../../constants/app_font_size.dart';
import '../../constants/asset_images.dart';
import '../../widgets/book_carousel.dart';
import '../../widgets/membership_card.dart';
import '../../widgets/number_book_carousel.dart';
import '../../widgets/section_title_with_icon.dart';
import '../main_wrapper/main_wrapper_cubit.dart';
import '../user_profile/user_cubit.dart';
import 'home_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeView extends StatefulWidget {
  final Function(int) onBottomNavBarButtonPressed;
  const HomeView({super.key,required this.onBottomNavBarButtonPressed});

  @override
  State<StatefulWidget> createState() {
    return HomeViewState();
  }
}

class HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  final double _customHeaderHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeLoading) {
          // Xử lý khi loading
        }
        if (state is HomeLoaded) {
          // Xử lý khi loaded
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          }

          if (state is HomeLoaded) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: WillPopScope(
                onWillPop: () async {
                  bool willExit = await AppDialog.showExitConfirmationDialog(context);
                  if (willExit) {
                    SystemNavigator.pop();
                    return false;
                  } else {
                    return false;
                  }
                },
                child: Scaffold(
                  extendBodyBehindAppBar: true,
                  backgroundColor: AppColors.whiteGrayContainer,
                  body: Stack(
                    children: <Widget>[
                      RefreshIndicator(
                        onRefresh: () async {
                          context.read<HomeBloc>().add( const FirstInitEvent()); // Fetch data lại khi refresh
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: EdgeInsets.only(top: _customHeaderHeight + MediaQuery.of(context).padding.top),
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF3E5151),
                                      Color(0xFFDECBA4),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: BigBookCarousel(bookList: state.mainBookList),
                              ),
                              const SizedBox(height: 20),
                              SectionTitleWithIcon(
                                title: "Top sách rating",
                                leadingIcon: Icons.format_quote,
                                onTap: () {

                                },
                              ),
                              TopRatingCarousel(bookList: state.topRatingBookList,onBookTap: (book) {
                                context.push("/detailBook", extra: book);
                              },),
                              const SizedBox(height: 20),
                              HorizontalBookList(title: 'Top Sách Ý Nghĩa', books: state.normalBookList,onBookTap: (book) {
                                context.push('/detailBook',extra: book);
                              },),
                              const SizedBox(height: 20,),
                              AuthorHorizontalList(title: 'Tác giả nổi bật', authors: state.authorList,onAuthorTap: (author) {
                                context.push('/authorPage',extra: author);
                              },),
                              const SizedBox(height: 20),
                              const SizedBox(height: 20),
                              SectionTitleWithIcon(
                                title: "Quotes Hay & Ý Nghĩa",
                                leadingIcon: Icons.format_quote, // Hoặc một icon phù hợp khác cho quotes
                                onTap: () {
                                  print('Quotes Hay & Ý Nghĩa tapped!');
                                },
                              ),
                              const SizedBox(height: 20),
                              QuoteCarousel(quotes: dummyQuotes),
                              const SizedBox(height: 20),
                              SectionTitleWithIcon(
                                title: "Gói hội viên hấp dẫn",
                                leadingIcon: Icons.interests, // Hoặc một icon phù hợp khác cho quotes
                                onTap: () {
                                  print('Quotes Hay & Ý Nghĩa tapped!');
                                },
                              ),
                              const SizedBox(height: 20),
                              MembershipCard(
                                titles: const [
                                  "Bạn chưa có thẻ Fonos nào",
                                  "Gói Hội viên Fonos mang lại",
                                  "Đừng bỏ lỡ ưu đãi đặc biệt!",
                                ],
                                // Đây là list các mô tả tương ứng sẽ cuộn qua lại cùng với tiêu đề
                                descriptions: const [
                                  "Trở thành Hội viên để nhận thẻ Fonos mỗi tháng và \"shopping\" bất kỳ nội dung nào bạn thích.",
                                  "Truy cập kho sách nói độc quyền, nghe không giới hạn và nhiều hơn nữa, giúp bạn trải nghiệm Fonos tốt hơn.",
                                  "Tham gia ngay hôm nay để nhận ưu đãi cho Hội viên mới và trải nghiệm toàn bộ thư viện sách nói và podcast.",
                                ],
                                buttonText: "Xem gói & quyền lợi",
                                onButtonPressed: () {
                                  if(state.isLoggedIn){
                                    context.read<MainWrapperCubit>().setBottomNavigationVisibility(false);
                                    context.push('/subscriptionPlan');
                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Vui lòng đăng nhập!!!'),duration: Duration(seconds: 500)),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- Widget Header/AppBar tùy chỉnh ---
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300), // Thời gian chuyển đổi màu
                          decoration: _isScrolled
                              ? BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          )
                              : null, // Không có decoration khi trong suốt
                          child: SafeArea(
                            child: Container(
                              height: _customHeaderHeight, // Đảm bảo _customHeaderHeight đủ lớn
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: <Widget>[
                                  // --- Logo "fonos" ---
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Icon hoặc Image cho logo sóng âm
                                      Icon(
                                        Icons.multitrack_audio, // Thay thế bằng icon hoặc asset phù hợp
                                        size: 28,
                                        color: _isScrolled ? Colors.black : Colors.black, // Màu sắc của logo
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'ETuh',
                                        style: TextStyle(
                                          fontSize: AppFontSize.large,
                                          fontWeight: FontWeight.bold,
                                          color: _isScrolled ? Colors.black : Colors.black, // Màu sắc của chữ "fonos"
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(), // Đẩy các widget tiếp theo sang phải

                                  // --- Nút "Nâng cấp" ---
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20), // Bo tròn góc
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF926F), // Màu cam nhạt
                                          Color(0xFFFF6B6B), // Màu cam đậm
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          if (state.isLoggedIn) {
                                            context.read<MainWrapperCubit>().setBottomNavigationVisibility(false);
                                            context.push('/subscriptionPlan');
                                          } else {
                                            context.push("/loginPage");
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.diamond, // Icon kim cương
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Nâng cấp',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.chevron_right, // Icon mũi tên
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                              // --- Ảnh đại diện tròn (Xử lý theo trạng thái đăng nhập giả định) ---
                              GestureDetector( // Sử dụng GestureDetector để xử lý tap
                                onTap: () {
                                  if (state.isLoggedIn) {

                                    context.read<UserCubit>().loadUser();
                                    context.read<MainWrapperCubit>().onBottomNavBarButtonPressed(3);

                                  } else {
                                    context.push("/loginPage");
                                  }
                                },
                                child: ClipOval(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: state.signedUrl??AssetImages.defaultBookHolder,
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) => Image.asset(
                                        AssetImages.defaultBookHolder, // Ảnh placeholder cục bộ của bạn
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person,size: 25, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(child: Text('Có lỗi đã xảy ra'),);
        },
      ),
    );
  }
}




