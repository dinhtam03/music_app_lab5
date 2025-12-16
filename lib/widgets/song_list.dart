import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/providers/audio_provider.dart';
import 'package:music_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SongList extends StatefulWidget {
  final List<Song>? songs;

  const SongList({super.key, this.songs});

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  late List<Song> _songs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.songs != null) {
      _songs = widget.songs!;
      _loading = false;
    } else {
      _fetchSongs();
    }
  }

  Future<void> _fetchSongs() async {
    final songs = await ApiService.fetchSongs();
    setState(() {
      _songs = songs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);

    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: List.generate(8, (index) => _buildShimmerItem()),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: _songs.length,
      itemBuilder: (context, index) {
        final song = _songs[index];
        final isFavorite = audioProvider.isFavorite(song);
        final isCurrentPlaying = audioProvider.currentSong?.id == song.id &&
            audioProvider.isPlaying;

        return Animate(
          effects: const [
            FadeEffect(duration: Duration(milliseconds: 600)),
            SlideEffect(
              begin: Offset(0, 0.3),
              curve: Curves.easeOutCubic,
            ),
          ],
          delay: Duration(milliseconds: 100 + index * 50),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.purpleAccent.withOpacity(0.2),
              highlightColor: Colors.purpleAccent.withOpacity(0.1),
              onTap: () {
                audioProvider.setPlaylist(_songs, index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isCurrentPlaying
                      ? Colors.purple.withOpacity(0.15)
                      : Colors.white.withOpacity(0.08),
                  border: Border.all(
                    color: isCurrentPlaying
                        ? Colors.purpleAccent.withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: song.imageUrl,
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.music_note, color: Colors.grey, size: 30),
                            ),
                          ),
                          if (isCurrentPlaying)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.purple.withOpacity(0.4),
                                ),
                                child: const Icon(
                                  Icons.equalizer,
                                  color: Colors.white,
                                  size: 32,
                                )
                                    .animate(
                                      onPlay: (controller) => controller.repeat(reverse: true),
                                    )
                                    .scale(
                                      begin: const Offset(0.9, 0.9),
                                      end: const Offset(1.1, 1.1),
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.easeInOut,
                                    ),
                              ),
                            ),
                          if (isCurrentPlaying)
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.purpleAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            song.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isCurrentPlaying ? Colors.purpleAccent : Colors.white,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            style: TextStyle(
                              fontSize: 14,
                              color: isCurrentPlaying
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    IconButton(
                      iconSize: 30,
                      splashRadius: 24,
                      onPressed: () => audioProvider.toggleFavorite(song),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(isFavorite),
                          color: isFavorite
                              ? Colors.redAccent
                              : Colors.white.withOpacity(0.6),
                          size: isFavorite ? 30 : 28,
                        ),
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

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!.withOpacity(0.5),
        highlightColor: Colors.grey[600]!.withOpacity(0.3),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 14, width: 150, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}