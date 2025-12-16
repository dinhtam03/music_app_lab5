import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_app/models/song.dart';
import 'package:music_app/providers/audio_provider.dart';
import 'package:music_app/providers/theme_provider.dart';
import 'package:music_app/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Hive
  await Hive.initFlutter();
  Hive.registerAdapter(SongAdapter());
  await Hive.openBox<Song>('favorites');
  await Hive.openBox<Song>('history');

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AudioProvider()..initBackground(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Muse',
            themeMode: ThemeMode
                .system, 
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: Colors.grey[50],
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
                surface: const Color(0xFF0F001A),
                surfaceContainer: const Color(0xFF1A0033),
              ),
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.white,
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.black54,
                selectedItemColor: Colors.purpleAccent,
                unselectedItemColor: Colors.grey,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => const MainScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon pulse + neon glow
              Animate(
                controller: _pulseController,
                effects: [
                  ScaleEffect(
                    begin: const Offset(
                        0.8, 0.8), // 
                    end: const Offset(1.2, 1.2),
                    curve: Curves.easeInOut,
                  ),
                ],
              ).custom(
                builder: (_, child, __) => Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.6),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Muse',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: Colors.purpleAccent,
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Khám phá âm nhạc của bạn',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.purple.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
