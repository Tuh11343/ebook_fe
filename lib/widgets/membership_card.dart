import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ebook_tuh/constants/app_color.dart';
import 'package:flutter/material.dart';


class MembershipCard extends StatefulWidget {
  final List<String> titles;
  final List<String> descriptions;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const MembershipCard({
    super.key,
    required this.titles,
    required this.descriptions,
    required this.buttonText,
    required this.onButtonPressed,
  }) : assert(titles.length == descriptions.length, 'Titles and descriptions must have the same length');

  @override
  State<MembershipCard> createState() => _MembershipCardState();
}

class _MembershipCardState extends State<MembershipCard> {
  int _currentTextIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20,left: 20,bottom: 20),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8E2DE2),
            Color(0xFF4A00E0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            width: double.maxFinite,
            child: CarouselSlider.builder(
              itemCount: widget.titles.length,
              itemBuilder: (context, index, realIndex) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.titles[index], // Tiêu đề từ list
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      widget.descriptions[index], // Mô tả từ list
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14.0,
                      ),
                      maxLines: 2, // Giới hạn 2 dòng cho mô tả
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
              options: CarouselOptions(
                autoPlay: true, // Tự động cuộn qua các cặp văn bản
                autoPlayInterval: const Duration(seconds: 5), // Thời gian giữa các lần cuộn
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
                viewportFraction: 1.0, // Mỗi item chiếm toàn bộ chiều rộng
                enableInfiniteScroll: true, // Cuộn vô hạn
                scrollDirection: Axis.horizontal, // Hướng cuộn ngang
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentTextIndex = index; // Cập nhật index để các chấm pagination đổi màu
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 10.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.start, // Căn các chấm sang trái
            children: [
              ...List.generate(widget.titles.length, (index) {
                return Container(
                  width: _currentTextIndex == index ? 10.0 : 6.0, // Chấm active lớn hơn
                  height: 6.0,
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  decoration: BoxDecoration(
                    color: _currentTextIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                );
              }),
              const Spacer(), // Đẩy nút sang phải

              InkWell(
                onTap: widget.onButtonPressed, // Sử dụng callback từ widget
                borderRadius: BorderRadius.circular(20.0), // Bo tròn góc
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: AppColors.whiteGrayContainer,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5), // Viền trắng mờ
                  ),
                  child: Text(
                    widget.buttonText,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}