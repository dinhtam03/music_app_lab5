import 'package:flutter/material.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/services/api_service.dart';
import 'package:music_app/widgets/song_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Song> _results = [];
  bool _isSearching = false;

  void _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await ApiService.searchSongs(query);

    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm bài hát hoặc ca sĩ...',
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 18),
          onChanged: _search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              _search('');
            },
          ),
        ],
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty && _controller.text.isNotEmpty
              ? const Center(child: Text('Không tìm thấy kết quả'))
              : SongList(songs: _results),
    );
  }
}
