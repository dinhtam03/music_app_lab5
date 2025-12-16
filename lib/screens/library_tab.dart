import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/providers/audio_provider.dart';
import 'package:music_app/widgets/song_item_modern.dart';
import 'package:provider/provider.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final favorites = audioProvider.getFavorites();
    final history = audioProvider.getHistory().take(30).toList();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFF4A148C),
              Colors.black,
              Colors.black,
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                title: const Text(
                  'Thư viện',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.purpleAccent,
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.purple.shade600.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.library_music_rounded,
                      size: 110,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.redAccent, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'Bài hát yêu thích',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    if (favorites.isNotEmpty)
                      Text(
                        '${favorites.length} bài',
                        style: TextStyle(color: Colors.grey[400], fontSize: 15),
                      ),
                  ],
                ),
              ),
            ),
            favorites.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                      padding: EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.favorite_border_rounded,
                              size: 80, color: Colors.grey[600]),
                          SizedBox(height: 20),
                          Text(
                            'Chưa có bài hát nào được yêu thích',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Nhấn trái tim để thêm bài hát vào đây nhé ❤️',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = favorites[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: SongItemModern(
                            song: song,
                            playlist: favorites,
                            index: index,
                          ),
                        );
                      },
                      childCount: favorites.length,
                    ),
                  ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded,
                        color: Colors.cyanAccent, size: 30),
                    const SizedBox(width: 12),
                    Text(
                      'Nghe gần đây',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '${history.length} bài',
                      style: TextStyle(color: Colors.grey[400], fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = history[index];
                    return GestureDetector(
                      onTap: () => audioProvider.setPlaylist(history, index),
                      child: Column(
                        children: [
                          Hero(
                            tag: 'history_${song.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: CachedNetworkImage(
                                      imageUrl: song.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) =>
                                          Container(color: Colors.grey[800]),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            song.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            song.artist,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: history.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(height: 90),
            ),
          ],
        ),
      ),
    );
  }
}
