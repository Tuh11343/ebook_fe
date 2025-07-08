import 'package:ebook_tuh/constants/app_font_size.dart';
import 'package:flutter/material.dart';

class SectionTitleWithIcon extends StatelessWidget {
  final String title;
  final IconData? leadingIcon;
  final IconData trailingIcon;
  final VoidCallback? onTap;

  const SectionTitleWithIcon({
    super.key,
    required this.title,
    this.leadingIcon,
    this.trailingIcon = Icons.chevron_right,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min, // Đảm bảo Row chỉ chiếm không gian cần thiết
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: AppFontSize.extraLarge),
              ),
              if (leadingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  leadingIcon,
                  size: AppFontSize.extraLarge,
                  color: Colors.amber,
                ),
              ],
              const SizedBox(width: 8),
              Icon(
                trailingIcon,
                size: AppFontSize.extraLarge,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}