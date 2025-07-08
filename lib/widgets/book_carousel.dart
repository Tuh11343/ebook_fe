import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/asset_images.dart';
import '../models/book.dart';

class BigBookCarousel extends StatefulWidget {
  final List<Book> bookList;
  final ValueChanged<Book>? onActiveBookChanged;

  const BigBookCarousel({
    super.key,
    required this.bookList,
    this.onActiveBookChanged,
  });

  @override
  State<BigBookCarousel> createState() => _BigBookCarouselState();
}

class _BigBookCarouselState extends State<BigBookCarousel> {
  int _activeIndex = 0;
  final Duration _animationDuration = const Duration(milliseconds: 500);
  final Curve _animationCurve = Curves.easeInOutCubic;
  final Offset _inactiveOffset = const Offset(0, -0.7);

  @override
  Widget build(BuildContext context) {
    if (widget.bookList.isEmpty) {
      return SizedBox(
        height: 320,
        child: Center(
          child: Text(
            "Không có sách nào để hiển thị.",
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ),
      );
    }

    return CarouselSlider.builder(
      itemCount: widget.bookList.length,
      itemBuilder: (context, index, realIndex) {
        final book = widget.bookList[index];
        final bool isActive = _activeIndex == index;

        return GestureDetector(
          onTap: () {
            context.push("/detailBook", extra: book);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isActive ? 0.2 : 0.1),
                        spreadRadius: isActive ? 2 : 1,
                        blurRadius: isActive ? 10 : 5,
                        offset: Offset(0, isActive ? 5 : 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          width: double.infinity,
                          imageUrl: book.coverImageUrl ?? AssetImages.defaultBookHolder,
                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                              Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                          errorWidget: (context, url, error) =>
                          const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50)),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _buildBookTypeChip(book.bookType),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _buildAccessBadge(book.accessType),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: ClipRect(
                  child: AnimatedSlide(
                    offset: isActive ? Offset.zero : _inactiveOffset,
                    duration: _animationDuration,
                    curve: _animationCurve,
                    child: AnimatedOpacity(
                      opacity: isActive ? 1.0 : 0.0,
                      duration: _animationDuration,
                      curve: _animationCurve,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFdf97a0),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isActive ? 0.1 : 0.0),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            book.title,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: AppFontSize.small,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      options: CarouselOptions(
        height: 320,
        initialPage: _activeIndex,
        enlargeCenterPage: true,
        viewportFraction: 0.55,
        enableInfiniteScroll: widget.bookList.length > 1,
        enlargeFactor: 0.25,
        scrollPhysics: const BouncingScrollPhysics(),
        onPageChanged: (index, reason) {
          if (mounted) {
            setState(() {
              _activeIndex = index;
            });
            widget.onActiveBookChanged?.call(widget.bookList[index]);
          }
        },
      ),
    );
  }

  Widget _buildBookTypeChip(BookType bookType) {
    final isEbook = bookType == BookType.ebook;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEbook ? Colors.blue[50] : Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEbook ? Colors.blue[200]! : Colors.purple[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEbook ? Icons.menu_book_rounded : Icons.headphones_rounded,
            size: 12,
            color: isEbook ? Colors.blue[700] : Colors.purple[700],
          ),
          const SizedBox(width: 4),
          Text(
            isEbook ? 'Ebook' : 'Audio',
            style: TextStyle(
              fontSize: 10,
              color: isEbook ? Colors.blue[700] : Colors.purple[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessBadge(AccessType accessType) {
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    switch (accessType) {
      case AccessType.free:
        badgeColor = Colors.green;
        badgeIcon = Icons.lock_open_rounded;
        badgeText = 'Free';
        break;
      case AccessType.premium:
        badgeColor = Colors.amber;
        badgeIcon = Icons.workspace_premium_rounded;
        badgeText = 'Premium';
        break;
      case AccessType.purchase:
        badgeColor = Colors.blue;
        badgeIcon = Icons.shopping_cart_rounded;
        badgeText = 'Purchase';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}