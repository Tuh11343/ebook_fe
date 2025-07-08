import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../constants/trivela_stuff.dart';
import '../models/book.dart';
import '../views/audio_book/audio_cubit.dart';
import '../views/audio_book/audio_state.dart';
import '../views/main_wrapper/main_wrapper_cubit.dart';

class SongControl extends StatelessWidget {
  const SongControl({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCubit, AudioState>(
      buildWhen: (previous, current) {
        // Chỉ rebuild khi các thuộc tính quan trọng thay đổi
        return previous.currentAudioBook != current.currentAudioBook ||
            previous.audioPlayerHandler != current.audioPlayerHandler ||
            previous.status != current.status;
      },
      builder: (context, state) {
        // Early return nếu không có dữ liệu cần thiết
        if (state.currentAudioBook == null ||
            state.audioPlayerHandler == null) {
          return const SizedBox.shrink();
        }

        return _SongControlCard(
          audioBook: state.currentAudioBook!,
          audioPlayerHandler: state.audioPlayerHandler!,
          isLoading: _isLoadingState(state.status),
          onTap: () => _navigateToAudioBook(
              context, state.currentAudioBook!, state.authorName),
          onSwipeDown: () => _handleSwipeDown(context),
        );
      },
    );
  }

  bool _isLoadingState(AudioStatus status) {
    return status == AudioStatus.loading || status == AudioStatus.initial;
  }

  void _navigateToAudioBook(
      BuildContext context, Book audioBook, String? authorName) {
    final mainWrapperCubit = context.read<MainWrapperCubit>();
    mainWrapperCubit.setSongControlVisibility(false);
    mainWrapperCubit.setBottomNavigationVisibility(false);
    context.pushNamed('audioBook', extra: {
      'book': audioBook, // Gửi đối tượng Book
      'authorName': authorName ?? "Không rõ",
    });
  }

  void _handleSwipeDown(BuildContext context) {
    debugPrint('Swipe down: Hiding SongControl and stopping audio.');
    final mainWrapperCubit = context.read<MainWrapperCubit>();
    mainWrapperCubit.setSongControlVisibility(false);
    mainWrapperCubit.setBottomNavigationVisibility(true);
    context.read<AudioCubit>().stop();
  }
}

class _SongControlCard extends StatelessWidget {
  final Book audioBook;
  final dynamic audioPlayerHandler;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onSwipeDown;

  const _SongControlCard({
    required this.audioBook,
    required this.audioPlayerHandler,
    required this.isLoading,
    required this.onTap,
    required this.onSwipeDown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getScreenWidth(),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _buildCardDecoration(),
      child: SwipeDetector(
        // <-- SwipeDetector ở đây
        onSwipeDown: (_) => onSwipeDown(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            // <-- InkWell ở đây
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  _buildAlbumArt(),
                  const SizedBox(width: 15),
                  _buildSongInfo(),
                  const SizedBox(width: 15),
                  _buildPlayButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildAlbumArt() {
    return Hero(
      tag: 'album-art-${audioBook.hashCode}', // Thêm Hero animation
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: audioBook.coverImageUrl ?? '',
          fit: BoxFit.cover,
          height: 55,
          width: 55,
          placeholder: (context, url) => _buildImagePlaceholder(),
          errorWidget: (context, url, error) => _buildImageError(),
          memCacheHeight: 110,
          // Tối ưu memory cache
          memCacheWidth: 110,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.music_note_rounded,
        color: Colors.grey,
        size: 24,
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.broken_image_rounded,
        color: Colors.grey,
        size: 24,
      ),
    );
  }

  Widget _buildSongInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            audioBook.title ?? 'Tiêu đề không rõ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return StreamBuilder<PlayerState>(
      stream: audioPlayerHandler.audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingButton();
        }

        final playerState = snapshot.data!;
        final processingState = playerState.processingState;
        final playing = playerState.playing;

        if (isLoading ||
            processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return _buildLoadingButton();
        }

        return _buildControlButton(
          playing: playing,
          completed: processingState == ProcessingState.completed,
          context: context,
        );
      },
    );
  }

  Widget _buildLoadingButton() {
    return const SizedBox(
      width: 45,
      height: 45,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildControlButton({
    required bool playing,
    required bool completed,
    required BuildContext context,
  }) {
    IconData iconData;
    VoidCallback onPressed;

    if (completed) {
      iconData = Icons.replay_circle_filled;
      onPressed = () => context.read<AudioCubit>().seek(Duration.zero);
    } else if (playing) {
      iconData = Icons.pause_circle_filled;
      onPressed = () => context.read<AudioCubit>().pause();
    } else {
      iconData = Icons.play_circle_filled;
      onPressed = () => context.read<AudioCubit>().play();
    }

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        iconData,
        size: 45,
        color: Colors.blue,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 45,
        minHeight: 45,
      ),
      splashRadius: 25, // Giới hạn splash effect
    );
  }
}

// Extension để tối ưu hóa performance
extension AudioBookExtension on dynamic {
  String? get safeTitle => this?.title?.toString();

  String? get safeCoverImageUrl => this?.coverImageUrl?.toString();

  String? get safeAuthor => this?.author?.toString();
}
