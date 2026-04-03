import 'package:audioplayers/audioplayers.dart';

enum WorkoutSound {
  restStart,
  restEnd,
  exerciseDone,
  countdown,
  complete,
  buttonClick,
  startExercise,
  save,
  create,
}

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _uiPlayer = AudioPlayer(); // untuk button click
  final AudioPlayer _gamePlayer = AudioPlayer(); // untuk sound gameplay
  final AudioPlayer _loopPlayer = AudioPlayer(); // untuk loop countdown
  bool _enabled = true;

  bool get enabled => _enabled;

  void toggleSound() => _enabled = !_enabled;

  Future<void> play(WorkoutSound sound) async {
    if (!_enabled) return;
    try {
      // Untuk UI sound (button) — buat player baru agar bisa spam
      if (sound == WorkoutSound.buttonClick) {
        final spamPlayer = AudioPlayer();
        await spamPlayer.play(AssetSource(_soundPath(sound)));
        // Auto dispose setelah selesai
        spamPlayer.onPlayerComplete.listen((_) {
          spamPlayer.dispose();
        });
        return;
      }

      // Untuk sound lainnya — pakai player kategori seperti sebelumnya
      final player = _getPlayer(sound);
      await player.stop();
      await player.play(AssetSource(_soundPath(sound)));
    } catch (_) {}
  }

  Future<void> playLoop(WorkoutSound sound) async {
    if (!_enabled) return;
    try {
      await _loopPlayer.setReleaseMode(ReleaseMode.loop);
      await _loopPlayer.play(AssetSource(_soundPath(sound)));
    } catch (e) {
      print('❌ Loop sound error: $e');
    }
  }

  Future<void> stopLoop() async {
    try {
      await _loopPlayer.stop();
    } catch (_) {}
  }

  Future<void> playWithTimeout(WorkoutSound sound, {int seconds = 1}) async {
    if (!_enabled) return;
    try {
      final player = _getPlayer(sound);
      await player.stop();
      await player.play(AssetSource(_soundPath(sound)));
      Future.delayed(Duration(seconds: seconds), () {
        player.stop();
      });
    } catch (_) {}
  }

  // Tentukan player berdasarkan jenis sound
  AudioPlayer _getPlayer(WorkoutSound sound) {
    return switch (sound) {
      // UI sounds pakai _uiPlayer
      WorkoutSound.buttonClick => _uiPlayer,
      WorkoutSound.startExercise => _uiPlayer,
      WorkoutSound.save => _uiPlayer,
      WorkoutSound.create => _uiPlayer,

      // Gameplay sounds pakai _gamePlayer
      WorkoutSound.restStart => _gamePlayer,
      WorkoutSound.restEnd => _gamePlayer,
      WorkoutSound.exerciseDone => _gamePlayer,
      WorkoutSound.countdown => _gamePlayer,
      WorkoutSound.complete => _gamePlayer,
    };
  }

  String _soundPath(WorkoutSound sound) {
    return switch (sound) {
      WorkoutSound.restStart => 'sounds/start_rest.wav',
      WorkoutSound.restEnd => 'sounds/rest_end.mp3',
      WorkoutSound.exerciseDone => 'sounds/exercise_done.wav',
      WorkoutSound.countdown => 'sounds/countdown.wav',
      WorkoutSound.complete => 'sounds/complete.mp3',
      WorkoutSound.buttonClick => 'sounds/click_button.wav',
      WorkoutSound.startExercise => 'sounds/start_exercise.mp3',
      WorkoutSound.save => 'sounds/save.flac',
      WorkoutSound.create => 'sounds/create.wav',
    };
  }

  void dispose() {
    _uiPlayer.dispose();
    _gamePlayer.dispose();
    _loopPlayer.dispose();
  }
}
