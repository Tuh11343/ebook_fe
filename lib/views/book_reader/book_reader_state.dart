import 'package:epub_view/epub_view.dart';
import 'package:epub_view/src/data/models/chapter_view_value.dart';

import '../../models/reading_progress.dart';
import '../../models/user.dart';

abstract class BookReaderState {}

class BookReaderInitial extends BookReaderState {}

class BookReaderLoading extends BookReaderState {}

class BookReaderLoaded extends BookReaderState {
  final String localEpubPath;
  final bool showToolbar;
  final EpubController epubController;
  final EpubChapterViewValue? currentChapter;
  final double currentFontSize;
  final bool isNightMode;
  final List<ReadingProgress> bookmarks;
  final User? user;

  BookReaderLoaded({
    required this.localEpubPath,
    this.showToolbar = true,
    required this.epubController,
    this.currentChapter,
    this.currentFontSize = 16.0,
    this.isNightMode = false,
    this.bookmarks = const [],
    this.user,
  });

  BookReaderLoaded copyWith({
    String? localEpubPath,
    bool? showToolbar,
    EpubController? epubController,
    EpubChapterViewValue? currentChapter,
    double? currentFontSize,
    bool? isNightMode,
    List<ReadingProgress>? bookmarks,
    User? user,
  }) {
    return BookReaderLoaded(
      localEpubPath: localEpubPath ?? this.localEpubPath,
      showToolbar: showToolbar ?? this.showToolbar,
      epubController: epubController ?? this.epubController,
      currentChapter: currentChapter ?? this.currentChapter,
      currentFontSize: currentFontSize ?? this.currentFontSize,
      isNightMode: isNightMode ?? this.isNightMode,
      bookmarks: bookmarks ?? this.bookmarks,
      user: user??this.user
    );
  }

  @override
  List<Object?> get props => [
    localEpubPath,
    showToolbar,
    epubController,
    currentChapter,
    currentFontSize,
    isNightMode,
    bookmarks,
    user
  ];
}

class BookReaderAction extends BookReaderState{
  final String message;
  BookReaderAction({required this.message});
}

class BookReaderError extends BookReaderState {
  final String message;
  BookReaderError({required this.message});
}
