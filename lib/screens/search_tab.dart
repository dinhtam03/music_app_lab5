import 'package:flutter/material.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/services/api_service.dart';
import 'package:music_app/widgets/song_item_modern.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  List<Song> _results = [];
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _animationController.reset();

    final results = await ApiService.searchSongs(query);

    if (mounted) {
      setState(() {
        _results = results;
        _isSearching = false;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A148C), Color(0xFF1A0033), Colors.black],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),

          // Search bar siêu đẹp glassmorphism + shadow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Hero(
              tag: 'search_bar',
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _controller,
                  autofocus: false,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Tìm bài hát, ca sĩ, album...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 18),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Colors.white70, size: 28),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: Colors.white70, size: 28),
                            onPressed: () {
                              _controller.clear();
                              _onSearchChanged();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide(
                          color: Colors.purpleAccent.withOpacity(0.6),
                          width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                  ),
                  onSubmitted: (_) => _onSearchChanged(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.purpleAccent,
                      strokeWidth: 5,
                    ),
                  )
                : _controller.text.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_rounded,
                                size: 100, color: Colors.grey[700]),
                            const SizedBox(height: 24),
                            Text(
                              'Tìm kiếm bài hát yêu thích',
                              style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Gõ tên bài hát hoặc ca sĩ để bắt đầu',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sentiment_dissatisfied,
                                    size: 80, color: Colors.grey[600]),
                                const SizedBox(height: 24),
                                Text(
                                  'Không tìm thấy kết quả',
                                  style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Thử tìm với từ khóa khác nhé',
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final song = _results[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: SongItemModern(
                                    song: song,
                                    playlist: _results,
                                    index: index,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
