import 'dart:async'; // Import này là cần thiết cho StreamSubscription
import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/book.dart';
import 'audio_handler.dart';
import 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  final Dio _dio;
  StreamSubscription<PlaybackState>? _playbackStateSubscription; // <-- THÊM DÒNG NÀY

  AudioCubit({Dio? dio}) : _dio = dio ?? Dio(), super(const AudioState());

  Future<void> initOrResetAudio({required Book book, String? authorName}) async {
    if (isClosed) {
      print('AudioCubit is closed. Cannot init or reset audio.');
      return;
    }

    if (state.status == AudioStatus.loading) return;

    emit(state.copyWith(
      status: AudioStatus.loading,
      currentAudioBook: book,
      authorName: authorName ?? 'Không rõ',
      errorMessage: null,
    ));

    try {
      AudioPlayerHandler handler;
      if (state.audioPlayerHandler == null) {
        handler = await AudioService.init(
          builder: () => AudioPlayerHandler(dio: _dio),
          config: const AudioServiceConfig(
            androidNotificationChannelId: 'com.example.app.ebook.audio',
            androidNotificationChannelName: 'Audio Playback',
            androidNotificationOngoing: true,
          ),
        );
        emit(state.copyWith(audioPlayerHandler: handler));
        _listenToHandlerPlaybackState(handler); // Bắt đầu lắng nghe
      } else {
        handler = state.audioPlayerHandler!;
      }

      String? audioUrl = book.audioFileUrl;
      if (audioUrl == null || audioUrl.isEmpty) {
        throw Exception('Audio file URL is missing for this book.');
      }

      if (handler.audioPlayer.playing) {
        await handler.resetAudio(
          audioId: book.bookId,
          audioUrl: audioUrl,
          audioTitle: book.title,
          audioAuthor: authorName ?? book.description,
          audioImageURL: book.coverImageUrl,
        );
      } else {
        await handler.initAudio(
          audioId: book.bookId,
          audioUrl: audioUrl,
          audioTitle: book.title,
          audioAuthor: authorName ?? book.description,
          audioImageURL: book.coverImageUrl,
        );
      }

      if (isClosed) {
        print('AudioCubit closed during init/reset. Aborting state update.');
        return;
      }
      emit(state.copyWith(status: AudioStatus.ready));
      handler.play();

    } catch (e) {
      print("Lỗi khởi tạo/reset Audio: $e");
      if (isClosed) {
        print('AudioCubit closed during error handling. Aborting error state update.');
        return;
      }
      emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _listenToHandlerPlaybackState(AudioPlayerHandler handler) {
    // Hủy đăng ký subscription cũ nếu có trước khi tạo cái mới
    _playbackStateSubscription?.cancel();

    _playbackStateSubscription = handler.playbackState.listen((playbackState) {
      // LUÔN LUÔN KIỂM TRA isClosed TRƯỚC KHI EMIT TRONG LISTENERS
      if (isClosed) {
        print('AudioCubit is closed. Cannot emit from playbackState listener.');
        _playbackStateSubscription?.cancel(); // Hủy subscription ngay lập tức
        return;
      }

      AudioStatus newStatus;
      switch (playbackState.processingState) {
        case AudioProcessingState.idle:
          newStatus = AudioStatus.stopped;
          break;
        case AudioProcessingState.loading:
        case AudioProcessingState.buffering:
          newStatus = AudioStatus.loading;
          break;
        case AudioProcessingState.ready:
          newStatus = playbackState.playing ? AudioStatus.playing : AudioStatus.paused;
          break;
        case AudioProcessingState.completed:
          newStatus = AudioStatus.stopped;
          break;
        case AudioProcessingState.error:
          newStatus = AudioStatus.error;
          break;
      }

      if (newStatus != state.status) {
        emit(state.copyWith(status: newStatus));
      }
    });
  }

  // Các phương thức điều khiển phát nhạc
  void play() {
    if (isClosed) return; // Kiểm tra an toàn
    state.audioPlayerHandler?.play();
  }

  void pause() {
    if (isClosed) return; // Kiểm tra an toàn
    state.audioPlayerHandler?.pause();
  }

  void stop() {
    if (isClosed) return; // Kiểm tra an toàn
    state.audioPlayerHandler?.stop();
  }

  void seek(Duration position) {
    if (isClosed) return; // Kiểm tra an toàn
    state.audioPlayerHandler?.seek(position);
  }

  void fastForward() {
    if (isClosed) return; // Kiểm tra an toàn
    state.audioPlayerHandler?.fastForward();
  }

  void rewind() {
    if (isClosed) return; // Kiểm tra an toàn
    state.audioPlayerHandler?.rewind();
  }

  @override
  Future<void> close() async {
    // Hủy đăng ký stream subscription khi Cubit bị đóng
    await _playbackStateSubscription?.cancel();

    // stop() handler nếu nó tồn tại và đang chạy
    // Tuy nhiên, việc dispose AudioPlayerHandler thường được quản lý bởi AudioService
    // hoặc trong `onTaskRemoved` của chính `AudioPlayerHandler` để đảm bảo nhạc dừng khi app bị đóng hoàn toàn
    // Nếu bạn gọi handler.stop() ở đây, nó sẽ dừng nhạc ngay khi Cubit bị đóng (ví dụ: khi rời màn hình)
    // Việc này tùy thuộc vào logic ứng dụng của bạn: bạn muốn nhạc dừng hay tiếp tục chạy nền?
    // Nếu bạn muốn nhạc tiếp tục chạy nền: không gọi stop/dispose handler ở đây.
    // Nếu bạn muốn nhạc dừng khi rời màn hình: hãy gọi stop().
    if (state.audioPlayerHandler != null) {
      await state.audioPlayerHandler!.stop(); // Ví dụ: dừng nhạc khi Cubit bị đóng
      // Không gọi handler.dispose() ở đây nếu AudioService đang quản lý lifecycle của nó
    }

    return super.close();
  }
}