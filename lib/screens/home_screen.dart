import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/providers/audio_provider.dart';
import 'package:music_app/providers/theme_provider.dart';
import 'package:music_app/services/api_service.dart';
import 'package:music_app/widgets/custom_mini_player.dart';
import 'package:music_app/widgets/song_item_modern.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];
  bool _isLoading = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng ☀️';
    if (hour < 18) return 'Chào buổi chiều 🌇';
    return 'Chào buổi tối 🌙';
  }

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _searchController.addListener(_onSearchChanged);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  Future<void> _loadSongs() async {
    final songs = await ApiService.fetchSongs();
    setState(() {
      _allSongs = songs;
      _filteredSongs = songs;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredSongs = _allSongs;
      } else {
        _filteredSongs = _allSongs
            .where((song) =>
                song.title.toLowerCase().contains(query) ||
                song.artist.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final history = audioProvider.getHistory().take(8).toList();

    return Scaffold(
      extendBody: true,
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
            stops: [0.0, 0.15, 0.4, 0.8, 1.0],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  titlePadding:
                      const EdgeInsetsDirectional.only(start: 20, bottom: 20),
                  title: Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 8,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.purple.shade700.withOpacity(0.8),
                              Colors.purple.shade900.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(90),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white.withOpacity(0.15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(
                          hintText: 'Tìm bài hát, nghệ sĩ, album...',
                          hintStyle:
                              TextStyle(color: Colors.white60, fontSize: 17),
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.white70, size: 28),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.white70),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged();
                                  },
                                )
                              : const Icon(Icons.mic, color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Theme.of(context).brightness == Brightness.dark
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              color: Colors.white,
                              size: 26,
                            ),
                            onPressed: () => themeProvider.toggleTheme(
                                Theme.of(context).brightness ==
                                    Brightness.light),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: _isLoading
                    ? Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Shimmer.fromColors(
                          baseColor: Colors.purple.shade300.withOpacity(0.3),
                          highlightColor:
                              Colors.purple.shade100.withOpacity(0.2),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.purpleAccent),
                            ),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (history.isNotEmpty) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 40, 20, 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Nghe gần đây',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Xem tất cả',
                                      style: TextStyle(
                                          color: Colors.purpleAccent,
                                          fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 160,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: history.length,
                                itemBuilder: (context, index) {
                                  final song = history[index];
                                  return GestureDetector(
                                    onTap: () => audioProvider.setPlaylist(
                                        history, index),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: SizedBox(
                                        width: 120,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Stack(
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl: song.imageUrl,
                                                    width: 120,
                                                    height: 120,
                                                    fit: BoxFit.cover,
                                                    placeholder: (_, __) =>
                                                        Container(
                                                            color: Colors
                                                                .grey[800]),
                                                  ),
                                                  Positioned.fill(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: [
                                                            Colors.transparent,
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.6),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const Positioned(
                                                    bottom: 8,
                                                    right: 8,
                                                    child: Icon(
                                                      Icons.play_circle_fill,
                                                      color:
                                                          Colors.purpleAccent,
                                                      size: 32,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              song.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              song.artist,
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Text(
                              _searchController.text.isEmpty
                                  ? 'Tất cả bài hát'
                                  : 'Kết quả tìm kiếm • ${_filteredSongs.length}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (_filteredSongs.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 100),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.music_off,
                                        size: 80, color: Colors.grey),
                                    SizedBox(height: 20),
                                    Text(
                                      'Không tìm thấy bài hát nào',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final song = _filteredSongs[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 10),
                                    child: SongItemModern(
                                      song: song,
                                      playlist: _filteredSongs,
                                      index: index,
                                    ),
                                  );
                                },
                                childCount: _filteredSongs.length,
                              ),
                            ),
                          const SizedBox(height: 120),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Consumer<AudioProvider>(
        builder: (context, audio, child) {
          return audio.currentSong != null
              ? const CustomMiniPlayer()
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
