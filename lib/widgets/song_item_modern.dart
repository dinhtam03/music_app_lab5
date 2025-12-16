import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/providers/audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SongItemModern extends StatelessWidget {
  final Song song;
  final List<Song> playlist;
  final int index;

  const SongItemModern({
    required this.song,
    required this.playlist,
    required this.index,
    super.key,
  });

  String _formatDuration(int seconds) {
    final min = (seconds ~/ 60).toString();
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final audio = Provider.of<AudioProvider>(context);
    final isPlaying = audio.currentSong?.id == song.id && audio.isPlaying;
    final isCurrentSong = audio.currentSong?.id == song.id;
    final isFavorite = audio.isFavorite(song);
    final duration = song.duration ?? 0; 
    audio.duration.inSeconds > 0
        ? audio.position.inSeconds / audio.duration.inSeconds
        : 0.0;

    return Dismissible(
      key: ValueKey(song.id),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 30),
        child: const Icon(Icons.favorite, color: Colors.redAccent, size: 32),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        child: const Icon(Icons.queue_music, color: Colors.purpleAccent, size: 32),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          audio.toggleFavorite(song);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFavorite ? 'Đã xóa khỏi yêu thích' : 'Đã thêm vào yêu thích'),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã thêm vào hàng đợi phát tiếp')),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: isCurrentSong
                ? LinearGradient(
                    colors: [
                      Colors.purpleAccent.withOpacity(0.4),
                      Colors.deepPurple.withOpacity(0.25),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isCurrentSong ? null : Colors.white.withOpacity(0.08),
            border: Border.all(
              color: isCurrentSong ? Colors.purpleAccent.withOpacity(0.5) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: isCurrentSong
                ? [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 8,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              splashColor: Colors.purpleAccent.withOpacity(0.3),
              highlightColor: Colors.purpleAccent.withOpacity(0.15),
              onTap: () => audio.setPlaylist(playlist, index),
              child: Row(
                children: [
                  const SizedBox(width: 16),

                  Hero(
                    tag: 'artwork_${song.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: song.imageUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.music_note, color: Colors.white38, size: 36),
                            ),
                          ),
                          if (isPlaying)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.purple.withOpacity(0.5),
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
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: isPlaying
                                ? [
                                    Shadow(
                                      color: Colors.purpleAccent,
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (isFavorite)
                              const Icon(Icons.favorite, color: Colors.redAccent, size: 18),
                            if (isFavorite) const SizedBox(width: 6),
                            Text(
                              song.artist,
                              style: TextStyle(
                                fontSize: 14.5,
                                color: isPlaying ? Colors.white70 : Colors.grey[400],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      children: [
                        if (isPlaying)
                          SizedBox(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(6, (i) {
                                final delay = i * 80;
                                return Container(
                                  width: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                )
                                    .animate(
                                      onPlay: (controller) => controller.repeat(reverse: true),
                                    )
                                    .scale(
                                      begin: const Offset(0.3, 0.3),
                                      end: const Offset(1.0, 1.0),
                                      duration: Duration(milliseconds: 500 + delay),
                                      curve: Curves.easeInOut,
                                    )
                                    .moveY(
                                      begin: 14,
                                      end: -14,
                                      duration: Duration(milliseconds: 500 + delay),
                                      curve: Curves.easeInOut,
                                    );
                              }),
                            ),
                          ),

                        if (isCurrentSong && !isPlaying)
                          const Icon(Icons.play_arrow, color: Colors.white70, size: 28)
                        else if (!isPlaying)
                          const SizedBox(width: 28),

                        const SizedBox(width: 12),

                        Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(width: 16),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: IconButton(
                            key: ValueKey(isFavorite),
                            iconSize: 28,
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.redAccent : Colors.grey[500],
                            ),
                            onPressed: () => audio.toggleFavorite(song),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}