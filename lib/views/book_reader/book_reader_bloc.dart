import 'dart:io';

import 'package:ebook_tuh/constants/app_secure_storage.dart';
import 'package:ebook_tuh/controllers/app_controller.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../models/reading_progress.dart';
import '../../models/user.dart';
import 'book_reader_event.dart';
import 'book_reader_state.dart';

class BookReaderBloc extends Bloc<BookReaderEvent, BookReaderState> {
  BookReaderBloc() : super(BookReaderInitial()) {
    on<LoadEpubRequested>(_onLoadEpubRequested);
    on<ToggleToolbarVisibility>(_onToggleToolbarVisibility);
    on<ChapterChanged>(_onChapterChanged);
    on<ChangeFontSizeRequested>(_onChangeFontSizeRequested);
    on<ToggleNightMode>(_onToggleNightMode);
    on<AddBookmarkRequested>(_onAddBookmarkRequested);
    on<DeleteBookmark>(_onDeleteBookmark);
  }

  Future<void> _onLoadEpubRequested(
      LoadEpubRequested event, Emitter<BookReaderState> emit) async {
    emit(BookReaderLoading());
    try {
      String? localPath;
      if (event.epubPath.startsWith('http://') ||
          event.epubPath.startsWith('https://')) {
        final response = await http.get(Uri.parse(event.epubPath));
        if (response.statusCode == 200) {
          final directory = await getTemporaryDirectory();
          final fileName =
              '${event.book.title.replaceAll(RegExp(r'[^\w\s.-]'), '').replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.epub';
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          localPath = filePath;
        } else {
          emit(BookReaderError(
              message:
                  'Không thể tải sách từ URL: HTTP ${response.statusCode}'));
          return;
        }
      } else if (event.epubPath.startsWith('assets/')) {
        localPath = event.epubPath;
      } else {
        final file = File(event.epubPath);
        if (await file.exists()) {
          localPath = event.epubPath;
        } else {
          emit(BookReaderError(
              message:
                  'Đường dẫn file không hợp lệ hoặc không tồn tại: ${event.epubPath}'));
          return;
        }
      }

      if (localPath != null) {
        final epubController = EpubController(
          document: EpubDocument.openFile(File(localPath)),
        );

        User? user = await AppStorage.getUser();

        List<ReadingProgress> bookmarks = await AppControllers()
            .readingProgress
            .fetchBookmarksForBook(event.book.bookId);

        emit(BookReaderLoaded(
            localEpubPath: localPath,
            epubController: epubController,
            bookmarks: bookmarks,
            user: user));
      } else {
        emit(BookReaderError(
            message: 'Không có đường dẫn file EPUB hợp lệ để tải.'));
      }
    } catch (e) {
      emit(BookReaderError(message: 'Lỗi tải sách: ${e.toString()}'));
    }
  }

  void _onToggleToolbarVisibility(
      ToggleToolbarVisibility event, Emitter<BookReaderState> emit) {
    if (state is BookReaderLoaded) {
      final currentState = state as BookReaderLoaded;
      emit(currentState.copyWith(showToolbar: !currentState.showToolbar));
    }
  }

  // Xử lý sự kiện thay đổi kích thước font
  void _onChangeFontSizeRequested(
      ChangeFontSizeRequested event, Emitter<BookReaderState> emit) {
    if (state is BookReaderLoaded) {
      final currentState = state as BookReaderLoaded;
      emit(currentState.copyWith(currentFontSize: event.fontSize));
    }
  }

  // Xử lý sự kiện bật/tắt chế độ ban đêm
  void _onToggleNightMode(
      ToggleNightMode event, Emitter<BookReaderState> emit) {
    if (state is BookReaderLoaded) {
      final currentState = state as BookReaderLoaded;
      emit(currentState.copyWith(isNightMode: !currentState.isNightMode));
    }
  }

  // Đã sửa: Handler nhận đúng kiểu dữ liệu EpubChapterViewValue?
  void _onChapterChanged(ChapterChanged event, Emitter<BookReaderState> emit) {
    if (state is BookReaderLoaded) {
      final currentState = state as BookReaderLoaded;
      // Vùng logic đã thêm để kiểm tra sự thay đổi của chương
      if (event.chapter != null &&
          (currentState.currentChapter == null ||
              currentState.currentChapter!.chapterNumber !=
                  event.chapter!.chapterNumber)) {
        emit(currentState.copyWith(currentChapter: event.chapter));
      }
    }
  }

  void _onAddBookmarkRequested(
      AddBookmarkRequested event, Emitter<BookReaderState> emit) async {

    try{
      if (state is BookReaderLoaded) {
        final loadedState = state as BookReaderLoaded;

        if (loadedState.user == null) {
          emit(BookReaderError(message: 'Không có thông tin người dùng'));
          return;
        }

        await AppControllers().readingProgress.addBookmark(
          bookId: event.bookId,
          chapterNumber: event.chapterNumber,
          chapterTitle: event.chapterTitle,
          paragraphNumber: event.paragraphNumber,
          cfi: event.cfi,
          completed: false,
        );

        List<ReadingProgress> bookmarks = await AppControllers()
            .readingProgress
            .fetchBookmarksForBook(event.bookId);

        emit(BookReaderAction(message: 'Thêm dấu trang thành công'));

        emit(loadedState.copyWith(bookmarks: bookmarks));
      }
    }catch(ex){
      emit(BookReaderError(message: 'Add Bookmark failed:${ex}'));
    }
  }


  void _onDeleteBookmark(
      DeleteBookmark event, Emitter<BookReaderState> emit) async {

    try{
      if (state is BookReaderLoaded) {
        final loadedState = state as BookReaderLoaded;

        if (loadedState.user == null) {
          emit(BookReaderError(message: 'Không có thông tin người dùng'));
          return;
        }

        await AppControllers().readingProgress.deleteBookmark(event.readingProgressId);

        List<ReadingProgress> bookmarks = await AppControllers()
            .readingProgress
            .fetchBookmarksForBook(event.bookId);

        emit(BookReaderAction(message: 'Xóa dấu trang thành công'));

        emit(loadedState.copyWith(bookmarks: bookmarks));
      }
    }catch(ex){
      emit(BookReaderError(message: 'Add Bookmark failed:${ex}'));
    }
  }

  @override
  Future<void> close() {
    (state as BookReaderLoaded?)?.epubController.dispose();
    return super.close();
  }
}
