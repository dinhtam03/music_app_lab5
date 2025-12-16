import 'package:flutter/material.dart';
import '../models/lyric_line.dart';

class LyricsParser {
  static Future<List<LyricLine>> loadFromAssets(
    BuildContext context,
    String path,
  ) async {
    try {
      final raw = await DefaultAssetBundle.of(context).loadString(path);
      final lines = raw.split('\n');

      final List<LyricLine> result = [];

      final regex = RegExp(r'\[(\d+):(\d+).(\d+)\](.*)');

      for (final line in lines) {
        final match = regex.firstMatch(line.trim());
        if (match != null) {
          final min = int.parse(match.group(1)!);
          final sec = int.parse(match.group(2)!);
          final ms = int.parse(match.group(3)!);
          final text = match.group(4)!.trim();

          result.add(
            LyricLine(
              time: Duration(
                minutes: min,
                seconds: sec,
                milliseconds: ms * 10,
              ),
              text: text,
            ),
          );
        }
      }

      return result;
    } catch (e) {
      return [];
    }
  }
}
