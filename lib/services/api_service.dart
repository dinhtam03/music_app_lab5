import 'package:music_app/models/song.dart';

class ApiService {
  static final List<Song> _allSongs = [
    Song(
      id: '1',
      title: 'Exit Sign',
      artist: 'HIEUTHUHAI ft. marzuz',
      url: 'assets/music/exit_sign.mp3',
      imageUrl:
          'https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/9a/80/e5/9a80e53a-197d-6d4d-2799-ac0a68427d12/602458735987_Cover.jpg/800x800cc.jpg',
      lyricsPath: 'assets/lyrics/exit_sign.lrc',
    ),
    Song(
      id: '2',
      title: 'Không Thể Say',
      artist: 'HIEUTHUHAI',
      url: 'assets/music/khong_the_say.mp3',
      imageUrl:
          'https://f.hoatieu.vn/data/image/2023/04/19/loi-bai-hat-khong-the-say-hieuthuhai-700.jpg',
    ),
    Song(
      id: '3',
      title: 'See Tình',
      artist: 'Hoàng Thùy Linh',
      url: 'assets/music/see_tinh.mp3',
      imageUrl:
          'https://bazaarvietnam.vn/wp-content/uploads/2022/02/SBT_4472.jpg',
    ),
    Song(
      id: '4',
      title: 'Đi Về Nhà',
      artist: 'Đen Vâu ft. JustaTee',
      url: 'assets/music/di_ve_nha.mp3',
      imageUrl:
          'https://cafebiz.cafebizcdn.vn/162123310254002176/2021/1/29/photo-2-1611908099181254349031.jpg',
    ),
    Song(
      id: '5',
      title: 'Em Bé',
      artist: 'AMEE ft. Karik',
      url: 'assets/music/em_be.mp3',
      imageUrl:
          'https://afamilycdn.com/150157425591193600/2020/9/21/am-1600679931453803298675.jpg',
    ),
    Song(
      id: '6',
      title: 'Muộn Rồi Mà Sao Còn',
      artist: 'Sơn Tùng M-TP',
      url: 'assets/music/mon_roi_ma_sao_con.mp3',
      imageUrl:
          'https://images.genius.com/d6086f24dcdfcb05b5624f59afcfa056.600x600x1.jpg',
    ),
    Song(
      id: '7',
      title: 'Nơi Này Có Anh',
      artist: 'Sơn Tùng M-TP',
      url: 'assets/music/noi_nay_co_anh.mp3',
      imageUrl:
          'https://images.genius.com/b6c44f836516ce8f33d539e140300a55.1000x1000x1.jpg',
    ),
    Song(
      id: '8',
      title: 'Em Của Ngày Hôm Qua',
      artist: 'Sơn Tùng M-TP',
      url: 'assets/music/em_cua_ngay_hom_qua.mp3',
      imageUrl:
          'http://image.mp3.zdn.vn/covers/b/1/b1c839bd85e6081614cf770278b8f782_1387164001.jpg',
    ),
    Song(
      id: '9',
      title: 'Faded',
      artist: 'Alan Walker',
      url: 'assets/music/faded.mp3',
      imageUrl:
          'https://p2.music.126.net/xVVVoLHhTg5tahAenhMi2g==/109951165213269908.jpg',
    ),
    Song(
      id: '10',
      title: 'Happier',
      artist: 'Marshmello ft. Bastille',
      url: 'assets/music/happier.mp3',
      imageUrl: 'https://i.ytimg.com/vi/-y6WACdajGk/maxresdefault.jpg',
    ),
    Song(
      id: '11',
      title: 'Thiên Lý Ơi',
      artist: 'Jack - J97',
      url: 'assets/music/thien_ly_oi.mp3',
      imageUrl: 'https://i.ytimg.com/vi/OrDB4jpA1g8/maxresdefault.jpg',
    ),
    Song(
      id: '12',
      title: 'Sài Gòn Đau Lòng Quá',
      artist: 'Hứa Kim Tuyền ft. Hoàng Duyên',
      url: 'assets/music/sai_gon_dau_long_qua.mp3',
      imageUrl:
          'https://i1.sndcdn.com/artworks-VYxs3hBeBd8LGd4C-zvEUow-t500x500.jpg',
    ),
    Song(
      id: '13',
      title: 'Nếu Lúc Đó',
      artist: 'tlinh ft. 2Pillz',
      url: 'assets/music/neu_luc_do.mp3',
      imageUrl: 'https://i.ytimg.com/vi/fyMgBQioTLo/maxresdefault.jpg',
    ),
    Song(
      id: '14',
      title: 'Ái Nộ',
      artist: 'Masew ft. Khoi Vu',
      url: 'assets/music/ai_no.mp3',
      imageUrl:
          'https://f.hoatieu.vn/data/image/2021/08/31/loi-bai-hat-ai-no-so-1.jpg',
      lyricsPath: 'assets/lyrics/ai_no.lrc',
    ),
    Song(
      id: '15',
      title: 'Shape of You',
      artist: 'Ed Sheeran',
      url: 'assets/music/shape_of_you.mp3',
      imageUrl: 'https://i.ytimg.com/vi/5pvEgyaoqm8/maxresdefault.jpg',
    ),
    Song(
      id: '16',
      title: 'Believer',
      artist: 'Imagine Dragons',
      url: 'assets/music/believer.mp3',
      imageUrl: 'https://i.ytimg.com/vi/Q0KuJrbrzoA/maxresdefault.jpg',
    ),
    Song(
      id: '17',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      url: 'assets/music/blinding_lights.mp3',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/e/e6/The_Weeknd_-_Blinding_Lights.png',
    ),
    Song(
      id: '18',
      title: 'Levitating',
      artist: 'Dua Lipa',
      url: 'assets/music/levitating.mp3',
      imageUrl:
          'https://www.billboard.com/wp-content/uploads/2020/11/01-dua-lipa-performance-ama-2020-billboard-1548-1606099534.jpg',
    ),
    Song(
      id: '19',
      title: 'Stay',
      artist: 'The Kid LAROI ft. Justin Bieber',
      url: 'assets/music/stay.mp3',
      imageUrl: 'http://i.ytimg.com/vi/kTJczUoc26U/maxresdefault.jpg',
    ),
    Song(
      id: '20',
      title: 'Industry Baby',
      artist: 'Lil Nas X ft. Jack Harlow',
      url: 'assets/music/industry_baby.mp3',
      imageUrl: 'https://i.ytimg.com/vi/I42Pgdmk11I/maxresdefault.jpg',
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
