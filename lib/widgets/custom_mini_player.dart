import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/providers/audio_provider.dart';
import 'package:music_app/screens/player_screen_pro.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomMiniPlayer extends StatelessWidget {
  const CustomMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, child) {
        if (audio.currentSong == null) return const SizedBox.shrink();

        final song = audio.currentSong!;
        final isPlaying = audio.isPlaying;
        final progress = audio.duration.inSeconds > 0
            ? audio.position.inSeconds / audio.duration.inSeconds
            : 0.0;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const PlayerScreenPro(),
              transitionDuration: const Duration(milliseconds: 600),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            height: 96,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isPlaying
                    ? [
                        Colors.purpleAccent.withOpacity(0.95),
                        Colors.deepPurple.withOpacity(0.8),
                      ]
                    : [
                        Colors.grey[900]!.withOpacity(0.95),
                        Colors.black87,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                if (isPlaying)
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.6),
                    blurRadius: 60,
                    spreadRadius: 12,
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  SizedBox(
                    height: 6,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: Colors.purpleAccent,
                        inactiveTrackColor: Colors.grey[700],
                        thumbColor: Colors.white,
                        overlayColor: Colors.purpleAccent.withOpacity(0.3),
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (value) {
                          final newPosition = Duration(
                              seconds:
                                  (value * audio.duration.inSeconds).round());
                          audio.seek(newPosition); // Tua chính xác
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Hero(
                          tag: 'mini_artwork_${song.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: song.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.music_note,
                                        color: Colors.white38, size: 40),
                                  ),
                                ),
                                if (isPlaying)
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.purple.withOpacity(0.4),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: isPlaying
                                      ? [
                                          Shadow(
                                            color: Colors.purpleAccent,
                                            blurRadius: 12,
                                            offset: const Offset(0, 3),
                                          )
                                        ]
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                song.artist,
                                style: TextStyle(
                                  color: isPlaying
                                      ? Colors.white70
                                      : Colors.grey[400],
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isPlaying)
                          SizedBox(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Container(
                                  width: 4,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                )
                                    .animate(
                                      onPlay: (controller) =>
                                          controller.repeat(reverse: true),
                                    )
                                    .scale(
                                      begin: const Offset(0.4, 0.4),
                                      end: const Offset(1.0, 1.0),
                                      duration: Duration(
                                          milliseconds: 600 + index * 100),
                                      curve: Curves.easeInOut,
                                    )
                                    .moveY(
                                      begin: 12,
                                      end: -12,
                                      duration: Duration(
                                          milliseconds: 600 + index * 100),
                                      curve: Curves.easeInOut,
                                    );
                              }),
                            ),
                          )
                        else
                          const SizedBox(width: 80),
                        IconButton(
                          iconSize: 60,
                          splashRadius: 30,
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_filled_rounded,
                              key: ValueKey(isPlaying),
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                          onPressed: isPlaying ? audio.pause : audio.play,
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded,
                              color: Colors.white, size: 42),
                          onPressed: audio.next,
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
