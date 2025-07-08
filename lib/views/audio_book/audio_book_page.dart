import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import '../../constants/app_font_size.dart';
import '../../models/book.dart';
import 'audio_cubit.dart';
import '../../widgets/circular_icon_button.dart';
import '../main_wrapper/main_wrapper_cubit.dart';
import 'audio_handler.dart';
import 'audio_state.dart';

class AudioBookPage extends StatefulWidget {
  final Book book;
  final String? authorName;

  const AudioBookPage({super.key, required this.book, this.authorName});

  @override
  State<AudioBookPage> createState() => _AudioBookPageState();
}

class _AudioBookPageState extends State<AudioBookPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  double? _dragValue;
  bool _isDragging = false;
  bool _wasPlayingBeforeDrag = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _handlePlayPause(bool isPlaying, BuildContext context) {
    HapticFeedback.lightImpact();

    if (isPlaying) {
      context.read<AudioCubit>().pause();
      _rotationController.stop();
    } else {
      context.read<AudioCubit>().play();
      _rotationController.repeat();
    }
  }

  void _handleSliderChange(double value, bool isLoading, BuildContext context) {
    if (isLoading) return;

    setState(() {
      _dragValue = value;
      _isDragging = true;
    });
  }

  void _handleSliderChangeStart(double value, bool isLoading, bool isPlaying, BuildContext context) {
    if (isLoading) return;

    _wasPlayingBeforeDrag = isPlaying;
    if (isPlaying) {
      context.read<AudioCubit>().pause();
      _rotationController.stop();
    }
  }

  void _handleSliderChangeEnd(double value, bool isLoading, Duration? totalDuration, BuildContext context) {
    if (isLoading || totalDuration == null) return;

    setState(() {
      _isDragging = false;
    });

    final newPosition = Duration(
      milliseconds: (totalDuration.inMilliseconds * value).toInt(),
    );

    context.read<AudioCubit>().seek(newPosition);

    if (_wasPlayingBeforeDrag) {
      context.read<AudioCubit>().play();
      _rotationController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        context.read<MainWrapperCubit>().setBottomNavigationVisibility(true);
        context.read<MainWrapperCubit>().setSongControlVisibility(true);
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
                Color(0xFFf093fb),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<AudioCubit, AudioState>(
              builder: (context, state) {
                return _buildContent(context, state);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AudioState state) {
    final isPlaying = state.status == AudioStatus.playing;
    final isLoading = state.status == AudioStatus.loading ||
        state.status == AudioStatus.initial;
    final audioPlayerHandler = state.audioPlayerHandler;

    if (state.status == AudioStatus.error && state.errorMessage != null) {
      return _buildErrorWidget(context, state.errorMessage!);
    }

    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildVinylRecord(isPlaying),
                const SizedBox(height: 40),
                _buildBookInfo(),
                const SizedBox(height: 30),
                if (audioPlayerHandler != null)
                  _buildAudioControls(context, audioPlayerHandler, isLoading, isPlaying)
                else if (isLoading)
                  _buildLoadingIndicator(),
                const SizedBox(height: 30),
                _buildFeatureButtons(context, audioPlayerHandler),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AudioCubit>().initOrResetAudio(
                  book: widget.book,
                  authorName: widget.authorName,
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF667eea),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircularIconButton(
            icon: Icons.keyboard_arrow_down,
            onPressed: () {
              context.read<MainWrapperCubit>().setSongControlVisibility(true);
              context.read<MainWrapperCubit>().setBottomNavigationVisibility(true);
              Navigator.pop(context);
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Text(
              'Mua ngay',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          CircularIconButton(
            icon: Icons.more_vert,
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVinylRecord(bool isPlaying) {
    return Hero(
      tag: 'book_cover_${widget.book.bookId}',
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: isPlaying ? _rotationController.value * 2 * math.pi : 0,
            child: child,
          );
        },
        child: Container(
          height: 280,
          width: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vinyl background
              Container(
                height: 280,
                width: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black87,
                  border: Border.all(color: Colors.grey.shade800, width: 2),
                ),
              ),
              // Album cover
              Container(
                height: 200,
                width: 200,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: CachedNetworkImage(
                  imageUrl: widget.book.coverImageUrl ??
                      "https://via.placeholder.com/300x400.png?text=No+Image",
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.music_note, size: 40, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              // Center dot
              Container(
                height: 20,
                width: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            widget.book.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppFontSize.large,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.authorName ?? 'Tác giả không xác định',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFontSize.normal,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(Icons.headphones, '${widget.book.durationMinutes ?? 0} phút'),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.language, widget.book.language),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioControls(BuildContext context, AudioPlayerHandler audioPlayerHandler,
      bool isLoading, bool isPlaying) {
    return StreamBuilder<Duration>(
      stream: audioPlayerHandler.audioPlayer.positionStream,
      builder: (context, snapshot) {
        final currentPosition = snapshot.data ?? Duration.zero;
        final totalDuration = audioPlayerHandler.audioPlayer.duration;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(context, currentPosition, totalDuration, isLoading),
              const SizedBox(height: 30),
              // Control buttons
              _buildControlButtons(context, isLoading, isPlaying),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(BuildContext context, Duration currentPosition,
      Duration? totalDuration, bool isLoading) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(currentPosition),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              _formatDuration(totalDuration),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
          ),
          child: Slider(
            value: _isDragging
                ? _dragValue!
                : (totalDuration?.inMilliseconds != null && totalDuration!.inMilliseconds > 0
                ? currentPosition.inMilliseconds.toDouble() / totalDuration.inMilliseconds.toDouble()
                : 0),
            onChanged: (value) => _handleSliderChange(value, isLoading, context),
            onChangeStart: (value) => _handleSliderChangeStart(value, isLoading,
                context.read<AudioCubit>().state.status == AudioStatus.playing, context),
            onChangeEnd: (value) => _handleSliderChangeEnd(value, isLoading, totalDuration, context),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(BuildContext context, bool isLoading, bool isPlaying) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.replay_10,
          onPressed: isLoading ? null : () => context.read<AudioCubit>().rewind(),
          size: 32,
        ),
        _buildControlButton(
          icon: Icons.skip_previous,
          onPressed: isLoading ? null : () {
            // Handle previous track
          },
          size: 36,
        ),
        _buildMainPlayButton(context, isLoading, isPlaying),
        _buildControlButton(
          icon: Icons.skip_next,
          onPressed: isLoading ? null : () {
            // Handle next track
          },
          size: 36,
        ),
        _buildControlButton(
          icon: Icons.forward_10,
          onPressed: isLoading ? null : () => context.read<AudioCubit>().fastForward(),
          size: 32,
        ),
      ],
    );
  }

  Widget _buildMainPlayButton(BuildContext context, bool isLoading, bool isPlaying) {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: isLoading ? null : () => _handlePlayPause(isPlaying, context),
          child: Icon(
            isLoading
                ? Icons.hourglass_empty
                : (isPlaying ? Icons.pause : Icons.play_arrow),
            size: 40,
            color: const Color(0xFF667eea),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required double size,
  }) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onPressed,
          child: Icon(
            icon,
            size: size,
            color: onPressed != null ? Colors.white : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildFeatureButtons(BuildContext context, AudioPlayerHandler? audioPlayerHandler) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFeatureButton(
            icon: Icons.bookmark_add_outlined,
            label: 'Đánh dấu',
            onPressed: () {
              // Handle bookmark
            },
          ),
          _buildFeatureButton(
            icon: Icons.format_list_bulleted,
            label: 'Chương',
            onPressed: () {
              // Handle chapters
            },
          ),
          if (audioPlayerHandler != null)
            StreamBuilder<double>(
              stream: audioPlayerHandler.audioPlayer.speedStream,
              initialData: 1.0,
              builder: (context, snapshot) {
                final currentSpeed = snapshot.data ?? 1.0;
                return _buildFeatureButton(
                  icon: Icons.speed,
                  label: '${currentSpeed.toStringAsFixed(1)}x',
                  onPressed: () => _showSpeedSelectionSheet(context, audioPlayerHandler),
                );
              },
            )
          else
            _buildFeatureButton(
              icon: Icons.speed,
              label: '1.0x',
              onPressed: null,
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: onPressed != null ? Colors.white : Colors.white.withOpacity(0.5),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: onPressed != null ? Colors.white : Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSpeedSelectionSheet(BuildContext context, AudioPlayerHandler audioPlayerHandler) {
    double currentSelectedSpeed = audioPlayerHandler.audioPlayer.speed;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tốc độ phát',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${currentSelectedSpeed.toStringAsFixed(1)}x',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    ),
                    child: Slider(
                      value: currentSelectedSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      label: '${currentSelectedSpeed.toStringAsFixed(1)}x',
                      onChanged: (double newValue) {
                        setState(() {
                          currentSelectedSpeed = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        audioPlayerHandler.audioPlayer.setSpeed(currentSelectedSpeed);
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Áp dụng',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}