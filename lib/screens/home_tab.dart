import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/providers/audio_provider.dart';
import 'package:music_app/services/api_service.dart';
import 'package:music_app/widgets/song_item_modern.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng ☀️';
    if (hour < 18) return 'Chào buổi chiều 🌤️';
    return 'Chào buổi tối 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final history = audioProvider.getHistory().take(8).toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A148C), Colors.black],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
                title: Text(
                  _getGreeting(),
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<List<Song>>(
                future: ApiService.fetchSongs(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(80),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Colors.purpleAccent)),
                    );
                  }

                  final allSongs = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (history.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 30, 20, 16),
                          child: Text('Nghe gần đây',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              final song = history[index];
                              return GestureDetector(
                                onTap: () =>
                                    audioProvider.setPlaylist(history, index),
                                child: Container(
                                  width: 140,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: CachedNetworkImage(
                                            imageUrl: song.imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Container(
                                                color: Colors.grey[800]),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        song.title,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        song.artist,
                                        style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Text('Gợi ý cho bạn',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allSongs.length,
                        itemBuilder: (context, index) {
                          final song = allSongs[index];
                          return SongItemModern(
                            song: song,
                            playlist: allSongs,
                            index: index,
                          );
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 140,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
