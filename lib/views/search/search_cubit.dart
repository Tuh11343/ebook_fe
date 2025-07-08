import 'dart:async';

import 'package:ebook_tuh/controllers/app_controller.dart';
import 'package:ebook_tuh/views/search/search_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/book.dart';
import '../../models/genre.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState());

  Timer? _debounceTimer;

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  // === GENRES MANAGEMENT ===
  Future<void> loadGenres() async {
    if (state.isGenresLoaded) return;

    try {
      emit(state.copyWith(status: SearchStatus.loadingGenres));

      final genres = await AppControllers().genre.fetchAllGenres();

      emit(state.copyWith(
        genres: genres,
        isGenresLoaded: true,
        status: state.books.isEmpty ? SearchStatus.loaded : SearchStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.error,
        errorMessage: 'Không thể tải thể loại: $e',
      ));
    }
  }

  // === SEARCH MANAGEMENT ===
  void updateSearchText(String text) {
    final newFilters = state.filters.copyWith(searchText: text);
    emit(state.copyWith(filters: newFilters));

    _debounceSearch();
  }

  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(isDebounced: true);
    });
  }

  void searchImmediately() {
    _debounceTimer?.cancel();
    _performSearch(isDebounced: false);
  }

  // === FILTER MANAGEMENT ===
  void updateGenreFilter(String? genreId) {
    final newFilters = genreId == null
        ? state.filters.clearGenre()
        : state.filters.copyWith(genreId: genreId);

    emit(state.copyWith(filters: newFilters));
    _performSearch(isFiltering: true);
  }

  void updateSortOption(SortOption? sortOption) {
    final newFilters = sortOption == null || sortOption == SortOption.none
        ? state.filters.clearSort()
        : state.filters.copyWith(sortOption: sortOption);

    emit(state.copyWith(filters: newFilters));
    _performSearch(isFiltering: true);
  }

  void resetFilters() {
    emit(state.copyWith(filters: const SearchFilters()));
    _performSearch(isFiltering: true);
  }

  // === CORE SEARCH LOGIC ===
  Future<void> _performSearch({
    bool isDebounced = false,
    bool isFiltering = false,
  }) async {
    try {
      // Xác định loại loading state
      SearchStatus loadingStatus;
      if (isFiltering) {
        loadingStatus = SearchStatus.filtering;
      } else if (state.books.isEmpty) {
        loadingStatus = SearchStatus.loading;
      } else {
        // Không show loading khi đã có books và đang debounce search
        loadingStatus = state.status;
      }

      // Emit loading state nếu cần
      if (loadingStatus != state.status) {
        emit(state.copyWith(status: loadingStatus));
      }

      // Thêm delay nhỏ cho filtering để user thấy loading
      if (isFiltering) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final books = await _fetchAndSortBooks();

      emit(state.copyWith(
        status: SearchStatus.loaded,
        books: books,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.error,
        errorMessage: 'Không thể tải sách: $e',
      ));
    }
  }

  Future<List<Book>> _fetchAndSortBooks() async {
    final filters = state.filters;

    // Fetch books based on current filters
    final books = await AppControllers().book.searchBooks(
      searchText: filters.searchText.isNotEmpty ? filters.searchText : null,
      genreId: filters.genreId,
    );

    // Apply sorting
    return _sortBooks(books, filters.sortOption);
  }

  List<Book> _sortBooks(List<Book> books, SortOption sortOption) {
    final sortedBooks = List<Book>.from(books);

    switch (sortOption) {
      case SortOption.title:
        sortedBooks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.rating:
      // Assuming Book has a rating field
      // sortedBooks.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.none:
      // Keep original order
        break;
    }

    return sortedBooks;
  }

  Future<void> refresh() async {
    await _performSearch();
  }

  Future<void> initialize() async {
    await loadGenres();
    await _performSearch();
  }

  // === UTILITY GETTERS ===
  bool get hasActiveFilters =>
      state.filters.searchText.isNotEmpty ||
          state.filters.genreId != null ||
          state.filters.sortOption != SortOption.none;

  bool get isLoading =>
      state.status == SearchStatus.loading ||
          state.status == SearchStatus.loadingGenres ||
          state.status == SearchStatus.filtering;

  bool get isFilteringOrLoading =>
      state.status == SearchStatus.filtering ||
          state.status == SearchStatus.loading;

  Genre? get selectedGenre => state.filters.genreId != null
      ? state.genres.firstWhere(
        (genre) => genre.genreId == state.filters.genreId,
    orElse: () => throw StateError('Genre not found'),
  )
      : null;
}