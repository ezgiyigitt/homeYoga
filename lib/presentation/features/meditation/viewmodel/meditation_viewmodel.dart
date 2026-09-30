import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/meditation_track_entity.dart';
import '../../../shared/providers/app_providers.dart';
import '../../home/viewmodel/home_viewmodel.dart';

class MeditationState {
  final bool isLoading;
  final String? error;
  final List<MeditationTrackEntity> tracks;
  final String selectedCategory;
  final MeditationTrackEntity? currentTrack;
  final bool isPlaying;
  final Duration position;
  final String mantra;
  final bool isSaving;

  const MeditationState({
    this.isLoading = true,
    this.error,
    this.tracks = const [],
    this.selectedCategory = 'Calm',
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.mantra = '',
    this.isSaving = false,
  });

  List<MeditationTrackEntity> get tracksInCategory =>
      tracks.where((t) => t.category == selectedCategory).toList();

  MeditationState copyWith({
    bool? isLoading,
    String? error,
    List<MeditationTrackEntity>? tracks,
    String? selectedCategory,
    MeditationTrackEntity? currentTrack,
    bool? isPlaying,
    Duration? position,
    String? mantra,
    bool? isSaving,
  }) {
    return MeditationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tracks: tracks ?? this.tracks,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      mantra: mantra ?? this.mantra,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Drives the sound-meditation screen: loads ambient/frequency tracks,
/// plays the selected one (audio-only — reuses VideoPlayerController
/// headlessly rather than pulling in a separate audio package), and
/// rotates a text mantra on a timer since there's no voice narration.
class MeditationViewModel extends StateNotifier<MeditationState> {
  final Ref _ref;
  final Random _random = Random();

  VideoPlayerController? _audioController;
  Timer? _mantraTimer;
  Timer? _positionTimer;

  MeditationViewModel(this._ref) : super(const MeditationState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _ref.read(getMeditationTracksUseCaseProvider).execute();
    if (res.isFailure) {
      state = state.copyWith(isLoading: false, error: res.errorOrNull);
      return;
    }
    final tracks = res.dataOrNull ?? const [];
    state = state.copyWith(isLoading: false, tracks: tracks, mantra: _pickMantra());

    final firstInCategory = tracks.where((t) => t.category == state.selectedCategory).toList();
    if (firstInCategory.isNotEmpty) {
      await selectTrack(firstInCategory.first);
    }
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    final match = state.tracksInCategory;
    if (match.isNotEmpty) {
      selectTrack(match.first);
    }
  }

  Future<void> selectTrack(MeditationTrackEntity track) async {
    await _disposeAudio();
    state = state.copyWith(currentTrack: track, isPlaying: false, position: Duration.zero);

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(track.audioUrl));
      await controller.initialize();
      controller.setLooping(true);
      _audioController = controller;
    } catch (e) {
      state = state.copyWith(error: 'Could not load audio: $e');
    }
  }

  void togglePlay() {
    final controller = _audioController;
    if (controller == null) return;

    if (state.isPlaying) {
      controller.pause();
      _positionTimer?.cancel();
      _mantraTimer?.cancel();
      state = state.copyWith(isPlaying: false);
    } else {
      controller.play();
      _startTimers();
      state = state.copyWith(isPlaying: true);
    }
  }

  void _startTimers() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final controller = _audioController;
      if (controller != null && controller.value.isInitialized) {
        state = state.copyWith(position: controller.value.position);
      }
    });

    _mantraTimer?.cancel();
    _mantraTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      state = state.copyWith(mantra: _pickMantra());
    });
  }

  String _pickMantra() {
    final pool = AppConstants.mantras;
    if (pool.isEmpty) return '';
    String next;
    do {
      next = pool[_random.nextInt(pool.length)];
    } while (next == state.mantra && pool.length > 1);
    return next;
  }

  Future<void> finish() async {
    if (state.isSaving) return;
    _positionTimer?.cancel();
    _mantraTimer?.cancel();
    _audioController?.pause();
    state = state.copyWith(isPlaying: false, isSaving: true);

    final minutes = max(1, state.position.inSeconds ~/ 60);
    final userId = _ref.read(localStorageProvider).userId ?? 'local';
    await _ref.read(completeMeditationUseCaseProvider).execute(
          userId: userId,
          durationMinutes: minutes,
        );

    // Refresh Home so streak/XP/skill points reflect the session.
    _ref.read(homeViewModelProvider.notifier).refresh();
    state = state.copyWith(isSaving: false);
  }

  Future<void> _disposeAudio() async {
    _positionTimer?.cancel();
    _mantraTimer?.cancel();
    await _audioController?.dispose();
    _audioController = null;
  }

  @override
  void dispose() {
    _disposeAudio();
    super.dispose();
  }
}

final meditationViewModelProvider =
    StateNotifierProvider.autoDispose<MeditationViewModel, MeditationState>(
  (ref) => MeditationViewModel(ref),
);
