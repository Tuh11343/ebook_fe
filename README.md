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
- Dart 3.x
- Android Studio Giraffe | 2022.3.1 Patch 1

## Hình ảnh minh họa
<div>
  <h3>Màn hình chính</h3>
  <img src="https://i.ibb.co/wF89Y6HX/d91952c3c0ec76b22ffd1.jpg" alt="Màn hình chính" width="200" style="margin-right: 15px;">
  <img src="https://i.ibb.co/My4trTfn/790eb1e823c79599ccd64.jpg" width="200" style="margin-right: 15px;">
  <img src="https://i.ibb.co/9m8VYy4D/c6a588411a6eac30f57f3.jpg" width="200" style="margin-right: 15px;">
  <img src="https://i.ibb.co/23sxp4Xt/13a74eb7dc986ac633899.jpg" width="200" style="margin-right: 15px;">
</div>

<div>
  <h3>Màn hình đăng nhập, đăng ký</h3>
  <img src="https://i.ibb.co/ZQxxDz8/00e2260fb420027e5b315.jpg" alt="Màn hình chính" width="200" style="margin-right: 15px;">
  <img src="https://i.ibb.co/TMkZdG0s/452a10d682f934a76de86.jpg" width="200" style="margin-right: 15px;">
  <img src="https://i.ibb.co/9HTRprCq/c882667df452420c1b437.jpg" width="200" style="margin-right: 15px;">
  <img src="https://i.ibb.co/cSpgjg5X/73565955cb7a7d24246b8.jpg" width="200" style="margin-right: 15px;">
</div>

<div>
  <h3>Màn hình nghe, đọc sách</h3>
  <img src="https://i.ibb.co/gLyXWJyV/38fcb19623b995e7cca816.jpg" alt="Màn hình nghe sách nói" width="200" style="margin-right: 15px;">
  <img src="https://i.ibb.co/vx32q84q/9be23f84adab1bf542ba15.jpg" alt="Màn hình đọc sách" width="200" style="margin-right: 15px;">
  <img src="https://i.ibb.co/0pqrqfdr/8062ea0d7822ce7c973317.jpg" alt="Màn hình đọc sách" width="200" style="margin-right: 15px;">
  <img src="https://i.ibb.co/KcTbpTH0/8fccf2b0609fd6c18f8e19.jpg" width="200" style="margin-right: 15px;">
</div>

<div>
  <h3>Màn hình thông tin chi tiết khác</h3>
  <img src="https://i.ibb.co/pBWfz6FQ/2ce935a3a78c11d2489d13.jpg" alt="Màn hình chính" width="200" style="margin-right: 15px;">
  <img src="https://i.ibb.co/XZjzpzmt/5c9f5bd2c9fd7fa326ec14.jpg" width="200" style="margin-right: 15px;">
  <img src="https://i.ibb.co/hjwXPmm/889ee38b71a4c7fa9eb510.jpg" width="200" style="margin-right: 15px;">
  <img src="https://i.ibb.co/MkmqcS65/ac0e7e16ec395a67032811.jpg" width="200" style="margin-right: 15px;">
  <img src="https://i.ibb.co/HTq1w8qb/be5ac9195b36ed68b42712.jpg" width="200" style="margin-right: 15px;">
</div>




## Bản quyền
Dự án phát triển phục vụ học tập, phi thương mại.
