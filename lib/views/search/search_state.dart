import 'package:equatable/equatable.dart';

import '../../models/book.dart';
import '../../models/genre.dart';

enum SearchStatus {
  initial,
  loading,           // Loading khi fetch books
  loadingGenres,     // Loading khi fetch genres
  filtering,         // Loading khi apply filter (genre/sort)
  loaded,
  error
}

enum SortOption {
  none(''),
  title('Tên sách'),
  rating('Đánh giá');

  const SortOption(this.displayName);
  final String displayName;
}

class SearchFilters extends Equatable {
  final String searchText;
  final String? genreId;
  final SortOption sortOption;

  const SearchFilters({
    this.searchText = '',
    this.genreId,
    this.sortOption = SortOption.none,
  });

  SearchFilters copyWith({
    String? searchText,
    String? genreId,
    SortOption? sortOption,
  }) {
    return SearchFilters(
      searchText: searchText ?? this.searchText,
      genreId: genreId ?? this.genreId,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  SearchFilters clearGenre() {
    return SearchFilters(
      searchText: searchText,
      genreId: null,
      sortOption: sortOption,
    );
  }

  SearchFilters clearSort() {
    return SearchFilters(
      searchText: searchText,
      genreId: genreId,
      sortOption: SortOption.none,
    );
  }

  SearchFilters reset() {
    return const SearchFilters();
  }

  @override
  List<Object?> get props => [searchText, genreId, sortOption];
}

class SearchState extends Equatable {
  final SearchStatus status;
  final List<Book> books;
  final List<Genre> genres;
  final SearchFilters filters;
  final String? errorMessage;
  final bool isGenresLoaded;

  const SearchState({
    this.status = SearchStatus.initial,
    this.books = const [],
    this.genres = const [],
    this.filters = const SearchFilters(),
    this.errorMessage,
    this.isGenresLoaded = false,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<Book>? books,
    List<Genre>? genres,
    SearchFilters? filters,
    String? errorMessage,
    bool? isGenresLoaded,
  }) {
    return SearchState(
      status: status ?? this.status,
      books: books ?? this.books,
      genres: genres ?? this.genres,
      filters: filters ?? this.filters,
      errorMessage: errorMessage,
      isGenresLoaded: isGenresLoaded ?? this.isGenresLoaded,
    );
  }

  SearchState clearError() {
    return copyWith(errorMessage: null);
  }

  @override
  List<Object?> get props => [
    status,
    books,
    genres,
    filters,
    errorMessage,
    isGenresLoaded,
  ];
}
