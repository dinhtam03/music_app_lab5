import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/providers/audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MiniPlayer extends StatelessWidget {
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.onTap});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, child) {
        final song = audio.currentSong;
        if (song == null) return const SizedBox.shrink();

        final isPlaying = audio.isPlaying;
        final position = audio.position;
        final duration = audio.duration;
        final progress = duration.inSeconds > 0
            ? position.inSeconds / duration.inSeconds
            : 0.0;

        return Dismissible(
          key: const ValueKey('mini_player'),
          direction: DismissDirection.down,
          onDismissed: (_) {
          },
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              height: 94,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPlaying
                      ? [
                          Colors.purpleAccent.withOpacity(0.95),
                          Colors.deepPurple.withOpacity(0.85),
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
                      spreadRadius: 10,
                    ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: [
                          Text(
                            _formatDuration(position),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.grey[600],
                                thumbColor: Colors.purpleAccent,
                                overlayColor: Colors.purpleAccent.withOpacity(0.3),
                              ),
                              child: Slider(
                                value: progress.clamp(0.0, 1.0),
                                onChanged: (value) {
                                  final newPos = Duration(seconds: (value * duration.inSeconds).round());
                                  audio.seek(newPos);
                                },
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
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
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.music_note, color: Colors.white38, size: 38),
                                    ),
                                  ),
                                  if (isPlaying)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: RadialGradient(
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

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  song.artist,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 14.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          if (isPlaying)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: List.generate(6, (index) {
                                  final delay = index * 100;
                                  return Container(
                                    width: 4,
                                    height: 30,
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  )
                                      .animate(
                                        onPlay: (controller) => controller.repeat(reverse: true),
                                      )
                                      .scale(
                                        begin: const Offset(0.3, 0.3),
                                        end: const Offset(1.0, 1.0),
                                        duration: Duration(milliseconds: 600 + delay),
                                        curve: Curves.easeInOut,
                                      )
                                      .moveY(
                                        begin: 15,
                                        end: -15,
                                        duration: Duration(milliseconds: 600 + delay),
                                        curve: Curves.easeInOut,
                                      );
                                }),
                              ),
                            )
                          else
                            const SizedBox(width: 80),

                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 40),
                            onPressed: audio.previous,
                          ),

                          IconButton(
                            iconSize: 60,
                            splashRadius: 30,
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(scale: animation, child: child),
                              child: Icon(
                                isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                                key: ValueKey(isPlaying),
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                            onPressed: isPlaying ? audio.pause : audio.play, 
                          ),

                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 40),
                            onPressed: audio.next,
                          ),

                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}