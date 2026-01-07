import 'dart:convert';
import 'package:flutter/foundation.dart';

class WsMessageParser {
  /// 嘗試解析 WebSocket 訊息（容錯版）
  static Map<String, dynamic>? parse(dynamic event) {
    try {
      String raw;

      if (event is String) {
        raw = event;
      } else if (event is List<int>) {
        raw = utf8.decode(event);
      } else {
        return null;
      }

      // 標準 JSON
      try {
        return json.decode(raw) as Map<String, dynamic>;
      } catch (_) {}

      // Python dict fallback
      final fixed = raw
          .replaceAll("'", '"')
          .replaceAll(": None", ": null")
          .replaceAll(": True", ": true")
          .replaceAll(": False", ": false");

      return json.decode(fixed) as Map<String, dynamic>;
    } catch (e) {
      debugPrint("WS parse failed: $e");
      return null;
    }
  }
}