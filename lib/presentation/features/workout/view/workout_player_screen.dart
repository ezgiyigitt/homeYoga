import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../viewmodel/workout_viewmodel.dart';
import '../../../shared/widgets/hy_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../app/navigation/route_names.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../domain/entities/exercise_entity.dart';
import '../../../../domain/entities/workout_entity.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../home/viewmodel/home_viewmodel.dart';
import '../widgets/pro_voiceover_sheet.dart';
import '../widgets/rotate_phone_prompt_view.dart';

class WorkoutPlayerScreen extends ConsumerStatefulWidget {
  final String? workoutId;
  final WorkoutEntity? customWorkout;
  const WorkoutPlayerScreen({super.key, this.workoutId, this.customWorkout});

  @override
  ConsumerState<WorkoutPlayerScreen> createState() =>
      _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends ConsumerState<WorkoutPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  AudioPlayer? _audioPlayer;
  AudioPlayer? _bgmPlayer;
  bool _isVoiceoverEnabled = false;
  bool _hasPromptedVoiceoverLanguage = false;
  bool _dismissedRotatePrompt = false;
  bool _isManualLandscape = false;
  bool _isBgmEnabled = true; // Gentle ambient background music
  static const String _defaultBgmUrl =
      'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/yoga_ambient_bgm.mp3';
  static const double _bgmVolume = 0.18; // Soft, peaceful ambient level
  String? _currentPlayingAudioUrl;
  int _lastExerciseIndex = -1;

  List<String> _currentVideoPlaylist = [];
  int _currentVideoPartIndex = 0;
  bool _isSwitchingVideoPart = false;

