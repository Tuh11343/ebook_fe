
import '../../models/book.dart';
import 'package:epub_view/epub_view.dart';
import 'package:epub_view/src/data/models/chapter_view_value.dart';


abstract class BookReaderEvent {}

class LoadEpubRequested extends BookReaderEvent {
  final String epubPath;
  final Book book;

  LoadEpubRequested({required this.epubPath, required this.book});
}

class ToggleToolbarVisibility extends BookReaderEvent {}

// THÊM EVENT MỚI NÀY
class ChapterChanged extends BookReaderEvent {
  final EpubChapterViewValue? chapter;
  ChapterChanged({this.chapter});
}

// Các Event khác cho tương lai
class ChangeFontSizeRequested extends BookReaderEvent {
  final double fontSize;
  ChangeFontSizeRequested({required this.fontSize});
}

class ToggleNightMode extends BookReaderEvent {}

class GoToChapterRequested extends BookReaderEvent {
  final int chapterIndex;
  GoToChapterRequested({required this.chapterIndex});
}

class AddBookmarkRequested extends BookReaderEvent {
  final String bookId;
  final String? chapterTitle;
  final int? chapterNumber;
  final int? paragraphNumber;
  final String? cfi;

  AddBookmarkRequested({
    required this.bookId,
    this.chapterTitle,
    this.chapterNumber,
    this.paragraphNumber,
    this.cfi
  });
}

class DeleteBookmark extends BookReaderEvent {
  final String readingProgressId;
  final String bookId;
  DeleteBookmark({required this.readingProgressId,required this.bookId});
}
