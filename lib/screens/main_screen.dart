// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:music_app/screens/home_tab.dart';
import 'package:music_app/screens/search_tab.dart';
import 'package:music_app/screens/library_tab.dart';
import 'package:music_app/widgets/custom_mini_player.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: const [
              HomeTab(),
              SearchTab(),
              LibraryTab(),
            ],
          ),
          const Positioned(bottom: 80, left: 0, right: 0, child: CustomMiniPlayer()),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black],
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.ease);
            setState(() => _currentIndex = i);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Library'),
          ],
        ),
      ),
    );
  }
}