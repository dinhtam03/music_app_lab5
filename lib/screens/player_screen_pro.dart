import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/providers/audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/models/lyric_line.dart';
import 'package:music_app/utils/lyrics_parser.dart';

class PlayerScreenPro extends StatefulWidget {
  const PlayerScreenPro({super.key});

  @override
  State<PlayerScreenPro> createState() => _PlayerScreenProState();
}

int _findCurrentLyricIndex(
  Duration position,
  List<LyricLine> lyrics,
) {
  for (int i = lyrics.length - 1; i >= 0; i--) {
    if (position >= lyrics[i].time) {
      return i;
    }
  }
  return 0;
}

class _PlayerScreenProState extends State<PlayerScreenPro> {
  final ScrollController _lyricsController = ScrollController();
  int _currentLyricIndex = 0;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString();
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _scrollToCurrentLyric(int index) {
    const itemHeight = 56.0;
    const containerHeight = 220.0;

    final targetOffset =
        (index * itemHeight) - (containerHeight / 2) + (itemHeight / 2);

    _lyricsController.animateTo(
      targetOffset.clamp(
        0,
        _lyricsController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, child) {
        if (audio.currentSong == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text('Không có bài hát nào đang phát',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          );
        }

        final song = audio.currentSong!;
        final isPlaying = audio.isPlaying;
        final position = audio.position;
        final duration = audio.duration;
        final progress = duration.inSeconds > 0
            ? position.inSeconds / duration.inSeconds
            : 0.0;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down,
                  size: 40, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert_rounded,
                    size: 32, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6B2D9F),
                  Color(0xFF4A148C),
                  Color(0xFF1A0033),
                  Colors.black,
                  Colors.black,
                ],
                stops: [0.0, 0.2, 0.5, 0.8, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isPlaying)
                            Container(
                              width: 340,
                              height: 340,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purpleAccent.withAlpha(180),
                                    blurRadius: 80,
                                    spreadRadius: 30,
                                  ),
                                ],
                              ),
                            )
                                .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true),
                                )
                                .scale(
                                  begin: const Offset(1.0, 1.0),
                                  end: const Offset(1.15, 1.15),
                                  duration: const Duration(milliseconds: 2000),
                                  curve: Curves.easeInOut,
                                ),
                          AnimatedRotation(
                            turns: isPlaying ? 10 : 0,
                            duration: const Duration(seconds: 20),
                            curve: Curves.linear,
                            child: Container(
                              width: 320,
                              height: 320,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.purpleAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Hero(
                            tag: 'artwork_${song.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: CachedNetworkImage(
                                imageUrl: song.imageUrl,
                                width: 300,
                                height: 300,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.music_note,
                                      size: 120, color: Colors.white38),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        song.title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.purpleAccent,
                              blurRadius: 15,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        song.artist,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 30),
                      if (isPlaying)
                        SizedBox(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(10, (index) {
                              final delay = index * 80;
                              return Container(
                                width: 6,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              )
                                  .animate(
                                    onPlay: (controller) =>
                                        controller.repeat(reverse: true),
                                  )
                                  .scale(
                                    begin: const Offset(0.3, 0.3),
                                    end: const Offset(1.0, 1.0),
                                    duration:
                                        Duration(milliseconds: 600 + delay),
                                    curve: Curves.easeInOut,
                                  )
                                  .moveY(
                                    begin: 20,
                                    end: -20,
                                    duration:
                                        Duration(milliseconds: 600 + delay),
                                    curve: Curves.easeInOut,
                                  );
                            }),
                          ),
                        ),
                      const SizedBox(height: 30),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 14),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 30),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.grey[600],
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withAlpha(77),
                        ),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (value) {
                            audio.seek(Duration(
                                seconds: (value * duration.inSeconds).round()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 16)),
                            Text(_formatDuration(duration),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.shuffle_rounded,
                                color: Colors.white60),
                            onPressed: () {},
                          ),
                          IconButton(
                            iconSize: 64,
                            icon: const Icon(Icons.skip_previous_rounded,
                                color: Colors.white),
                            onPressed: audio.previous,
                          ),
                          GestureDetector(
                            onTap: isPlaying ? audio.pause : audio.play,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 30,
                                      offset: const Offset(0, 15)),
                                ],
                              ),
                              child: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 72,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            iconSize: 64,
                            icon: const Icon(Icons.skip_next_rounded,
                                color: Colors.white),
                            onPressed: audio.next,
                          ),
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.repeat_rounded,
                                color: Colors.white60),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: IconButton(
                          key: ValueKey(audio.isFavorite(song)),
                          iconSize: 48,
                          icon: Icon(
                            audio.isFavorite(song)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: audio.isFavorite(song)
                                ? Colors.redAccent
                                : Colors.white70,
                          ),
                          onPressed: () => audio.toggleFavorite(song),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withAlpha(50),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.mic_rounded,
                                size: 48, color: Colors.white38),
                            const SizedBox(height: 16),
                            const Text(
                              'Lời bài hát',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FutureBuilder<List<LyricLine>>(
                              future: song.lyricsPath == null
                                  ? Future.value([])
                                  : LyricsParser.loadFromAssets(
                                      context, song.lyricsPath!),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(
                                        color: Colors.purpleAccent),
                                  );
                                }

                                final lyrics = snapshot.data!;

                                if (lyrics.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      'Chưa có lời bài hát 🎤',
                                      style: TextStyle(color: Colors.white70),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }

                                final currentIndex = _findCurrentLyricIndex(
                                    audio.position, lyrics);

                                if (mounted &&
                                    currentIndex != _currentLyricIndex) {
                                  _currentLyricIndex = currentIndex;

                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (_lyricsController.hasClients) {
                                      _scrollToCurrentLyric(currentIndex);
                                    }
                                  });
                                }

                                return SizedBox(
                                  height: 220,
                                  child: ListView.builder(
                                    controller: _lyricsController,
                                    itemCount: lyrics.length,
                                    itemBuilder: (context, index) {
                                      final isActive =
                                          index == _currentLyricIndex;

                                      return AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        style: TextStyle(
                                          fontSize: isActive ? 20 : 16,
                                          color: isActive
                                              ? Colors.white
                                              : Colors.white54,
                                          fontWeight: isActive
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          height: 1.6,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Text(
                                            lyrics[index].text,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _lyricsController.dispose();
    super.dispose();
  }
}
