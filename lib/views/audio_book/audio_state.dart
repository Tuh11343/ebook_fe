


import 'package:equatable/equatable.dart';

import '../../models/book.dart';
import 'audio_handler.dart';

enum AudioStatus {
  initial, // Trạng thái ban đầu
  loading, // Đang tải/khởi tạo âm thanh
  ready,   // Sẵn sàng phát
  playing, // Đang phát
  paused,  // Đã tạm dừng
  stopped, // Đã dừng hoàn toàn
  error,   // Có lỗi xảy ra
}


class AudioState extends Equatable {
  final AudioStatus status;
  final Book? currentAudioBook;
  final String authorName;
  final AudioPlayerHandler? audioPlayerHandler;
  final String? errorMessage; // Để lưu thông báo lỗi nếu có

  const AudioState({
    this.status = AudioStatus.initial,
    this.currentAudioBook,
    this.authorName = '',
    this.audioPlayerHandler,
    this.errorMessage,
  });

  AudioState copyWith({
    AudioStatus? status,
    Book? currentAudioBook,
    String? authorName,
    AudioPlayerHandler? audioPlayerHandler,
    String? errorMessage,
  }) {
    return AudioState(
      status: status ?? this.status,
      currentAudioBook: currentAudioBook ?? this.currentAudioBook,
      authorName: authorName ?? this.authorName,
      audioPlayerHandler: audioPlayerHandler ?? this.audioPlayerHandler,
      errorMessage: errorMessage, // Luôn cập nhật errorMessage nếu được truyền vào
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentAudioBook,
    authorName,
    audioPlayerHandler, // Cẩn thận với việc so sánh handler, có thể không cần thiết nếu nó không thay đổi instance.
    errorMessage,
  ];
}