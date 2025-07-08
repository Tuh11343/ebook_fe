import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';

const _defaultControls = [
  MediaControl.rewind,
  MediaControl.pause, // Sẽ được thay đổi thành play tùy trạng thái
  MediaControl.fastForward,
  MediaControl.stop,
];

// Các action mặc định cho hệ thống (Android/iOS)
const _defaultSystemActions = {
  MediaAction.seek,
  MediaAction.seekForward,
  MediaAction.seekBackward,
};

// Mape trạng thái ProcessingState của just_audio sang AudioProcessingState của audio_service
const _processingStateMap = {
  ProcessingState.idle: AudioProcessingState.idle,
  ProcessingState.loading: AudioProcessingState.loading,
  ProcessingState.buffering: AudioProcessingState.buffering,
  ProcessingState.ready: AudioProcessingState.ready,
  ProcessingState.completed: AudioProcessingState.completed,
};

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player =
      AudioPlayer(); // Tạo một instance AudioPlayer duy nhất
  final Dio _dio;

  // Constructor: chỉ nhận Dio để có thể sử dụng lại instance Dio đã có
  // Không nên khởi tạo AudioPlayer và gọi _init() trong constructor này.
  // Quá trình khởi tạo và thiết lập nguồn âm thanh nên được thực hiện sau khi handler được đăng ký.
  AudioPlayerHandler({Dio? dio}) : _dio = dio ?? Dio() {
    _listenToPlaybackEvents(); // Lắng nghe các sự kiện của trình phát
  }

  // Phương thức để truy cập AudioPlayer trực tiếp nếu cần (ví dụ: để thay đổi âm lượng)
  AudioPlayer get audioPlayer => _player;

  // Phương thức khởi tạo handler và thiết lập nguồn âm thanh ban đầu
  // Nên được gọi sau khi handler được đăng ký với AudioService.
  Future<void> initAudio({
    required String audioUrl,
    String? audioTitle,
    String? audioAuthor,
    String? audioImageURL,
    String? audioId, // Thêm audioId để MediaItem có ID duy nhất
  }) async {
    // Đặt thông tin media trước khi tải để hiển thị ngay trên notification
    await _setMediaItem(
      audioId: audioId ?? audioUrl,
      // Sử dụng audioId hoặc audioUrl làm ID mặc định
      audioTitle: audioTitle,
      audioAuthor: audioAuthor,
      audioImageURL: audioImageURL,
      duration: null, // Ban đầu không có thời lượng, sẽ cập nhật sau
    );

    // Xóa tất cả các source cũ trước khi thêm source mới
    // await _player.setAudioSource(null); // Không cần thiết nếu dùng setUrl
    try {
      await _player.setUrl(audioUrl);
    } catch (e) {
      print("Lỗi tải URL âm thanh: $e");
      // hoặc đặt processingState về idle/error
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ));
      return;
    }

    // Cập nhật MediaItem với thời lượng chính xác sau khi tải thành công
    await _setMediaItem(
      audioId: audioId ?? audioUrl,
      audioTitle: audioTitle,
      audioAuthor: audioAuthor,
      audioImageURL: audioImageURL,
      duration: _player.duration,
    );
  }

  // Phương thức để reset nguồn âm thanh (ví dụ: khi người dùng chọn bài khác)
  Future<void> resetAudio({
    required String audioUrl,
    String? audioTitle,
    String? audioAuthor,
    String? audioImageURL,
    String? audioId,
  }) async {
    await _player.stop(); // Dừng phát nhạc hiện tại
    await initAudio(
      // Gọi lại initAudio để thiết lập nguồn mới
      audioUrl: audioUrl,
      audioTitle: audioTitle,
      audioAuthor: audioAuthor,
      audioImageURL: audioImageURL,
      audioId: audioId,
    );
    // Sau khi reset, bạn có thể tự động play hoặc để người dùng nhấn play
    // play(); // Ví dụ: tự động phát sau khi reset
  }

  // Lắng nghe các sự kiện phát lại từ just_audio và cập nhật playbackState của audio_service
  void _listenToPlaybackEvents() {
    _player.playbackEventStream.listen((event) {
      // Cập nhật mediaItem nếu thời lượng đã thay đổi (ví dụ: sau khi tải xong)
      if (mediaItem.value?.duration != _player.duration) {
        _setMediaItem(
          audioId: mediaItem.value?.id ?? 'default_id',
          // Giữ ID hiện tại
          audioTitle: mediaItem.value?.title,
          audioAuthor: mediaItem.value?.album,
          audioImageURL: mediaItem.value?.artUri?.toString(),
          duration: _player.duration,
        );
      }

      // Tạo danh sách controls dựa trên trạng thái _player.playing
      final controls = [
        MediaControl.rewind,
        _player.playing ? MediaControl.pause : MediaControl.play,
        // Thay đổi play/pause
        MediaControl.fastForward,
        MediaControl.stop,
      ];

      playbackState.add(playbackState.value.copyWith(
        controls: controls,
        systemActions: _defaultSystemActions,
        // Sử dụng các action mặc định
        androidCompactActionIndices: const [0, 1, 3],
        // Ví dụ: rewind, play/pause, stop
        processingState: _processingStateMap[_player.processingState]!,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex:
            _player.currentIndex, // Chỉ có ý nghĩa nếu sử dụng QueueHandler
      ));
    });

    // Lắng nghe thay đổi trạng thái _player (playing/paused) để cập nhật playbackState
    _player.playerStateStream.listen((playerState) {
      // Đã được xử lý bởi playbackEventStream, nhưng có thể thêm logic cụ thể ở đây nếu cần.
    });
  }

  // Cập nhật MediaItem trên notification và màn hình khóa
  Future<void> _setMediaItem({
    required String audioId,
    String? audioTitle,
    String? audioAuthor,
    String? audioImageURL,
    Duration? duration,
  }) async {
    Uri? artUri;
    if (audioImageURL != null && audioImageURL.isNotEmpty) {
      bool isImageUrlValid = await _isValidImageUrl(audioImageURL);
      artUri = isImageUrlValid ? Uri.parse(audioImageURL) : null;
    }

    mediaItem.add(MediaItem(
      id: audioId, // ID duy nhất cho mỗi bài hát
      album: audioAuthor ?? 'Unknown Album',
      title: audioTitle ?? 'Unknown Title',
      duration: duration, // Thời lượng hiện tại của bài hát
      // Thêm các thông tin khác nếu có: artist, genre, etc.
    ));
  }

  // Kiểm tra tính hợp lệ của URL ảnh bằng cách gửi HEAD request
  // Sử dụng instance Dio đã được inject
  Future<bool> _isValidImageUrl(String imageUrl) async {
    try {
      final response = await _dio.head(imageUrl);
      return response.statusCode == 200;
    } on DioError catch (e) {
      // Bắt DioException thay vì Exception chung chung
      print("Lỗi kiểm tra URL ảnh: $e");
      return false;
    } catch (e) {
      print("Lỗi không xác định khi kiểm tra URL ảnh: $e");
      return false;
    }
  }

  @override
  Future<void> play() async {
    // Đảm bảo MediaItem đã được đặt trước khi play
    if (mediaItem.value == null) {
      print("Chưa có MediaItem, không thể play.");
      return;
    }
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> fastForward() =>
      _player.seek(Duration(seconds: _player.position.inSeconds + 10));

  @override
  Future<void> rewind() =>
      _player.seek(Duration(seconds: _player.position.inSeconds - 10));

  @override
  Future<void> stop() async {
    await _player.stop();
    // Đặt lại trạng thái khi dừng hoàn toàn
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
      updatePosition: Duration.zero,
    ));
    await super.stop();
  }

  // Đảm bảo dispose player khi handler không còn được sử dụng
  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose(); // Quan trọng: giải phóng tài nguyên player
    super.onTaskRemoved();
  }

// Nếu muốn hỗ trợ skipToNext/skipToPrevious
// @override
// Future<void> skipToNext() async { /* Logic để chuyển bài tiếp theo */ }
// @override
// Future<void> skipToPrevious() async { /* Logic để chuyển bài trước đó */ }
}
