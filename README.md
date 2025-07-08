# Ebook TUH

Ebook TUH là ứng dụng đọc sách và nghe sách nói đa nền tảng được phát triển bằng Flutter. Ứng dụng hỗ trợ quản lý thư viện sách, nghe audio book, tìm kiếm, đánh dấu, và nhiều tính năng hiện đại khác.

## Tính năng chính
- Đọc sách điện tử (ebook) với giao diện đẹp, dễ sử dụng
- Nghe sách nói (audio book) với trình phát hiện đại, hỗ trợ tua, thay đổi tốc độ
- Tìm kiếm sách
- Xem chi tiết tác giả, danh sách tác phẩm của tác giả
- Đánh dấu sách yêu thích, thêm vào danh sách cá nhân
- Hỗ trợ đa nền tảng: Android, iOS
- Đăng nhập, đăng ký, xác thực người dùng (Firebase Auth)
- Lưu trữ dữ liệu đám mây (Firebase, Cloud Storage)
- Giao diện responsive
- Thanh toán mua premium (Stripe)

## Cấu trúc thư mục
```
lib/
  constants/         # Các hằng số dùng chung (font size, màu sắc...)
  controllers/       # Xử lý logic, điều khiển dữ liệu
  data/              # Dữ liệu mẫu, truy vấn dữ liệu
  models/            # Định nghĩa các model (Book, Author...)
  navigation/        # Điều hướng, router
  services/          # Dịch vụ bên ngoài (API, Firebase...)
  utils/             # Tiện ích, helper
  views/             # Giao diện UI, chia theo màn hình (audio_book, author, main_wrapper...)
    audio_book/      # Giao diện và logic sách nói
    author/          # Giao diện và logic tác giả
    ...
  widgets/           # Các widget tái sử dụng (nút, danh sách...)
assets/
  images/            # Ảnh minh họa
  icons/             # Icon tuỳ chỉnh
android/             # Mã nguồn Android
ios/                 # Mã nguồn iOS
web/                 # Mã nguồn Web
macos/               # Mã nguồn macOS
windows/             # Mã nguồn Windows
linux/               # Mã nguồn Linux
```

## Công nghệ sử dụng
- Flutter 3.x
- Dart
- Firebase (Auth, Storage, Firestore)
- BLoC/Cubit (flutter_bloc)
- CachedNetworkImage, ReadMore, GoRouter, v.v.

## Hướng dẫn cài đặt
1. Clone repo:
   ```bash
   git clone https://github.com/yourusername/ebook_tuh.git
   cd ebook_tuh
   ```
2. Cài đặt dependencies:
   ```bash
   flutter pub get
   ```
3. Chạy ứng dụng:
   ```bash
   flutter run
   ```

## Bản quyền
Dự án phát triển phục vụ học tập, phi thương mại.
