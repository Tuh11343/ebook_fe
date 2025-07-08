import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:ebook_tuh/widgets/section_title_with_icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/asset_images.dart';
import '../models/book.dart';

class HorizontalBookList extends StatelessWidget {
  final String title;
  final bool? showTitle;
  final List<Book> books;
  final void Function(Book)? onBookTap;

  const HorizontalBookList({
    super.key,
    required this.title,
    this.showTitle,
    required this.books,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle == true) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SectionTitleWithIcon(
              title: title,
              leadingIcon: FontAwesomeIcons.cloud,
            ),
          ),
        ],
        const SizedBox(height: 16),
        CarouselSlider.builder(
          itemCount: books.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            final book = books[index];
            return GestureDetector(
              onTap: () => onBookTap?.call(book),
              child: SizedBox(
                height: 320, // Must match CarouselOptions height
                child: _buildBookCard(book),
              ),
            );
          },
          options: CarouselOptions(
            height: 320,
            // Explicitly set height for CarouselSlider items
            viewportFraction: 0.45,
            initialPage: 0,
            autoPlay: books.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOutCubic,
            enlargeCenterPage: true,
            enlargeFactor: 0.25,
            scrollDirection: Axis.horizontal,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBookCard(Book book) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16.0)),
                  child: CachedNetworkImage(
                    imageUrl:
                        book.coverImageUrl ?? AssetImages.defaultBookHolder,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16.0)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
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
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppFontSize.normal,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.language_rounded,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                book.language.toUpperCase(),
                                style: TextStyle(
                                  fontSize: AppFontSize.small,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (book.accessType == AccessType.purchase &&
                          book.price != null)
                        _buildPriceTag(book.price!),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
        badgeText = 'Pro';
        break;
      case AccessType.purchase:
        badgeColor = Colors.blue;
        badgeIcon = Icons.shopping_cart_rounded;
        badgeText = 'Buy';
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

  Widget _buildPriceTag(double price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!, width: 1),
      ),
      child: Text(
        '${price.toStringAsFixed(0)}đ',
        style: TextStyle(
          fontSize: 10,
          color: Colors.green[700],
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
