import 'dart:async';

import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:ebook_tuh/views/search/search_cubit.dart';
import 'package:ebook_tuh/views/search/search_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_color.dart';
import '../../widgets/book_list_vertical.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchCubit>().initialize();
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<SearchCubit>().refresh();
  }

  void _showFilteringModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Thể loại',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  if (!state.isGenresLoaded)
                    const CircularProgressIndicator()
                  else if (state.genres.isEmpty)
                    const Text('Không có thể loại nào.')
                  else
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.genres.length,
                        itemBuilder: (context, index) {
                          final genre = state.genres[index];
                          return RadioListTile<String>(
                            title: Text(genre.name),
                            value: genre.genreId,
                            groupValue: state.filters.genreId,
                            toggleable: true,
                            onChanged: (String? newValue) {
                              context.read<SearchCubit>().updateGenreFilter(newValue);
                              Navigator.pop(context);
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

  void _showSortingModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sắp xếp',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: SortOption.values.length - 1, // Exclude 'none'
                    itemBuilder: (context, index) {
                      final sortOption = SortOption.values[index + 1]; // Skip 'none'
                      return RadioListTile<SortOption>(
                        title: Text(sortOption.displayName),
                        value: sortOption,
                        groupValue: state.filters.sortOption == SortOption.none
                            ? null
                            : state.filters.sortOption,
                        toggleable: true,
                        onChanged: (SortOption? newValue) {
                          context.read<SearchCubit>().updateSortOption(newValue);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onSearchTextChanged(String text) {
    // _textEditingController.text = text;
    context.read<SearchCubit>().updateSearchText(text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchCubit, SearchState>(
      listener: (context, state) {
        if (state.filters.searchText.isEmpty && _textEditingController.text.isNotEmpty) {
          _textEditingController.clear();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3E5151), Color(0xFFDECBA4)],
                stops: [0.0, 0.4],
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: SearchBar(
                          controller: _textEditingController,
                          padding: const MaterialStatePropertyAll<EdgeInsets>(
                              EdgeInsets.symmetric(horizontal: 16.0)),
                          onChanged: _onSearchTextChanged,
                          leading: const Icon(Icons.search, color: AppColors.darkGrey),
                          hintText: 'Tìm kiếm sách',
                          // ... other SearchBar properties
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          context.read<SearchCubit>().resetFilters();
                        },
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter and Sort buttons với loading indicators
                BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    final isFiltering = state.status == SearchStatus.filtering;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Genre Filter Button
                          TextButton.icon(
                            onPressed: isFiltering ? null : () => _showFilteringModalBottomSheet(context),
                            icon: isFiltering
                                ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Icon(Icons.filter_list, size: 16, color: Colors.white),
                            label: Text(
                              state.filters.genreId != null
                                  ? 'Lọc: ${context.read<SearchCubit>().selectedGenre?.name ?? ""}'
                                  : 'Lọc thể loại',
                              style: TextStyle(
                                fontSize: AppFontSize.normal,
                                color: isFiltering ? Colors.white70 : Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          // Sort Button
                          TextButton.icon(
                            onPressed: isFiltering ? null : () => _showSortingModalBottomSheet(context),
                            icon: const Icon(Icons.sort, size: 16, color: Colors.white),
                            label: Text(
                              state.filters.sortOption != SortOption.none
                                  ? 'Sắp xếp: ${state.filters.sortOption.displayName}'
                                  : 'Sắp xếp',
                              style: TextStyle(
                                fontSize: 16,
                                color: isFiltering ? Colors.white70 : Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Books list
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                    decoration: const BoxDecoration(
                      color: AppColors.whiteGrayContainer,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: BlocBuilder<SearchCubit, SearchState>(
                      builder: (context, state) {
                        // Show loading for initial load
                        if (state.status == SearchStatus.loading && state.books.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        // Show loading for genres
                        else if (state.status == SearchStatus.loadingGenres) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        // Show error
                        else if (state.status == SearchStatus.error) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Lỗi: ${state.errorMessage}',
                                  style: const TextStyle(color: Colors.red, fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.read<SearchCubit>().refresh(),
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          );
                        }
                        // Show empty state
                        else if (state.books.isEmpty && state.status == SearchStatus.loaded) {
                          return const Center(
                            child: Text(
                              'Không tìm thấy sách nào phù hợp.',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.whiteGrayContainer,
                              ),
                            ),
                          );
                        }

                        // Show books list with optional loading overlay
                        return Stack(
                          children: [
                            RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: ListBookVertical(books: state.books),
                            ),
                            // Show loading overlay when filtering
                            if (state.status == SearchStatus.filtering)
                              Container(
                                color: Colors.black.withOpacity(0.3),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
