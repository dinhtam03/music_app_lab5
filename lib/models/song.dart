import 'package:hive/hive.dart';

part 'song.g.dart';

@HiveType(typeId: 0)
class Song {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String url;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final int? duration;


  @HiveField(6)
  final String? lyricsPath;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    required this.imageUrl,
    this.duration,
    this.lyricsPath, 
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      url: json['url'] as String,
      imageUrl: json['imageUrl'] as String,
      duration: json['duration'] as int?,
      lyricsPath: json['lyricsPath'] as String?, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'url': url,
      'imageUrl': imageUrl,
      'duration': duration,
      'lyricsPath': lyricsPath, 
    };
  }
}
