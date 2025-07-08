import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/book.dart';
import '../main_wrapper/main_wrapper_cubit.dart';
import 'book_reader_bloc.dart';
import 'book_reader_event.dart';
import 'book_reader_state.dart';

class BookReaderPage extends StatefulWidget {
  final Book book;
  final String epubPath;

  const BookReaderPage({
    super.key,
    required this.book,
    required this.epubPath,
  });

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  double _currentSliderValue = 16;

  // Hàm hiển thị Font Size Picker
  void _showFontSizePicker(BuildContext context, BookReaderLoaded state) {
    _currentSliderValue = state.currentFontSize;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Để Container kiểm soát màu nền
      builder: (BuildContext bc) {
        // bc là BuildContext của BottomSheet
        return StatefulBuilder(
          // <<< PHẢI CÓ STATEFULBUILDER Ở ĐÂY
          builder: (BuildContext innerContext, StateSetter innerSetState) {
            return Container(
              decoration: BoxDecoration(
                color: state.isNightMode
                    ? Colors.black.withOpacity(0.8)
                    : Colors.white.withOpacity(0.9),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Kích thước chữ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: state.isNightMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    // Giá trị của Slider LẤY TỪ BIẾN CỤC BỘ CỦA STATEFULBUILDER
                    value: _currentSliderValue,
                    min: 12.0,
                    max: 28.0,
                    divisions: (28 - 12) ~/ 2,
                    label: _currentSliderValue.round().toString(),
                    activeColor:
                        state.isNightMode ? Colors.blueAccent : Colors.blue,
                    inactiveColor:
                        state.isNightMode ? Colors.grey[700] : Colors.grey[300],
                    onChanged: (double newValue) {
                      // GỌI innerSetState ĐỂ CẬP NHẬT BIẾN CỤC BỘ VÀ REBUILD CHỈ PHẦN NÀY
                      innerSetState(() {
                        _currentSliderValue = newValue;
                      });
                    },
                    onChangeEnd: (value) {
                      context
                          .read<BookReaderBloc>()
                          .add(ChangeFontSizeRequested(fontSize: value));
                    },
                  ),
                  Text(
                    // Hiển thị giá trị TỪ BIẾN CỤC BỘ CỦA STATEFULBUILDER
                    'Kích thước hiện tại: ${_currentSliderValue.round()}',
                    style: TextStyle(
                        color: state.isNightMode
                            ? Colors.white70
                            : Colors.black87),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Hàm hiển thị Mục lục
  void _showTableOfContents(
      BuildContext parentContext, BookReaderLoaded state) {
    showModalBottomSheet(
      backgroundColor: state.isNightMode ? Colors.black : Colors.white,
      context: parentContext,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Mục lục',
                        style: TextStyle(
                            color:
                                state.isNightMode ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: state.epubController.tableOfContents().length,
                      itemBuilder: (context, index) {
                        final chapter =
                            state.epubController.tableOfContents()[index];
                        return ListTile(
                          title: Text(
                            chapter.title ?? 'Chương ${index + 1}',
                            style: TextStyle(
                                color: state.isNightMode
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 16),
                          ),
                          onTap: () async {
                            state.epubController
                                .scrollTo(index: chapter.startIndex);
                            Navigator.pop(parentContext);
                            parentContext
                                .read<BookReaderBloc>()
                                .add(ToggleToolbarVisibility());
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
      },
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<BookReaderBloc>()
          .add(LoadEpubRequested(epubPath: widget.epubPath, book: widget.book));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: WillPopScope(
        onWillPop: () async {
          context.read<MainWrapperCubit>().setBottomNavigationVisibility(true);
          return true;
        },
        child: BlocConsumer<BookReaderBloc, BookReaderState>(
          listener: (context, state) {
            if (state is BookReaderAction) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green, // Sử dụng AppColors
                ),
              );
            } else if (state is BookReaderError) {}
          },
          builder: (context, state) {
            if (state is BookReaderLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is BookReaderError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            } else if (state is BookReaderLoaded) {
              final Color textColor =
                  state.isNightMode ? Colors.white : Colors.black;
              final Color backgroundColor =
                  state.isNightMode ? Colors.black : Colors.white;

              return Stack(
                children: [
                  Container(color: backgroundColor),
                  GestureDetector(
                    onTap: () {
                      context
                          .read<BookReaderBloc>()
                          .add(ToggleToolbarVisibility());
                    },
                    child: EpubView(
                      controller: state.epubController,
                      onDocumentLoaded: (document) {
                        debugPrint('Tài liệu EPUB đã tải: ${document.Title}');
                      },
                      builders: EpubViewBuilders<DefaultBuilderOptions>(
                        options: DefaultBuilderOptions(
                          textStyle: TextStyle(
                              fontSize: state.currentFontSize,
                              color: textColor),
                        ),
                        chapterDividerBuilder: (EpubChapter chapter) {
                          final Color bgColor = state.isNightMode
                              ? Colors.grey.withOpacity(0.5)
                              : Colors.grey.shade200.withOpacity(0.9);
                          return Container(
                            color: bgColor,
                            alignment: Alignment.centerLeft,
                            // Căn chỉnh chữ sang trái
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Text(
                              chapter.Title ?? 'Chương ?',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Thanh công cụ trên cùng
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: state.showToolbar ? 0 : -kToolbarHeight * 2,
                    left: 0,
                    right: 0,
                    child: AppBar(
                      backgroundColor: Colors.black.withOpacity(0.7),
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          // Xử lý khi nhấn nút back trên AppBar
                          // Bật lại Bottom Navigation Bar
                          context
                              .read<MainWrapperCubit>()
                              .setBottomNavigationVisibility(true);
                          Navigator.pop(context); // Đóng trang hiện tại
                        },
                      ),
                      title: Text(
                        widget.book.title,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.bookmark_border,
                              color: Colors.white),
                          onPressed: () {
                            EpubController epubController =
                                state.epubController;

                            print('Chapter hiện tại:${epubController.currentValue?.chapterNumber} cfi:${epubController.epubCfi}  generate:${epubController.generateEpubCfi()}');

                            String? cfi=epubController.generateEpubCfi();

                            context.read<BookReaderBloc>().add(
                                AddBookmarkRequested(
                                    bookId: widget.book.bookId,
                                    chapterTitle: epubController
                                        .currentValue?.chapter?.Title,
                                    chapterNumber: epubController
                                        .currentValue?.chapterNumber,
                                    paragraphNumber: epubController
                                        .currentValue?.paragraphNumber,
                                    cfi: cfi));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.note_alt, color: Colors.white),
                          onPressed: () {
                            _showBookmarks(context, state);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Thanh công cụ dưới cùng
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: state.showToolbar ? 0 : -kToolbarHeight * 2,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: kToolbarHeight,
                      color: Colors.black.withOpacity(0.7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.format_size,
                                color: Colors.white),
                            onPressed: () {
                              _showFontSizePicker(context, state);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.lightbulb_outline,
                                color: Colors.white),
                            onPressed: () {
                              context
                                  .read<BookReaderBloc>()
                                  .add(ToggleNightMode());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.content_copy,
                                color: Colors.white),
                            onPressed: () {
                              _showTableOfContents(context, state);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showBookmarks(BuildContext parentContext, BookReaderLoaded state) {
    showModalBottomSheet(
      backgroundColor: state.isNightMode ? Colors.black : Colors.white,
      context: parentContext,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Đánh dấu trang',
                        style: TextStyle(
                            color:
                                state.isNightMode ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: state.bookmarks.isEmpty
                        ? Center(
                            child: Text(
                              'Bạn chưa có đánh dấu trang nào.',
                              style: TextStyle(
                                color: state.isNightMode
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: state.bookmarks.length,
                            itemBuilder: (context, index) {
                              final bookmark = state.bookmarks[index];
                              return ListTile(
                                title: Text(
                                  bookmark.chapterTitle ??
                                      'Chương ${bookmark.paragraphNumber ?? '?'}',
                                  // Fallback title
                                  style: TextStyle(
                                      color: state.isNightMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 16),
                                ),
                                subtitle: Text(
                                  'Chương ${bookmark.chapterNumber != null ? bookmark.chapterNumber! + 1 : '?'} - Vị trí: ${bookmark.paragraphNumber}',
                                  style: TextStyle(
                                      color: state.isNightMode
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 14),
                                ),
                                onTap: () async {
                                  String? cfi = bookmark.cfi;
                                  if (cfi != null && cfi.isNotEmpty) {
                                    print('Đi tới:${cfi}');
                                    state.epubController.gotoEpubCfi(cfi);
                                  } else {}

                                  Navigator.pop(
                                      parentContext); // Close the bottom sheet
                                  parentContext.read<BookReaderBloc>().add(
                                      ToggleToolbarVisibility()); // Hide toolbar
                                },
                                trailing: IconButton(
                                  icon: Icon(Icons.delete,
                                      color: state.isNightMode
                                          ? Colors.redAccent
                                          : Colors.red),
                                  onPressed: () {
                                    context.read<BookReaderBloc>().add(
                                        DeleteBookmark(
                                            readingProgressId: state
                                                .bookmarks[index].progressId,
                                            bookId: widget.book.bookId));

                                    Navigator.pop(
                                        parentContext); // Close the bottom sheet
                                    parentContext.read<BookReaderBloc>().add(
                                        ToggleToolbarVisibility()); // Hide toolbar

                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
