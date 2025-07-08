import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:flutter/material.dart';

import '../constants/asset_images.dart';
import '../models/book.dart';

class TopRatingCarousel extends StatelessWidget {
  final List<Book> bookList;
  final void Function(Book)? onBookTap;

  const TopRatingCarousel({super.key, required this.bookList, this.onBookTap});

  @override
  Widget build(BuildContext context) {
    if (bookList.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "Không có sách top rating nào.",
            style:
                TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ),
      );
    }

    return CarouselSlider.builder(
      itemCount: bookList.length,
      itemBuilder: (context, index, realIndex) {
        final book = bookList[index];
        final int displayIndex = index + 1;

        return GestureDetector(
          onTap: () => onBookTap?.call(book),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 10,
                  left: 10,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl:
                            book.coverImageUrl ?? AssetImages.defaultBookHolder,
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade300,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade400,
                          child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.white, size: 40)),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onPrimary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      displayIndex.toString(),
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary,
                        fontSize: AppFontSize.large,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 220,
        viewportFraction: 0.4,
        initialPage: 0,
        enableInfiniteScroll: false,
        scrollDirection: Axis.horizontal,
        enlargeCenterPage: false,
        scrollPhysics: const BouncingScrollPhysics(),
        padEnds: false,
      ),
    );
  }
}