  @override
  void initState() {
    super.initState();
    // Allow both landscape directions (left and right) during workout
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final isPro = ref.read(localStorageProvider).isPro;
    final lang = ref.read(appLanguageProvider);
    final isNonEnglish = lang != AppLanguage.english;
    // İngilizce dışındaki dillerde kullanıcıya sormadan sesi arka planda otomatik açma
    _isVoiceoverEnabled = isPro && !isNonEnglish;
    _audioPlayer = AudioPlayer();
    _initBgm();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.customWorkout != null) {
        ref
            .read(workoutViewModelProvider.notifier)
            .setCustomWorkout(widget.customWorkout!);
      } else if (widget.workoutId != null && widget.workoutId!.isNotEmpty) {
        ref
            .read(workoutViewModelProvider.notifier)
            .loadWorkoutById(widget.workoutId!);
      } else {
        final userId = ref.read(localStorageProvider).userId ?? 'local';
        ref.read(workoutViewModelProvider.notifier).loadWorkout(userId);
      }
    });
  }

  @override
  void dispose() {
    // Re-lock to portrait when leaving the workout screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _disposeVideo();
    _disposeAudio();
    _disposeBgm();
    super.dispose();
  }

  void _initBgm() async {
    try {
      _bgmPlayer ??= AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.setVolume(_bgmVolume);
      if (_isBgmEnabled) {
        await _bgmPlayer!.play(UrlSource(_defaultBgmUrl));
        debugPrint('Yoga ambient BGM playing');
      }
    } catch (e) {
      debugPrint('Error playing ambient BGM: $e');
    }
  }

  Future<void> _toggleBgm() async {
    setState(() {
      _isBgmEnabled = !_isBgmEnabled;
    });

    if (_isBgmEnabled) {
      if (_bgmPlayer?.state == PlayerState.paused) {
        await _bgmPlayer?.resume();
      } else {
        await _bgmPlayer?.play(UrlSource(_defaultBgmUrl));
      }
    } else {
      await _bgmPlayer?.pause();
    }
  }

  void _disposeBgm() {
    _bgmPlayer?.stop();
    _bgmPlayer?.dispose();
    _bgmPlayer = null;
  }

  void _disposeVideo() {
    _videoPlayerController?.removeListener(_onVideoTick);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;
  }

  void _disposeAudio() {
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _currentPlayingAudioUrl = null;
  }

  void _initAudio(String? url) async {
    if (url == null || url.isEmpty || !_isVoiceoverEnabled) {
      _currentPlayingAudioUrl = null;
      await _audioPlayer?.stop();
      return;
    }

    if (_currentPlayingAudioUrl == url &&
        _audioPlayer?.state == PlayerState.playing) {
      return;
    }

    _currentPlayingAudioUrl = url;
    try {
      _audioPlayer ??= AudioPlayer();
      await _audioPlayer!.stop();
      await _audioPlayer!.setVolume(1.0);
      await _audioPlayer!.play(UrlSource(url));
      debugPrint('Voiceover playing: $url');
    } catch (e) {
      debugPrint('Error playing voiceover: $e');
    }
  }

  Future<void> _handleVoiceoverTap(String? currentAudioUrl, bool isPro) async {
    if (!isPro) {
      final purchased = await ProVoiceoverSheet.show(context);
      if (!mounted) return;
      if (purchased == true) {
        if (!_hasPromptedVoiceoverLanguage &&
            _shouldPromptEnglishVoiceover(context)) {
          _hasPromptedVoiceoverLanguage = true;
          final wantAudio = await _showVoiceoverLanguageDialog(context);
          if (!mounted) return;
          if (!wantAudio) {
            setState(() {
              _isVoiceoverEnabled = false;
            });
            return;
          }
        }
        setState(() {
          _isVoiceoverEnabled = true;
        });
        _videoPlayerController?.setVolume(0.0);
        if (currentAudioUrl != null) {
          _initAudio(currentAudioUrl);
        }
      }
      return;
    }

    _toggleVoiceover(currentAudioUrl);
  }

  Future<void> _toggleVoiceover(String? currentAudioUrl) async {
    if (!_isVoiceoverEnabled) {
      // Seslendirmeyi açarken İngilizce uyarısını göster
      if (!_hasPromptedVoiceoverLanguage &&
          _shouldPromptEnglishVoiceover(context)) {
        _hasPromptedVoiceoverLanguage = true;
        final wantAudio = await _showVoiceoverLanguageDialog(context);
        if (!mounted) return;
        if (!wantAudio) {
          return;
        }
      }

      setState(() {
        _isVoiceoverEnabled = true;
      });

      // Videos are ALWAYS completely muted as requested
      _videoPlayerController?.setVolume(0.0);

      if (currentAudioUrl != null) {
        _initAudio(currentAudioUrl);
      }
    } else {
      setState(() {
        _isVoiceoverEnabled = false;
      });
      _currentPlayingAudioUrl = null;
      await _audioPlayer?.stop();
    }
  }

  void _syncVideoPlaylist(List<String> urls) {
    final playlist = urls.isEmpty
        ? [
            'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
          ]
        : urls;

    // Check if playlist has changed
    final isSamePlaylist = _currentVideoPlaylist.length == playlist.length &&
        _currentVideoPlaylist
            .asMap()
            .entries
            .every((e) => e.value == playlist[e.key]);

    if (isSamePlaylist && _videoPlayerController != null) {
      return;
    }

    _currentVideoPlaylist = List.from(playlist);
    _currentVideoPartIndex = 0;
    _playVideoPart(0);
  }

  Future<void> _playVideoPart(int index) async {
    if (_currentVideoPlaylist.isEmpty) return;
    _currentVideoPartIndex = index % _currentVideoPlaylist.length;
    final videoUrl = _currentVideoPlaylist[_currentVideoPartIndex];

    _disposeVideo();

    if (videoUrl.startsWith('assets/')) {
      _videoPlayerController = VideoPlayerController.asset(videoUrl);
    } else {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    }

    try {
      await _videoPlayerController!.initialize();
      // Completely mute the video sound
      await _videoPlayerController!.setVolume(0.0);

      _videoPlayerController!.addListener(_onVideoTick);

      final hasMultipleParts = _currentVideoPlaylist.length > 1;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping:
            !hasMultipleParts, // Only loop internally if there is a single clip
        showControls: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
      );

      await _videoPlayerController!.play();

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error initializing video part: $e');
    }
  }

  void _onVideoTick() {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return;
    }

    // Enforce 0.0 volume on video at all times
    if (_videoPlayerController!.value.volume != 0.0) {
      _videoPlayerController!.setVolume(0.0);
    }

    if (_currentVideoPlaylist.length <= 1) return;
    if (_isSwitchingVideoPart) return;

    final val = _videoPlayerController!.value;
    final pos = val.position;
    final dur = val.duration;

    // Switch to next part (e.g. from Left to Right) when clip completes
    if (dur > Duration.zero &&
        (pos >= dur - const Duration(milliseconds: 300) || val.isCompleted)) {
      _isSwitchingVideoPart = true;
      final nextIndex =
          (_currentVideoPartIndex + 1) % _currentVideoPlaylist.length;
      debugPrint('Video part ended, auto-advancing to part $nextIndex');
      _playVideoPart(nextIndex).then((_) {
        _isSwitchingVideoPart = false;
      });
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _toggleLandscape(bool toLandscape) {
    if (toLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      setState(() {
        _isManualLandscape = true;
      });
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      setState(() {
        _isManualLandscape = false;
      });
      // Allow physical rotation again once phone is settled in portrait
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && !_isManualLandscape) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutViewModelProvider);
    final vm = ref.read(workoutViewModelProvider.notifier);
    final isPro = ref.watch(localStorageProvider).isPro;

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.systemBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == WorkoutStatus.finished) {
      if (_isManualLandscape) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isManualLandscape) {
            setState(() {
              _isManualLandscape = false;
            });
          }
        });
      }
      return _buildFinishedScreen(context);
    }

    final ex = state.currentExercise?.exercise;
    if (ex == null) return const SizedBox();

    final isRest = state.status == WorkoutStatus.resting;

    // Determine the video(s) to play: current exercise or next exercise (if resting)
    final nextIndex = (state.currentExerciseIndex + 1)
        .clamp(0, (state.workout?.exercises.length ?? 1) - 1);
    final nextEx = state.workout?.exercises[nextIndex].exercise;

    final targetVideoUrls = isRest ? (nextEx?.videoUrls ?? []) : ex.videoUrls;

    // Listen to workout status to keep audio & video playback in sync
    ref.listen(workoutViewModelProvider, (previous, next) {
      if (next.status == WorkoutStatus.paused) {
        _videoPlayerController?.pause();
        _audioPlayer?.pause();
        _bgmPlayer?.pause();
      } else if (next.status == WorkoutStatus.playing &&
          (previous?.status == WorkoutStatus.paused ||
           previous?.status == WorkoutStatus.notStarted)) {
        _videoPlayerController?.play();
        _videoPlayerController?.setVolume(0.0);
        if (_isVoiceoverEnabled) {
          if (_audioPlayer?.state == PlayerState.paused) {
            _audioPlayer?.resume();
          } else if (ex.audioUrl != null && !isRest) {
            _initAudio(ex.audioUrl);
          }
        }
        if (_isBgmEnabled) {
          if (_bgmPlayer?.state == PlayerState.paused) {
            _bgmPlayer?.resume();
          } else {
            _initBgm();
          }
        }
      } else if (next.status == WorkoutStatus.finished) {
        _bgmPlayer?.stop();
        _audioPlayer?.stop();
        // Immediately lock orientation back to portrait when workout finishes
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        if (_isManualLandscape) {
          setState(() {
            _isManualLandscape = false;
          });
        }
      }
    });

    // Synchronize video playlist playback immediately so video is ready and playing
    if (targetVideoUrls.isNotEmpty && !state.isLoading) {
      _syncVideoPlaylist(targetVideoUrls);
    }

    // Synchronize voiceover audio per exercise
    if (state.status == WorkoutStatus.playing && !isRest) {
      if (_lastExerciseIndex != state.currentExerciseIndex) {
        _lastExerciseIndex = state.currentExerciseIndex;
        if (_isVoiceoverEnabled && ex.audioUrl != null) {
          _initAudio(ex.audioUrl);
        } else {
          _audioPlayer?.stop();
        }
      }
    } else if (isRest) {
      _lastExerciseIndex = -1;
      _audioPlayer?.stop();
    }

    final size = MediaQuery.of(context).size;
    final isPhysicalLandscape = size.width > size.height;
    final isLandscape = _isManualLandscape || isPhysicalLandscape;

    // Auto-start workout immediately when in landscape or after prompt is dismissed
    if ((isLandscape || _dismissedRotatePrompt) &&
        state.status == WorkoutStatus.notStarted &&
        !state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && state.status == WorkoutStatus.notStarted) {
          vm.start();
          _videoPlayerController?.play();
        }
      });
    }

    // ── 1. Dikey modda Rotate Your Phone Animasyonu ────────────
    if (!isLandscape && !_dismissedRotatePrompt) {
      return RotatePhonePromptView(
        onContinuePortrait: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          setState(() {
            _dismissedRotatePrompt = true;
            _isManualLandscape = false;
          });
          vm.start();
          _videoPlayerController?.play();
        },
        onSwitchToLandscape: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          setState(() {
            _isManualLandscape = true;
            _dismissedRotatePrompt = true;
          });
          vm.start();
          _videoPlayerController?.play();
        },
        onClose: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.home);
          }
        },
      );
    }

    // ── 2. Yatay modda Sinematik Tam Ekran Oynatıcı (Sadece Dersler) ──
    if (isLandscape) {
      return _buildLandscapePlayer(
        context: context,
        state: state,
        vm: vm,
        ex: ex,
        isRest: isRest,
        isPro: isPro,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.systemBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            vm.pause();
            _showQuitDialog(context);
          },
        ),
        title: isRest
            ? Text('Rest', style: AppTypography.subheadlineSemibold)
            : _EpisodeCounterBadge(
                current: state.currentExerciseIndex + 1,
                total: state.workout?.exerciseCount ?? 0,
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.screen_rotation_rounded),
            tooltip: 'Yatay / Tam Ekran',
            onPressed: () => _toggleLandscape(true),
          ),
          _BgmActionButton(
            isEnabled: _isBgmEnabled,
            isCompact: true,
            onTap: _toggleBgm,
          ),
          const SizedBox(width: AppSpacing.xs),
          _VoiceoverActionButton(
            isEnabled: _isVoiceoverEnabled,
            hasAudio: ex.audioUrl != null && !isRest,
            isPro: isPro,
            isCompact: true,
            onTap: () => _handleVoiceoverTap(ex.audioUrl, isPro),
            onProBadgeTap: isPro ? () => ProVoiceoverSheet.show(context) : null,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: state.progress,
            minHeight: 4,
            backgroundColor: AppColors.systemGray5,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isShort = constraints.maxHeight < 640;
                final videoHeight = isShort ? 200.0 : 250.0;
                final timerFontSize = isShort ? 46.0 : 60.0;
                final playButtonSize = isShort ? 62.0 : 72.0;
                final playIconSize = isShort ? 34.0 : 40.0;
                final bottomPadding = isShort ? AppSpacing.md : AppSpacing.xxxl;

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Video Player with Overlays
                          GestureDetector(
                            onTap: () => _handlePlayPause(vm, state, ex, isRest),
                            child: Container(
                              height: videoHeight,
                              width: double.infinity,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryGroupedBackground,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusCard),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (_chewieController != null)
                                    Chewie(controller: _chewieController!)
                                  else
                                    Center(
                                        child: Icon(Icons.play_circle_outline_rounded,
                                            size: 64, color: AppColors.systemGray3)),

                                  // Duration chip & Rotate button bottom-right
                                  if (!isRest)
                                    Positioned(
                                      right: 8,
                                      bottom: 8,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _DurationChip(
                                            elapsedSeconds: (state.currentExercise!
                                                        .effectiveDuration(ex) -
                                                    state.remainingSeconds)
                                                .clamp(
                                                    0,
                                                    state.currentExercise!
                                                        .effectiveDuration(ex)),
                                            totalSeconds: state.currentExercise!
                                                .effectiveDuration(ex),
                                            formatTime: _formatTime,
                                          ),
                                          const SizedBox(width: 6),
                                          _VideoRotateButton(
                                            onTap: () => _toggleLandscape(true),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Multi-part indicator
                                  if (!isRest && _currentVideoPlaylist.length > 1)
                                    Positioned(
                                      left: 8,
                                      top: 8,
                                      child: _VideoPartBadge(
                                        currentPartUrl:
                                            _currentVideoPlaylist.isNotEmpty &&
                                                    _currentVideoPartIndex <
                                                        _currentVideoPlaylist.length
                                                ? _currentVideoPlaylist[
                                                    _currentVideoPartIndex]
                                                : '',
                                        partIndex: _currentVideoPartIndex,
                                        totalParts: _currentVideoPlaylist.length,
                                      ),
                                    ),

                                  // Dark overlay for Rest state
                                  if (isRest)
                                    Container(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'UP NEXT',
                                            style: AppTypography.caption1.copyWith(
                                              color: AppColors.systemGray2,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: AppSpacing.md),
                                            child: Text(
                                              nextEx?.name ?? 'Next Exercise',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isShort ? AppSpacing.sm : AppSpacing.lg),

                          if (isRest) ...[
                            Text(
                              'Take a breather',
                              style: isShort ? AppTypography.title2 : AppTypography.title1,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              child: Text(
                                'Next: ${state.workout?.exercises[(state.currentExerciseIndex + 1).clamp(0, state.workout!.exercises.length - 1)].exercise?.name}',
                                style: AppTypography.callout
                                    .copyWith(color: AppColors.secondaryLabel),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ] else
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.name,
                                    style: (isShort ? AppTypography.title3 : AppTypography.title2)
                                        .copyWith(fontWeight: FontWeight.w700),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        ex.difficulty.label.toUpperCase(),
                                        style: AppTypography.caption1Medium.copyWith(
                                          color: AppColors.secondaryLabel,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 6),
                                        child: Text('·',
                                            style: AppTypography.caption1.copyWith(
                                                color: AppColors.tertiaryLabel)),
                                      ),
                                      Text(
                                        ex.durationLabel,
                                        style: AppTypography.caption1Medium.copyWith(
                                          color: AppColors.secondaryLabel,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures()
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    ex.instructions,
                                    style: AppTypography.caption1
                                        .copyWith(color: AppColors.secondaryLabel),
                                    maxLines: isShort ? 2 : 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                          const Spacer(),

                          // Timer
                          Text(
                            isRest ? 'REST' : 'TIME REMAINING',
                            style: AppTypography.caption1.copyWith(
                              color: AppColors.tertiaryLabel,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(state.remainingSeconds),
                            style: GoogleFonts.robotoMono(
                              fontSize: timerFontSize,
                              fontWeight: FontWeight.w600,
                              color: AppColors.label,
                              letterSpacing: 1,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),

                          const Spacer(),

                          // Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                iconSize: 32,
                                color: AppColors.secondaryLabel,
                                icon: const Icon(Icons.skip_previous_rounded),
                                onPressed: vm.skipToPrevious,
                              ),
                              GestureDetector(
                                onTap: () => _handlePlayPause(vm, state, ex, isRest),
                                child: Container(
                                  height: playButtonSize,
                                  width: playButtonSize,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    (state.status == WorkoutStatus.playing ||
                                            state.status == WorkoutStatus.resting)
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: playIconSize,
                                  ),
                                ),
                              ),
                              IconButton(
                                iconSize: 32,
                                color: AppColors.secondaryLabel,
                                icon: const Icon(Icons.skip_next_rounded),
                                onPressed: vm.skipToNext,
                              ),
                            ],
                          ),
                          SizedBox(height: bottomPadding),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapePlayer({
    required BuildContext context,
    required WorkoutState state,
    required WorkoutViewModel vm,
    required ExerciseEntity ex,
    required bool isRest,
    required bool isPro,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompactMode = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-screen Video Player
          Center(
            child: AspectRatio(
              aspectRatio: _videoPlayerController?.value.isInitialized == true
                  ? _videoPlayerController!.value.aspectRatio
                  : 16 / 9,
              child: _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
            ),
          ),

          // Tap video to play/pause
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _handlePlayPause(vm, state, ex, isRest),
            ),
          ),

          // Rest Screen Overlay
          if (isRest)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'REST & BREATHE',
                        style: AppTypography.subheadlineSemibold.copyWith(
                          color: AppColors.primaryDark,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatTime(state.remainingSeconds),
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Next: ${state.workout?.exercises != null && state.workout!.exercises.isNotEmpty ? state.workout!.exercises[(state.currentExerciseIndex + 1).clamp(0, state.workout!.exercises.length - 1)].exercise?.name ?? '' : ''}',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 2. Cinematic Top Bar Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SafeArea(
                bottom: false,
                left: true,
                right: true,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 24),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: () {
                        vm.pause();
                        _showQuitDialog(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    _EpisodeCounterBadge(
                      current: state.currentExerciseIndex + 1,
                      total: state.workout?.exerciseCount ?? 0,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isRest ? 'Rest' : ex.name,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!isRest)
                            Text(
                              '${ex.difficulty.label.toUpperCase()} · ${ex.category}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.screen_rotation_rounded,
                          color: Colors.white, size: 22),
                      tooltip: 'Dikey Mod',
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: () => _toggleLandscape(false),
                    ),
                    const SizedBox(width: 4),
                    _BgmActionButton(
                      isEnabled: _isBgmEnabled,
                      isCompact: isCompactMode,
                      onTap: _toggleBgm,
                    ),
                    const SizedBox(width: 6),
                    _VoiceoverActionButton(
                      isEnabled: _isVoiceoverEnabled,
                      hasAudio: ex.audioUrl != null && !isRest,
                      isPro: isPro,
                      isCompact: isCompactMode,
                      onTap: () => _handleVoiceoverTap(ex.audioUrl, isPro),
                      onProBadgeTap:
                          isPro ? () => ProVoiceoverSheet.show(context) : null,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Cinematic Bottom Bar Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCompactMode) ...[
                      // Sub-row: Part badge and duration chip
                      if ((!isRest && _currentVideoPlaylist.length > 1) || !isRest)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (!isRest && _currentVideoPlaylist.length > 1)
                                _VideoPartBadge(
                                  currentPartUrl: _currentVideoPlaylist.isNotEmpty &&
                                          _currentVideoPartIndex <
                                              _currentVideoPlaylist.length
                                      ? _currentVideoPlaylist[_currentVideoPartIndex]
                                      : '',
                                  partIndex: _currentVideoPartIndex,
                                  totalParts: _currentVideoPlaylist.length,
                                )
                              else
                                const SizedBox.shrink(),
                              if (!isRest)
                                _DurationChip(
                                  elapsedSeconds:
                                      (state.currentExercise!.effectiveDuration(ex) -
                                              state.remainingSeconds)
                                          .clamp(
                                              0,
                                              state.currentExercise!
                                                  .effectiveDuration(ex)),
                                  totalSeconds:
                                      state.currentExercise!.effectiveDuration(ex),
                                  formatTime: _formatTime,
                                )
                              else
                                const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      // Main control row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded,
                                color: Colors.white, size: 28),
                            onPressed: state.currentExerciseIndex > 0
                                ? () => vm.skipToPrevious()
                                : null,
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                _handlePlayPause(vm, state, ex, isRest),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.45),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                state.status == WorkoutStatus.playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded,
                                color: Colors.white, size: 28),
                            onPressed: () => vm.skipToNext(),
                          ),
                          const SizedBox(width: 14),
                          // Digital Countdown Timer
                          Text(
                            _formatTime(state.remainingSeconds),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Video Part Badge if multiple parts
                          if (!isRest && _currentVideoPlaylist.length > 1)
                            _VideoPartBadge(
                              currentPartUrl: _currentVideoPlaylist.isNotEmpty &&
                                      _currentVideoPartIndex <
                                          _currentVideoPlaylist.length
                                  ? _currentVideoPlaylist[_currentVideoPartIndex]
                                  : '',
                              partIndex: _currentVideoPartIndex,
                              totalParts: _currentVideoPlaylist.length,
                            )
                          else
                            const SizedBox(width: 48),

                          // Center Controls: Prev, Play/Pause, Next & Countdown Timer
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.skip_previous_rounded,
                                    color: Colors.white, size: 28),
                                onPressed: state.currentExerciseIndex > 0
                                    ? () => vm.skipToPrevious()
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () =>
                                    _handlePlayPause(vm, state, ex, isRest),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.45),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    state.status == WorkoutStatus.playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.skip_next_rounded,
                                    color: Colors.white, size: 28),
                                onPressed: () => vm.skipToNext(),
                              ),
                              const SizedBox(width: 18),
                              // Digital Countdown Timer
                              Text(
                                _formatTime(state.remainingSeconds),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),

                          // Elapsed / Total Duration Chip
                          if (!isRest)
                            _DurationChip(
                              elapsedSeconds:
                                  (state.currentExercise!.effectiveDuration(ex) -
                                          state.remainingSeconds)
                                      .clamp(
                                          0,
                                          state.currentExercise!
                                              .effectiveDuration(ex)),
                              totalSeconds:
                                  state.currentExercise!.effectiveDuration(ex),
                              formatTime: _formatTime,
                            )
                          else
                            const SizedBox(width: 48),
                        ],
                      ),
                    const SizedBox(height: 8),
                    // Bottom thin session progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: state.progress,
                        minHeight: 3.5,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedScreen(BuildContext context) {
    final progress = ref.watch(homeViewModelProvider).progress;
    final xpEarned = 50; // AppConstants.xpWorkoutComplete

    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 52,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Workout Complete!', style: AppTypography.largeTitle),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Awesome job! You earned $xpEarned XP.',
                    style: AppTypography.body
                        .copyWith(color: AppColors.secondaryLabel),
                    textAlign: TextAlign.center,
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.systemBackground,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.local_fire_department_rounded,
                                  size: 26, color: Colors.deepOrange),
                              const SizedBox(height: 4),
                              Text(
                                '${progress.currentStreak} Day',
                                style: AppTypography.headline.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                              Text('Streak',
                                  style: AppTypography.caption1
                                      .copyWith(color: AppColors.secondaryLabel)),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 26, color: Colors.amber),
                              const SizedBox(height: 4),
                              Text(
                                'Level ${progress.level}',
                                style: AppTypography.headline.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                              Text(
                                '${progress.xpToNextLevel} to next',
                                style: AppTypography.caption1.copyWith(
                                  color: AppColors.secondaryLabel,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: HYButton(
                      label: 'Back to Home',
                      onPressed: () {
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ]);
                        context.go(RouteNames.home);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldPromptEnglishVoiceover(BuildContext context) {
    final lang = ref.read(appLanguageProvider);
    if (lang == AppLanguage.english) {
      return false;
    }
    if (lang == AppLanguage.turkish ||
        lang == AppLanguage.french ||
        lang == AppLanguage.spanish ||
        lang == AppLanguage.chinese) {
      return true;
    }
    final locale = Localizations.maybeLocaleOf(context);
    return locale != null && locale.languageCode != 'en';
  }

  Future<bool> _showVoiceoverLanguageDialog(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.systemBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.separator.withValues(alpha: 0.5),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.headphones_rounded,
                      size: 28,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.voiceoverAlertTitle,
                  style: AppTypography.title3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.label,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.voiceoverAlertMessage,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.secondaryLabel,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                HYButton(
                  label: l10n.voiceoverAlertConfirm,
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(
                    l10n.voiceoverAlertDismiss,
                    style: AppTypography.callout.copyWith(
                      color: AppColors.secondaryLabel,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return result ?? false;
  }

  Future<void> _handlePlayPause(
    WorkoutViewModel vm,
    WorkoutState state,
    ExerciseEntity ex,
    bool isRest,
  ) async {
    if (state.status == WorkoutStatus.playing ||
        state.status == WorkoutStatus.resting) {
      vm.pause();
      _videoPlayerController?.pause();
      _audioPlayer?.pause();
      _bgmPlayer?.pause();
      return;
    }

    if (!_hasPromptedVoiceoverLanguage &&
        _shouldPromptEnglishVoiceover(context)) {
      _hasPromptedVoiceoverLanguage = true;
      final wantAudio = await _showVoiceoverLanguageDialog(context);
      if (!mounted) return;
      setState(() {
        _isVoiceoverEnabled = wantAudio;
      });
    }

    vm.start();
    _videoPlayerController?.play();
    _videoPlayerController?.setVolume(0.0);
    if (_isBgmEnabled) {
      if (_bgmPlayer?.state == PlayerState.paused) {
        _bgmPlayer?.resume();
      } else {
        _initBgm();
      }
    }
    if (_isVoiceoverEnabled && ex.audioUrl != null && !isRest) {
      _lastExerciseIndex = state.currentExerciseIndex;
      if (_audioPlayer?.state == PlayerState.paused) {
        _audioPlayer?.resume();
      } else {
        _initAudio(ex.audioUrl);
      }
    } else {
      _audioPlayer?.stop();
    }
  }

  void _showQuitDialog(BuildContext context) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryGroupedBackground,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.separator.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon Badge
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.systemRed.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.directions_run_rounded,
                      size: 28,
                      color: AppColors.systemRed,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Title
                Text(
                  l10n.quitWorkoutDialogTitle,
                  style: AppTypography.title2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.label,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),

                // Message
                Text(
                  l10n.quitWorkoutDialogMessage,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.secondaryLabel,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Primary Action: Resume Workout
                HYButton(
                  label: l10n.quitWorkoutResumeButton,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ref.read(workoutViewModelProvider.notifier).start();
                  },
                ),
                const SizedBox(height: AppSpacing.xs),

                // Destructive Action: Quit
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                    context.go(RouteNames.home);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: Text(
                    l10n.quitWorkoutConfirmButton,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.systemRed,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// AppBar counter styled like a YouTube playlist badge ("3 / 8")
/// instead of plain "3 of 8" body text — small, gray, tabular-figure
/// numerals in a soft pill.
class _EpisodeCounterBadge extends StatelessWidget {
  final int current;
  final int total;

  const _EpisodeCounterBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        '$current / $total',
        style: AppTypography.caption1Medium.copyWith(
          color: AppColors.secondaryLabel,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// The little "0:12 / 0:45" chip in the bottom-right corner of the
/// player — the same shape as YouTube's duration/progress overlay —
/// instead of the time only living in the big countdown below.
class _DurationChip extends StatelessWidget {
  final int elapsedSeconds;
  final int totalSeconds;
  final String Function(int seconds) formatTime;

  const _DurationChip({
    required this.elapsedSeconds,
    required this.totalSeconds,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${formatTime(elapsedSeconds)} / ${formatTime(totalSeconds)}',
        style: GoogleFonts.robotoMono(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Compact button on the video player in portrait mode allowing instant
/// rotation / fullscreen transition without intermediate prompts.
class _VideoRotateButton extends StatelessWidget {
  final VoidCallback onTap;

  const _VideoRotateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.screen_rotation_rounded,
              size: 13,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              'Rotate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceoverActionButton extends StatelessWidget {
  final bool isEnabled;
  final bool hasAudio;
  final bool isPro;
  final bool isCompact;
  final VoidCallback onTap;
  final VoidCallback? onProBadgeTap;

  const _VoiceoverActionButton({
    required this.isEnabled,
    required this.hasAudio,
    required this.isPro,
    this.isCompact = false,
    required this.onTap,
    this.onProBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = isEnabled ? l10n.playerAudioOn : l10n.playerVoiceGuide;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 10,
          vertical: isCompact ? 5 : 6,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.primaryContainer
              : AppColors.secondaryGroupedBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled ? AppColors.primary : AppColors.separator,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEnabled ? Icons.headphones_rounded : Icons.headphones_outlined,
              size: 16,
              color:
                  isEnabled ? AppColors.primaryDark : AppColors.secondaryLabel,
            ),
            if (!isCompact) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.caption1.copyWith(
                  color: isEnabled ? AppColors.primaryDark : AppColors.label,
                  fontWeight: isEnabled ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(width: 4),
            if (!isPro)
              // Satın alınmamış durum: Canlı yeşil PRO rozeti
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.systemGreen, Color(0xFF28A745)],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.systemGreen.withValues(alpha: 0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  'PRO',
                  style: AppTypography.caption2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 8.5,
                    letterSpacing: 0.5,
                  ),
                ),
              )
            else
              // Satın alındıktan sonra: Satın alındı tarzında yeşil onaylı PRO rozeti
              GestureDetector(
                onTap: onProBadgeTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.systemGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: AppColors.systemGreen.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 10,
                        color: AppColors.systemGreen,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'PRO',
                        style: AppTypography.caption2.copyWith(
                          color: AppColors.systemGreen,
                          fontWeight: FontWeight.w800,
                          fontSize: 8.5,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoPartBadge extends StatelessWidget {
  final String currentPartUrl;
  final int partIndex;
  final int totalParts;

  const _VideoPartBadge({
    required this.currentPartUrl,
    required this.partIndex,
    required this.totalParts,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;
    final lower = currentPartUrl.toLowerCase();
    if (lower.contains('left')) {
      label = 'Left Side';
      icon = Icons.arrow_back_rounded;
    } else if (lower.contains('right')) {
      label = 'Right Side';
      icon = Icons.arrow_forward_rounded;
    } else {
      label = 'Part ${partIndex + 1} / $totalParts';
      icon = Icons.view_carousel_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _BgmActionButton extends StatelessWidget {
  final bool isEnabled;
  final bool isCompact;
  final VoidCallback onTap;

  const _BgmActionButton({
    required this.isEnabled,
    this.isCompact = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 10,
          vertical: isCompact ? 5 : 6,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.primaryContainer
              : AppColors.secondaryGroupedBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled ? AppColors.primary : AppColors.separator,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
              size: 16,
              color:
                  isEnabled ? AppColors.primaryDark : AppColors.secondaryLabel,
            ),
            if (!isCompact) ...[
              const SizedBox(width: 4),
              Text(
                isEnabled ? l10n.playerMusic : l10n.playerMusicOff,
                style: AppTypography.caption1.copyWith(
                  color: isEnabled ? AppColors.primaryDark : AppColors.label,
                  fontWeight: isEnabled ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
