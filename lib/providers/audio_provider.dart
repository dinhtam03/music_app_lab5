import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_app/models/song.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  Song? currentSong;
  List<Song> playlist = [];
  int currentIndex = -1;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;

  AudioProvider() {
    _player.durationStream.listen((d) {
      duration = d ?? Duration.zero;
      notifyListeners();
    });
    _player.positionStream.listen((p) {
      position = p;
      notifyListeners();
    });
    _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        next();
      }
      notifyListeners();
    });
  }

  Future<void> initBackground() async {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.example.music_app.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  }

  void setPlaylist(List<Song> songs, int index) {
    playlist = songs;
    currentIndex = index;
    play();
  }

  void play() async {
    if (currentIndex >= 0 && currentIndex < playlist.length) {
      currentSong = playlist[currentIndex];
      await _player.setAudioSource(AudioSource.uri(
        Uri.parse(currentSong!.url),
        tag: MediaItem(
          id: currentSong!.id,
          title: currentSong!.title,
          artist: currentSong!.artist,
          artUri: Uri.parse(currentSong!.imageUrl),
        ),
      ));
      _player.play();
      addToHistory(currentSong!);
    }
  }

  void pause() {
    _player.pause();
  }

  void next() {
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
      play();
    }
  }

  void previous() {
    if (currentIndex > 0) {
      currentIndex--;
      play();
    }
  }

  void seek(Duration pos) {
    _player.seek(pos);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // Favorites
  void toggleFavorite(Song song) {
    var box = Hive.box<Song>('favorites');
    if (box.containsKey(song.id)) {
      box.delete(song.id);
    } else {
      box.put(song.id, song);
    }
    notifyListeners();
  }

  bool isFavorite(Song song) {
    return Hive.box<Song>('favorites').containsKey(song.id);
  }

  List<Song> getFavorites() {
    return Hive.box<Song>('favorites').values.toList();
  }

  // History
  void addToHistory(Song song) {
    var box = Hive.box<Song>('history');
    if (box.containsKey(song.id)) {
      box.delete(song.id);
    }
    box.put(song.id, song);
  }

  List<Song> getHistory() {
    return Hive.box<Song>('history').values.toList().reversed.toList();
  }

  // Playlists
  void createPlaylist(String name, List<Song> songs) {
    var box = Hive.box<List<Song>>('playlists');
    box.put(name, songs);
  }

  List<String> getPlaylistNames() {
    return Hive.box<List<Song>>('playlists').keys.cast<String>().toList();
  }

  List<Song> getPlaylist(String name) {
    return Hive.box<List<Song>>('playlists').get(name) ?? [];
  }

  void addToPlaylist(String name, Song song) {
    var playlist = getPlaylist(name);
    if (!playlist.any((s) => s.id == song.id)) {
      playlist.add(song);
      Hive.box<List<Song>>('playlists').put(name, playlist);
    }
  }
}