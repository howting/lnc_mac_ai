import 'package:flutter/services.dart';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class VoiceRecorder {
  final Record _record = Record();

  Future<String?> startRecord() async {
    if (!await _record.hasPermission()) return null;

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;

    AudioEncoder encoder;
    String ext;

    if (Platform.isIOS) {
      // 🔹 iOS → 用 AAC，副檔名 m4a（Apple 最吃這套）
      encoder = AudioEncoder.aacLc;
      ext = 'm4a';
    } else {
      // 🔹 Android → 你要 WAV 或 AAC 都行，這裡先留 WAV
      encoder = AudioEncoder.wav;
      ext = 'wav';
    }

    final path = p.join(dir.path, 'rec_$ts.$ext');

    try {
      await _record.start(
        path: path,
        encoder: encoder,
        bitRate: 128000,
        samplingRate: 16000,
      );
      print("startRecord path=$path encoder=$encoder");
      return path;
    } on PlatformException catch (e) {
      print("VoiceRecorder.startRecord error: $e");
      return null;
    }
  }

  Future<String?> stopRecord() async {
    final path = await _record.stop();
    print("stopRecord path=$path");
    return path;
  }

  Future<void> dispose() async {
    await _record.dispose();
  }
}