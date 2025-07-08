import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:flutter/material.dart';

import '../constants/asset_images.dart';
import '../models/author.dart';

class AuthorHorizontalList extends StatelessWidget {
  final String title;
  final List<Author> authors;
  final void Function(Author)? onAuthorTap;

  const AuthorHorizontalList({
    super.key,
    required this.title,
    required this.authors,
    this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context) {
    if (authors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20,),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: authors.length,
              itemBuilder: (context, index) {
                final author = authors[index];
                return GestureDetector(
                    onTap: () => onAuthorTap?.call(author),
                    child: _buildAuthorCard(author),);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorCard(Author author) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: author.avatarUrl ?? AssetImages.defaultBookHolder,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.grey[300])),
                errorWidget: (context, url, error) =>
                    Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.person_outline, size: 40,
                            color: Colors.grey[500]),
                      ),
                    ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Tên tác giả
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              author.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppFontSize.small,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // Thêm một số thông tin khác nếu bio không null và bạn muốn hiển thị ngắn gọn
          if (author.bio != null && author.bio!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                author.bio!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
}