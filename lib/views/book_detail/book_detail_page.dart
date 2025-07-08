import 'package:ebook_tuh/constants/app_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

import '../../models/author.dart';
import '../../models/book.dart';
import '../../models/genre.dart';
import '../../models/review.dart';
import '../../models/user.dart';
import '../audio_book/audio_cubit.dart';
import '../main_wrapper/main_wrapper_cubit.dart';
import 'book_detail_bloc.dart';
import 'book_detail_event.dart';
import 'book_detail_state.dart';

class BookDetailPage extends StatefulWidget {
  final Book initialBook;

  const BookDetailPage({super.key, required this.initialBook});

  @override
  _BoatDetailPageState createState() => _BoatDetailPageState();
}

class _BoatDetailPageState extends State<BookDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;
  User? _user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _user = await AppStorage.getUser();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookDetailBloc(initialBook: widget.initialBook)
        ..add(LoadBookDetailRelatedData(book: widget.initialBook)),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.white,
          body: BlocConsumer<BookDetailBloc, BookDetailState>(
            listener: (context, state) {
              if (state is BookDetailActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (state is BookDetailError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${state.message}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is BookDetailError) {
                return Center(child: Text('Lỗi: ${state.message}'));
              } else if (state is BookDetailLoaded) {
                return _buildBookDetailContent(context, state);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookDetailContent(BuildContext context, BookDetailLoaded state) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFbdc3c7), Color(0xFF2c3e50)],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, state.book, state.isFavorite,
              state.isLoadingRelatedData),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildBookHeaderSection(context, state),
              const SizedBox(height: 20),
              _buildActionButtons(context, state),
              const SizedBox(height: 20),
              if(!state.isLoadingRelatedData)
                if (widget.initialBook.accessType == AccessType.premium &&
                    state.canAccess == false) ...[
                  _buildMembershipSection(context, state.book),
                  const SizedBox(height: 20),
                ],
              _buildContentSection(context, state),
            ]),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
      BuildContext context, Book book, bool isFavorite, bool isLoading) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      snap: false,
      stretch: true,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20.0),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        if (!isLoading) ...[
          _buildAppBarAction(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white,
            onPressed: () =>
                context.read<BookDetailBloc>().add(const ToggleFavoriteEvent()),
          ),
        ],
        _buildAppBarAction(
          icon: Icons.share,
          color: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Chức năng chia sẻ (chưa triển khai)')),
          ),
          marginRight: 10,
        ),
      ],
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double marginRight = 5,
  }) {
    return Container(
      margin: EdgeInsets.only(right: marginRight, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20.0),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBookHeaderSection(BuildContext context, BookDetailLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cover Image
          _buildCoverImage(state.book),
          const SizedBox(height: 20),
          // Title
          Text(
            state.book.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          // Authors
          _buildAuthorsWidget(
              context, state.authors, state.isLoadingRelatedData),
          const SizedBox(height: 10),
          // Rating
          _buildRatingWidget(state.averageRating, state.totalReviews),
          const SizedBox(height: 20),
          // Genres
          _buildGenresWidget(state.genres, state.isLoadingRelatedData),
        ],
      ),
    );
  }

  Widget _buildCoverImage(Book book) {
    return Container(
      height: 220,
      width: 150,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty
            ? Image.network(
                book.coverImageUrl!,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey,
                  child: const Icon(Icons.broken_image,
                      color: Colors.white, size: 50),
                ),
              )
            : Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.book, color: Colors.grey, size: 80),
                ),
              ),
      ),
    );
  }

  Widget _buildAuthorsWidget(
      BuildContext context, List<Author> authors, bool isLoading) {
    if (isLoading) {
      return const Text(
        'Tác giả: Đang tải...',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.white),
      );
    }

    if (authors.isEmpty) {
      return const Text(
        'Không rõ tác giả',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.white),
      );
    }

    if (authors.length == 1) {
      return TextButton(
        child: Text(
          authors.first.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        onPressed: () {
          context.push('/authorPage', extra: authors.first);
        },
      );
    }

    // Multiple authors - show with arrow and tap functionality
    return InkWell(
      onTap: () => _showAuthorsBottomSheet(context, authors),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                authors.map((a) => a.name).join(', '),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showAuthorsBottomSheet(BuildContext context, List<Author> authors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Title
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                child: Text(
                  'Tác giả',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
              ),
              // Authors list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: authors.length,
                  itemBuilder: (context, index) {
                    final author = authors[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 24,
                        child:
                            Icon(Icons.person, color: Colors.white, size: 24),
                      ),
                      title: Text(author.name),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/authorPage', extra: author);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingWidget(double? averageRating, int? totalReviews) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.star,
          color: averageRating != null && averageRating > 0
              ? Colors.amber
              : Colors.white70,
          size: 18,
        ),
        const SizedBox(width: 5),
        Text(
          averageRating != null && averageRating > 0
              ? '${averageRating.toStringAsFixed(1)} ($totalReviews đánh giá)'
              : 'Chưa có đánh giá',
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildGenresWidget(List<Genre> genres, bool isLoading) {
    if (isLoading) {
      return const Text(
        'Thể loại: Đang tải...',
        style: TextStyle(fontSize: 14, color: Colors.white),
      );
    }

    if (genres.isEmpty) {
      return const Text(
        'Thể loại: Chưa cập nhật',
        style: TextStyle(fontSize: 14, color: Colors.white),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thể loại:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 35,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: genres.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return Chip(
                label: Text(genres[index].name),
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.blue.shade50, width: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, BookDetailLoaded state) {
    final book = state.book;

    // Determine button properties based on book type
    IconData buttonIcon = Icons.error_outline;
    String buttonLabel = 'Không xác định';
    VoidCallback? onPressed;

    if (book.bookType == BookType.audiobook) {
      buttonIcon = Icons.play_arrow;
      buttonLabel = 'Nghe chương đầu miễn phí';
      if (book.audioFileUrl != null && book.audioFileUrl!.isNotEmpty) {
        onPressed = () {
          if (state.canAccess) {
            context
                .read<MainWrapperCubit>()
                .setBottomNavigationVisibility(false);
            context.read<MainWrapperCubit>().setSongControlVisibility(false);
            context.pushNamed(
              'audioBook',
              extra: {
                'book': state.book, // Gửi đối tượng Book
                'authorName': state.authors.isNotEmpty
                    ? state.authors[0].name
                    : "Không rõ", // Gửi một chuỗi
              },
            );
            context.read<AudioCubit>().initOrResetAudio(
                  book: book,
                  authorName: state.authors.isNotEmpty
                      ? state.authors[0].name
                      : "Không rõ",
                );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng mua gói để truy cập'),
                duration: Duration(milliseconds: 700),
              ),
            );
          }
        };
      }
    } else if (book.bookType == BookType.ebook) {
      buttonIcon = Icons.menu_book;
      buttonLabel = 'Đọc ngay';
      if (book.fileUrl != null && book.fileUrl!.isNotEmpty) {
        onPressed = () {
          if (state.canAccess) {
            context
                .read<MainWrapperCubit>()
                .setBottomNavigationVisibility(false);
            context.read<MainWrapperCubit>().setSongControlVisibility(false);
            context.read<AudioCubit>().stop();
            context.pushNamed('bookReader', extra: book);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng mua gói để truy cập'),
                duration: Duration(milliseconds: 700),
              ),
            );
          }
        };
      }
    }

    if (state.isLoadingRelatedData) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(buttonIcon, color: Colors.white),
              label: Text(
                buttonLabel,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                disabledBackgroundColor: Colors.grey.shade400,
                disabledForegroundColor: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildMembershipSection(BuildContext context, Book book) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final String fonosCardPrice = currencyFormatter.format(70000.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mua với 1 thẻ Fonos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'TỪ $fonosCardPrice đ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Đăng ký Hội viên để nhận thẻ Fonos mỗi tháng, chỉ từ 70.000 đ/thẻ.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          const Text(
            'Bạn được sở hữu vĩnh viễn sau khi mua.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Đăng ký Hội viên',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, BookDetailLoaded state) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDescriptionSection(context, state.book),
          const SizedBox(height: 20),
          _buildReviewsSection(context, state),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, Book book) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giới thiệu sách',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ReadMoreText(
            book.description,
            trimLines: 4,
            colorClickableText: Colors.blueAccent,
            trimMode: TrimMode.Line,
            trimCollapsedText: 'Đọc thêm',
            trimExpandedText: 'Thu gọn',
            style: Theme.of(context).textTheme.bodyMedium,
            moreStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
            lessStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, BookDetailLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đánh giá (${state.totalReviews})',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildReviewForm(context),
          const SizedBox(height: 20),
          _buildReviewsList(state),
        ],
      ),
    );
  }

  Widget _buildReviewForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Để lại đánh giá của bạn:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Viết bình luận của bạn...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.blueAccent, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      User? user = await AppStorage.getUser();

                      if (context.mounted) {
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Vui lòng đăng nhập để sử dụng tính năng'),
                              duration: Duration(milliseconds: 700),
                            ),
                          );
                          return;
                        }

                        if (_selectedRating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Vui lòng chọn số sao đánh giá.')),
                          );
                          return;
                        }

                        if (_commentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Vui lòng không để trống bình luận')),
                          );
                          return;
                        }

                        context.read<BookDetailBloc>().add(CreateReviewEvent(
                              bookId: widget.initialBook.bookId,
                              rating: _selectedRating,
                              comment: _commentController.text,
                            ));
                        setState(() {
                          _commentController.clear();
                          _selectedRating = 0;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Gửi đánh giá',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewsList(BookDetailLoaded state) {
    if (state.isLoadingRelatedData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.reviews.isEmpty) {
      return const Text(
        'Chưa có đánh giá nào cho sách này.',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    return Column(
      children: state.reviews.map<Widget>((review) {
        // Kiểm tra xem review này có phải của người dùng hiện tại không
        bool isMyReview =
            _user?.userId != null && _user?.userId == review.userId;

        // Nếu là review của người dùng hiện tại, bọc nó trong Slidable
        if (isMyReview) {
          return Slidable(
            key: ValueKey(review.reviewId),
            // Key duy nhất cho Slidable (quan trọng!)
            endActionPane: ActionPane(
              // Định nghĩa các hành động khi vuốt từ cuối (phải sang trái)
              motion: const StretchMotion(), // Kiểu chuyển động khi vuốt
              children: [
                // // Nút Sửa
                // SlidableAction(
                //   onPressed: (context) { // `context` ở đây là BuildContext của SlidableAction
                //     _showEditReviewDialog(context, state.book.bookId, review);
                //   },
                //   backgroundColor: Colors.blue,
                //   foregroundColor: Colors.white,
                //   icon: Icons.edit,
                //   label: 'Sửa',
                // ),
                // Nút Xóa
                SlidableAction(
                  onPressed: (context) {
                    // Khi nhấn vào nút xóa, hiển thị dialog xác nhận
                    _showDeleteReviewDialog(
                        context, review.reviewId, state.book.bookId);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Xóa',
                ),
              ],
            ),
            // Phần nội dung chính của mỗi item review
            child: _buildReviewCard(review, isMyReview),
          );
        } else {
          // Nếu không phải review của tôi, chỉ hiển thị Card review bình thường
          return _buildReviewCard(review, isMyReview);
        }
      }).toList(),
    );
  }

  Widget _buildReviewCard(Review review, bool isMyReview) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(
                  review.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Text(
                  isMyReview
                      ? 'Bạn'
                      : 'Người dùng: ${review.userId.substring(0, 4)}...',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yyyy').format(review.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(review.comment!),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteReviewDialog(
      BuildContext context, String reviewId, String bookId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final bookDetailBloc = context.read<BookDetailBloc>();

        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa đánh giá này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Đóng dialog ngay lập tức
                Navigator.of(dialogContext).pop();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  bookDetailBloc.add(DeleteReviewEvent(reviewId: reviewId));
                });
              },
            ),
          ],
        );
      },
    );
  }

