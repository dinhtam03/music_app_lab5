import 'package:music_app/models/song.dart';

class ApiService {
  static final List<Song> _allSongs = [
    Song(
      id: '1',
      title: 'Chăng phải tình đầu sao đau đến thế',
      artist: 'MIN ft. dangrangto',
      url: 'assets/music/chang_phai_tinh_dau_sao_dau_den_the.mp3',
      imageUrl:
          'assets/images/chang_phai_tinh_dau_sao_dau_den_the.jpg',
    ),
    Song(
      id: '2',
      title: 'Chờ anh về',
      artist: 'BRAY X AMEE X Masew',
      url: 'assets/music/cho_anh_ve.mp3',
      imageUrl:
          'assets/images/cho_anh_ve.jpg',
    ),
    Song(
      id: '3',
      title: 'In Love',
      artist: 'Lowg ft. JustaTee',
      url: 'assets/music/in_love.mp3',
      imageUrl:
          'assets/images/in_love.jpg',
    ),
  ];

  static Future<List<Song>> fetchSongs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<Song>.from(_allSongs);
  }

  static Future<List<Song>> searchSongs(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    return _allSongs
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q))
        .toList();
  }
}
