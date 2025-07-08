import 'package:uuid/uuid.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../models/genre.dart';
import '../models/premium_plans.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import '../models/user_subscription.dart';
import '../widgets/daily_quotes.dart'; // Cần import Uuid để tạo bookId

final Uuid _uuid = Uuid();

List<Book> dummyBooks = [
  Book(
    bookId: _uuid.v4(),
    title: 'Bí Mật Của Nước',
    description:
        'Một hành trình khám phá về các yếu tố bí ẩn của nước và ảnh hưởng của nó đến cuộc sống.',
    coverImageUrl:
        'https://thuvienhoasen.org/images/file/SFO5nWNm2ggBAmBH/hat-giong-tam-hon.png',
    bookType: BookType.ebook,
    accessType: AccessType.free,
    fileUrl: 'https://firebasestorage.googleapis.com/v0/b/book-41cab.appspot.com/o/Chu%CC%81ng%20Ta%20Se%CC%83%20To%CC%82%CC%81t%20Ho%CC%9Bn_Ca%CC%82%CC%80n%20Lao%20%C4%90i%CC%81ch%20Tie%CC%82%CC%89u%20Da%CC%83%20Mie%CC%82u.epub?alt=media&amp;token=f0e65269-2420-407a-b6d9-26eaf36a0818',
    audioFileUrl: 'https://firebasestorage.googleapis.com/v0/b/book-41cab.appspot.com/o/1-hatgiongtamhon.mp3?alt=media&token=1b664a66-38dc-4fdb-b7fd-5ff54c1fc9e4',
    pages: 250,
    publishedDate: DateTime(2022, 1, 15),
    language: 'Vietnamese',
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
    updatedAt: DateTime.now().subtract(const Duration(days: 30)),
  ),
  Book(
    bookId: _uuid.v4(),
    title: 'Sức Mạnh Của Thói Quen',
    description:
        'Cuốn sách phân tích cách thói quen hình thành và cách chúng ta có thể thay đổi chúng.',
    coverImageUrl:
        'https://www.nxbtre.com.vn/Images/Book/copy_22_nxbtre_full_19482018_034833.jpg',
    bookType: BookType.audiobook,
    accessType: AccessType.purchase,
    price: 9.99,
    audioFileUrl: 'http://example.com/audiobooks/suc-manh-thoi-quen.mp3',
    durationMinutes: 450,
    publishedDate: DateTime(2021, 5, 20),
    language: 'Vietnamese',
    createdAt: DateTime.now().subtract(const Duration(days: 500)),
    updatedAt: DateTime.now().subtract(const Duration(days: 15)),
  ),
  Book(
    bookId: _uuid.v4(),
    title: 'Đi Tìm Lẽ Sống',
    description:
        'Tác phẩm kinh điển về ý nghĩa cuộc sống và sự chịu đựng trong các trại tập trung.',
    coverImageUrl: 'https://i.ibb.co/gRwXWXQ/dacnhantam.png',
    bookType: BookType.ebook,
    accessType: AccessType.premium,
    price: 7.50,
    fileUrl: 'http://example.com/ebooks/di-tim-le-song.pdf',
    pages: 180,
    publishedDate: DateTime(2020, 11, 10),
    language: 'Vietnamese',
    createdAt: DateTime.now().subtract(const Duration(days: 700)),
    updatedAt: DateTime.now().subtract(const Duration(days: 45)),
  ),
  Book(
    bookId: _uuid.v4(),
    title: 'Tuổi Trẻ Đáng Giá Bao Nhiêu?',
    description:
        'Một cuốn sách truyền cảm hứng giúp bạn tận dụng tối đa tuổi trẻ của mình.',
    coverImageUrl:
        'http://bizweb.dktcdn.net/100/180/408/files/nhung-quy-tac-trong-cuoc-song-01.png?v=1609502016217',
    bookType: BookType.ebook,
    accessType: AccessType.free,
    fileUrl: 'http://example.com/ebooks/tuoi-tre.epub',
    pages: 200,
    audioFileUrl: 'http://example.com/audiobooks/tuoi-tre.mp3',
    durationMinutes: 300,
    publishedDate: DateTime(2019, 8, 5),
    language: 'Vietnamese',
    createdAt: DateTime.now().subtract(const Duration(days: 1000)),
    updatedAt: DateTime.now().subtract(const Duration(days: 60)),
  ),
  Book(
    bookId: _uuid.v4(),
    title: 'Nhà Giả Kim',
    description:
        'Câu chuyện huyền thoại về chàng chăn cừu Santiago đi tìm kho báu và lẽ sống.',
    coverImageUrl:
        'https://salt.tikicdn.com/media/catalog/product/t/h/thien-trong-nghe-thuat-ban-cung.jpg',
    bookType: BookType.ebook,
    accessType: AccessType.purchase,
    price: 6.25,
    fileUrl: 'http://example.com/ebooks/nha-gia-kim.pdf',
    pages: 160,
    publishedDate: DateTime(1988, 1, 1),
    language: 'Vietnamese',
    createdAt: DateTime.now().subtract(const Duration(days: 2000)),
    updatedAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  Book(
    bookId: _uuid.v4(),
    title: 'Hạt Giống Tâm Hồn',
    description:
        'Tuyển tập những câu chuyện ngắn đầy ý nghĩa, nuôi dưỡng tâm hồn.',
    coverImageUrl:
        'https://docsachhay.net/images/e-book/marketing-du-kich-trong-30-ngay.jpg',
    bookType: BookType.audiobook,
    accessType: AccessType.free,
    audioFileUrl: 'http://example.com/audiobooks/hat-giong-tam-hon.mp3',
    durationMinutes: 500,
    publishedDate: DateTime(2015, 3, 1),
    language: 'Vietnamese',
    createdAt: DateTime.now().subtract(const Duration(days: 1500)),
    updatedAt: DateTime.now().subtract(const Duration(days: 25)),
  ),
  Book(
    bookId: _uuid.v4(),
    title: 'Đắc Nhân Tâm',
    description:
        'Nghệ thuật thu phục lòng người và xây dựng các mối quan hệ hiệu quả.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1534439121110-123456789017?ixlib=rb-4.0.3&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max',
    bookType: BookType.ebook,
    accessType: AccessType.purchase,
    price: 12.00,
    fileUrl: 'http://example.com/ebooks/dac-nhan-tam.epub',
    pages: 300,
    audioFileUrl: 'http://example.com/audiobooks/dac-nhan-tam.mp3',
    durationMinutes: 600,
    publishedDate: DateTime(1936, 1, 1),
    // Sách kinh điển
    language: 'Vietnamese',
    createdAt: DateTime.now().subtract(const Duration(days: 3000)),
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Book(
    bookId: _uuid.v4(),
    title: 'Tư Duy Nhanh Và Chậm',
    description:
        'Khám phá hai hệ thống tư duy chi phối cách chúng ta suy nghĩ và ra quyết định.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1534439121110-123456789018?ixlib=rb-4.0.3&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max',
    bookType: BookType.ebook,
    accessType: AccessType.premium,
    price: null,
    // Không có giá nếu là subscription
    fileUrl: 'http://example.com/ebooks/tu-duy-nhanh-cham.pdf',
    pages: 500,
    publishedDate: DateTime(2011, 10, 25),
    language: 'Vietnamese',
    createdAt: DateTime.now().subtract(const Duration(days: 1200)),
    updatedAt: DateTime.now().subtract(const Duration(days: 20)),
  ),
  Book(
    bookId: _uuid.v4(),
    title: 'Muôn Kiếp Nhân Sinh',
    description:
        'Cuốn sách đưa người đọc đi sâu vào những bí ẩn của luân hồi và nghiệp báo.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1534439121110-123456789019?ixlib=rb-4.0.3&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max',
    bookType: BookType.audiobook,
    accessType: AccessType.premium,
    price: null,
    // Không có giá nếu là subscription
    audioFileUrl: 'http://example.com/audiobooks/muon-kiep.mp3',
    durationMinutes: 700,
    publishedDate: DateTime(2020, 6, 1),
    language: 'Vietnamese',
    createdAt: DateTime.now().subtract(const Duration(days: 800)),
    updatedAt: DateTime.now().subtract(const Duration(days: 40)),
  ),
  Book(
    bookId: _uuid.v4(),
    title: 'Cà Phê Sáng Với Thượng Đế',
    description:
        'Một cuốn sách tâm linh nhẹ nhàng về ý nghĩa cuộc sống và sự kết nối.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1534439121110-123456789020?ixlib=rb-4.0.3&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max',
    bookType: BookType.ebook,
    accessType: AccessType.free,
    fileUrl: 'http://example.com/ebooks/cafe-sang.pdf',
    pages: 150,
    publishedDate: DateTime(2023, 2, 1),
    language: 'Vietnamese',
    createdAt: DateTime.now().subtract(const Duration(days: 100)),
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
];

List<QuoteItem> dummyQuotes = [
  QuoteItem(
    title: "Reading Wisdom",
    quote:
        "The more that you read, the more things you will know. The more that you learn, the more places you'll go.",
    author: "Dr. Seuss",
  ),
  QuoteItem(
    title: "Knowledge is Power",
    quote:
        "Knowledge is power. Information is liberating. Education is the premise of progress, in every society, in every family.",
    author: "Kofi Annan",
  ),
  QuoteItem(
    title: "A Reader Lives",
    quote:
        "A reader lives a thousand lives before he dies... The man who never reads lives only one.",
    author: "George R.R. Martin",
  ),
  QuoteItem(
    title: "Books Are Mirrors",
    quote:
        "Books are mirrors: you only see in them what you already have inside you \n\n\n12321321\n\n\n\ntuh",
    author: "Carlos Ruiz Zafón",
  ),
  QuoteItem(
    title: "Escape Reality",
    quote:
        "That’s the thing about books. They let you travel without moving your feet.",
    author: "Jhumpa Lahiri",
  ),
];

List<Genre> dummyGenres = [
  Genre(
    genreId: 'g001',
    name: 'Tiểu thuyết',
    description: 'Các tác phẩm văn học hư cấu dài.',
  ),
  Genre(
    genreId: 'g002',
    name: 'Khoa học viễn tưởng',
    description: 'Sách về tương lai, công nghệ và khám phá không gian.',
  ),
  Genre(
    genreId: 'g003',
    name: 'Fantasy',
    description: 'Thế giới phép thuật, rồng và những sinh vật huyền bí.',
  ),
  Genre(
    genreId: 'g004',
    name: 'Lịch sử',
    description: 'Nghiên cứu về quá khứ và các sự kiện đã diễn ra.',
  ),
  Genre(
    genreId: 'g005',
    name: 'Hồi ký',
    description: 'Câu chuyện có thật về cuộc đời của tác giả.',
  ),
  Genre(
    genreId: 'g006',
    name: 'Tâm lý học',
    description: 'Sách về các vấn đề tâm lý và hành vi con người.',
  ),
  Genre(
    genreId: 'g007',
    name: 'Kinh tế & Kinh doanh',
    description:
        'Các lý thuyết và ứng dụng trong lĩnh vực kinh tế và kinh doanh.',
  ),
];

List<Review> dummyReviews = [
  Review(
    reviewId: 'r001',
    userId: 'user_A',
    bookId: 'book_xyz',
    // Giả sử đây là ID của một cuốn sách cụ thể
    rating: 5,
    comment: 'Cuốn sách tuyệt vời! Nội dung sâu sắc và rất cuốn hút.',
    createdAt: DateTime(2023, 10, 20, 14, 30),
  ),
  Review(
    reviewId: 'r002',
    userId: 'user_B',
    bookId: 'book_xyz',
    rating: 4,
    comment: 'Cốt truyện hấp dẫn, tuy nhiên đôi chỗ hơi dài dòng.',
    createdAt: DateTime(2023, 11, 01, 9, 00),
  ),
  Review(
    reviewId: 'r003',
    userId: 'user_C',
    bookId: 'book_abc',
    // Một sách khác
    rating: 3,
    comment: 'Tạm ổn, có một số điểm thú vị nhưng không thực sự nổi bật.',
    createdAt: DateTime(2023, 11, 15, 11, 45),
  ),
  Review(
    reviewId: 'r004',
    userId: 'user_D',
    bookId: 'book_xyz',
    rating: 5,
    comment: 'Tôi đã đọc đi đọc lại nhiều lần. Rất đáng tiền!',
    createdAt: DateTime(2023, 12, 05, 18, 10),
  ),
  Review(
    reviewId: 'r005',
    userId: 'user_E',
    bookId: 'book_xyz',
    rating: 2,
    comment: null,
    // Có thể không có bình luận
    createdAt: DateTime(2024, 01, 02, 10, 00),
  ),
  Review(
    reviewId: 'r006',
    userId: 'user_F',
    bookId: 'book_def',
    // Một sách khác
    rating: 4,
    comment: 'Thông tin hữu ích, tôi học được nhiều điều từ cuốn sách này.',
    createdAt: DateTime(2024, 01, 10, 16, 20),
  ),
];

List<Author> dummyAuthors = [
  Author(
    authorId: 'auth001',
    name: 'Nguyễn Nhật Ánh',
    bio: 'Nhà văn chuyên viết cho tuổi học trò với nhiều tác phẩm nổi tiếng như "Mắt biếc", "Tôi thấy hoa vàng trên cỏ xanh".',
    avatarUrl: 'https://example.com/avatars/nna.jpg', // Thay bằng URL ảnh thật nếu có
  ),
  Author(
    authorId: 'auth002',
    name: 'Stephen King',
    bio: 'Bậc thầy của thể loại kinh dị và giả tưởng, với các tác phẩm như "It", "The Shining".',
    avatarUrl: 'https://example.com/avatars/sk.jpg',
  ),
];

List<PremiumPlan> dummyPremiumPlans = [
  PremiumPlan(
    planId: 'premium_monthly_001',
    name: 'Premium Monthly',
    description: 'Truy cập không giới hạn trong 30 ngày.',
    price: 249000,
    durationDays: 30,
    isActive: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  ),
  PremiumPlan(
    planId: 'premium_annual',
    name: 'Premium Annual',
    description: 'Truy cập không giới hạn trong 365 ngày.',
    price: 2499000,
    durationDays: 365,
    isActive: true,
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
    updatedAt: DateTime.now(),
  ),
  PremiumPlan(
    planId: 'basic_monthly',
    name: 'Basic Monthly',
    description: 'Truy cập 5 sách mỗi tháng.',
    price: 99000,
    durationDays: 30,
    isActive: true,
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    updatedAt: DateTime.now(),
  ),
];

List<UserSubscription> dummyUserSubscriptions = [
  // Gói Premium Monthly đang hoạt động
  UserSubscription(
    userSubscriptionId: _uuid.v4(),
    userId: 'user_A123',
    planId: 'premium_monthly', // Tham chiếu đến planId trong dummyPremiumPlans
    startDate: DateTime.now().subtract(const Duration(days: 10)), // Bắt đầu cách đây 10 ngày
    endDate: DateTime.now().add(const Duration(days: 20)), // Kết thúc sau 20 ngày (tổng 30 ngày)
    isActive: true,
    transactionId: _uuid.v4(), // ID giao dịch giả lập
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),

  // Gói Basic Monthly đã hết hạn
  UserSubscription(
    userSubscriptionId: _uuid.v4(),
    userId: 'user_B456',
    planId: 'basic_monthly', // Tham chiếu đến planId trong dummyPremiumPlans
    startDate: DateTime.now().subtract(const Duration(days: 45)), // Bắt đầu cách đây 45 ngày
    endDate: DateTime.now().subtract(const Duration(days: 15)), // Kết thúc cách đây 15 ngày (đã hết hạn)
    isActive: false, // Đánh dấu là không còn hoạt động
    transactionId: _uuid.v4(), // ID giao dịch giả lập
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
    updatedAt: DateTime.now().subtract(const Duration(days: 14)), // Cập nhật lần cuối khi hết hạn
  ),

  // Gói Premium Annual giả lập sắp hết hạn (hoặc vừa mới hết hạn nếu bạn muốn)
  UserSubscription(
    userSubscriptionId: _uuid.v4(),
    userId: 'user_C789',
    planId: 'premium_annual', // Tham chiếu đến planId trong dummyPremiumPlans
    startDate: DateTime.now().subtract(const Duration(days: 360)), // Bắt đầu cách đây 360 ngày
    endDate: DateTime.now().add(const Duration(days: 5)), // Kết thúc sau 5 ngày
    isActive: true,
    transactionId: _uuid.v4(),
    createdAt: DateTime.now().subtract(const Duration(days: 360)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
];

List<User> dummyUsers = [
  User(
    userId: 'user002',
    name: 'Nguyễn Thị Bích',
    phone: null, // Phone can be null
    email: 'bich@example.com',
    passwordHash: 'another_hashed_password_456',
    role: UserRole.reader, // Example: an author user
    token: null, // Token can be null (e.g., if logged out)
    avatarUrl: 'https://cdn.icon-icons.com/icons2/2643/PNG/512/female_person_girl_avatar_icon_159359.png', // A generic female avatar
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
    lastLoginAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  User(
    userId: 'user003',
    name: 'Trần Văn Mạnh',
    phone: '0987654321',
    email: null, // Email can be null
    passwordHash: 'hashed_admin_password_789',
    role: UserRole.admin, // Example: an admin user
    token: 'admin_jwt_token_xyz',
    avatarUrl: 'https://cdn.icon-icons.com/icons2/2643/PNG/512/male_man_person_people_avatar_icon_159363.png',
    createdAt: DateTime.now().subtract(const Duration(days: 500)),
    lastLoginAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
];