// void _showEditReviewDialog(BuildContext context, String bookId, Review reviewToEdit) {
//   final TextEditingController editCommentController = TextEditingController(text: reviewToEdit.comment);
//   int editSelectedRating = reviewToEdit.rating;
//
//   // Lưu trữ tham chiếu tới BookDetailBloc trước khi hiển thị dialog
//   final bookDetailBloc = context.read<BookDetailBloc>();
//
//   showDialog(
//     context: context,
//     builder: (BuildContext dialogContext) {
//       return AlertDialog(
//         title: const Text('Sửa đánh giá'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               StatefulBuilder(
//                 builder: (context, setStateSB) {
//                   return Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(5, (index) {
//                       return IconButton(
//                         icon: Icon(
//                           index < editSelectedRating
//                               ? Icons.star
//                               : Icons.star_border,
//                           color: Colors.amber,
//                           size: 30,
//                         ),
//                         onPressed: () {
//                           setStateSB(() {
//                             editSelectedRating = index + 1;
//                           });
//                         },
//                       );
//                     }),
//                   );
//                 },
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: editCommentController,
//                 maxLines: 4,
//                 decoration: InputDecoration(
//                   hintText: 'Sửa bình luận của bạn...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Hủy'),
//             onPressed: () {
//               Navigator.of(dialogContext).pop();
//             },
//           ),
//           TextButton(
//             child: const Text('Lưu'),
//             onPressed: () async {
//               if (editSelectedRating == 0) {
//                 ScaffoldMessenger.of(dialogContext).showSnackBar(
//                   const SnackBar(content: Text('Vui lòng chọn số sao đánh giá.')),
//                 );
//                 return;
//               }
//               if (editCommentController.text.isEmpty) {
//                 ScaffoldMessenger.of(dialogContext).showSnackBar(
//                   const SnackBar(content: Text('Bình luận không được để trống.')),
//                 );
//                 return;
//               }
//
//               // Sử dụng tham chiếu đã lưu để gửi sự kiện
//               bookDetailBloc.add(
//                 UpdateReviewEvent(
//                   reviewId: reviewToEdit.reviewId,
//                   rating: editSelectedRating,
//                   comment: editCommentController.text,
//                 ),
//               );
//               Navigator.of(dialogContext).pop();
//
//               // Giải phóng controller
//               editCommentController.dispose();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
}
