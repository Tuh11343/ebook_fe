import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:flutter/material.dart';

import '../constants/asset_images.dart';
import '../models/book.dart';

class ListBookVertical extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book>? onBookTap;
  final bool? canScroll;

  const ListBookVertical({
    super.key,
    required this.books,
    this.onBookTap,
    this.canScroll
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy sách nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử tìm kiếm với từ khóa khác',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: books.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: (canScroll ?? true)
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final book = books[index];
        return GestureDetector(
          onTap: () => onBookTap?.call(book),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onBookTap?.call(book),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Cover với hiệu ứng đẹp hơn
                      Hero(
                        tag: 'book_cover_${book.bookId}',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                spreadRadius: 0,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: book.coverImageUrl ?? AssetImages.defaultBookHolder,
                              width: 100,
                              height: 140,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 100,
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.grey[200]!,
                                      Colors.grey[100]!,
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.auto_stories_outlined,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 100,
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.grey[300]!,
                                      Colors.grey[200]!,
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Book Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Book Title
                            Text(
                              book.title,
                              style: const TextStyle(
                                fontSize: AppFontSize.normal,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Book Type và Access Type badges
                            Row(
                              children: [
                                _buildBadge(
                                  _getBookTypeLabel(book.bookType),
                                  _getBookTypeColor(book.bookType),
                                  _getBookTypeIcon(book.bookType),
                                ),
                                const SizedBox(width: 8),
                                _buildBadge(
                                  _getAccessTypeLabel(book.accessType),
                                  _getAccessTypeColor(book.accessType),
                                  _getAccessTypeIcon(book.accessType),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Book Description
                            Text(
                              book.description,
                              style: TextStyle(
                                fontSize: AppFontSize.small,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),

                            // Additional Info (Price, Pages, Duration)
                            Row(
                              children: [
                                if (book.accessType == AccessType.purchase && book.price != null)
                                  _buildInfoChip(
                                    Icons.attach_money,
                                    '${book.price!.toStringAsFixed(0)}đ',
                                    Colors.green,
                                  ),
                                if (book.bookType == BookType.ebook && book.pages != null) ...[
                                  if (book.accessType == AccessType.purchase) const SizedBox(width: 8),
                                  _buildInfoChip(
                                    Icons.chrome_reader_mode_outlined,
                                    '${book.pages} trang',
                                    Colors.blue,
                                  ),
                                ],
                                if (book.bookType == BookType.audiobook && book.durationMinutes != null) ...[
                                  if (book.accessType == AccessType.purchase || book.pages != null) const SizedBox(width: 8),
                                  _buildInfoChip(
                                    Icons.headphones_outlined,
                                    '${_formatDuration(book.durationMinutes!)}',
                                    Colors.purple,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getBookTypeLabel(BookType type) {
    switch (type) {
      case BookType.ebook:
        return 'E-book';
      case BookType.audiobook:
        return 'Audio';
    }
  }

  Color _getBookTypeColor(BookType type) {
    switch (type) {
      case BookType.ebook:
        return Colors.blue;
      case BookType.audiobook:
        return Colors.purple;
    }
  }

  IconData _getBookTypeIcon(BookType type) {
    switch (type) {
      case BookType.ebook:
        return Icons.menu_book;
      case BookType.audiobook:
        return Icons.headphones;
    }
  }

  String _getAccessTypeLabel(AccessType type) {
    switch (type) {
      case AccessType.free:
        return 'Miễn phí';
      case AccessType.premium:
        return 'Premium';
      case AccessType.purchase:
        return 'Mua';
    }
  }

  Color _getAccessTypeColor(AccessType type) {
    switch (type) {
      case AccessType.free:
        return Colors.green;
      case AccessType.premium:
        return Colors.orange;
      case AccessType.purchase:
        return Colors.red;
    }
  }

  IconData _getAccessTypeIcon(AccessType type) {
    switch (type) {
      case AccessType.free:
        return Icons.lock_open;
      case AccessType.premium:
        return Icons.diamond;
      case AccessType.purchase:
        return Icons.shopping_cart;
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${minutes}m';
    }
  }
}