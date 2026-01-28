import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:lncmacai/ai/const_api.dart';
import 'package:lncmacai/ai/module/boardrecommend/boardrecommendchat_provider.dart';
import 'package:lncmacai/ai/module/boardrecommend/oss_uploader.dart';
import 'package:lncmacai/global.dart';
import 'package:lncmacai/ai/module/boardrecommend/ws_message_parser.dart';
import 'voice_recorder.dart';

class boardrecommendChatController extends GetxController {
  boardrecommendChatController(this._provider);

  final boardrecommendChatProvider _provider;

  // =============================
  // State
  // =============================
  final RxString lastUserQuestion = ''.obs;
  final RxBool canSend = false.obs;
  final RxList<ChatMessage> chatMessageList = <ChatMessage>[].obs;

  final TextEditingController textController = TextEditingController();
  final FocusNode textFocusNode = FocusNode();

  // =============================
  // Audio
  // =============================
  final AudioPlayer audioplayer = AudioPlayer();
  final VoiceRecorder voiceRecorder = VoiceRecorder();
  final RxMap<int, File> files = <int, File>{}.obs;
  final String _dir = 'voice';
  final String _ext = '.wav';

  // =============================
  // Image (OSS)
  // =============================
  final ImagePicker _picker = ImagePicker();
  final OssUploader _ossUploader =
      OssUploader('https://www.lnc-ai.com/api/generate_oss_signature/');

  final List<String> ossImageKeys = [];
  final RxList<XFile> selectedImages = <XFile>[].obs;

  // =============================
  // WebSocket
  // =============================
  WebSocket? _ws;

  // =============================
  // Lifecycle
  // =============================
  @override
  void onInit() {
    super.onInit();
    textController.addListener(_updateCanSend);
  }

  @override
  void onClose() {
    try {
      _ws?.close();
    } catch (_) {}
    voiceRecorder.dispose();
    audioplayer.dispose();
    textController.dispose();
    textFocusNode.dispose();
    super.onClose();
  }

  void _updateCanSend() {
    canSend.value =
        textController.text.trim().isNotEmpty || ossImageKeys.isNotEmpty;
  }

  // =============================
  // Image pick + upload (OSS)
  // =============================
  // Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
  //   final XFile? image = await _picker.pickImage(source: source);
  //   if (image == null) return;

  //   Get.dialog(
  //     const Center(child: CircularProgressIndicator()),
  //     barrierDismissible: false,
  //   );

  //   try {
  //     selectedImages.clear();
  //     ossImageKeys.clear();
  //     selectedImages.add(image);

  //     final ext = p.extension(image.path);
  //     final filename =
  //         'board_${DateTime.now().millisecondsSinceEpoch}${ext.isEmpty ? '.jpg' : ext}';

  //     final sign = await _ossUploader.uploadXFile(image, filename);
  //     ossImageKeys.add(sign.objectKey);

  //     _updateCanSend();
  //     Get.snackbar("圖片上傳完成", "已上傳 1 張圖片");
  //   } catch (e) {
  //     Get.snackbar("上傳失敗", e.toString());
  //   } finally {
  //     if (Get.isDialogOpen == true) Get.back();
  //   }
  // }
  Future<void> pickImage({required ImageSource source}) async {
    final XFile? image =
        await _picker.pickImage(source: source, imageQuality: 80);
    if (image == null) return;

    // 1. 立即加入預覽清單，讓 UI 顯示
    selectedImages.add(image);
    canSend.value = true;

    try {
      // 2. 開始背景上傳
      final ext = p.extension(image.path).toLowerCase();
      final filename =
          "workorder-uploads/${DateTime.now().millisecondsSinceEpoch}$ext";

      // 注意：這裡不需要 Get.dialog 轉圈圈了，因為我們是背景上傳
      final sign = await _ossUploader.uploadXFile(image, filename);

      // 3. 上傳成功，將 Key 存入待發送清單
      ossImageKeys.add(sign.objectKey);
      print("圖片預上傳成功: ${sign.objectKey}");
    } catch (e) {
      // 如果上傳失敗，從預覽中移除並提示
      selectedImages.remove(image);
      Get.snackbar("上傳失敗", "圖片上傳雲端失敗，請重試");
    }
  }

  // =============================
  // Send text / image -> qwenboard (ACK + WS)
  // =============================
  Future<void> sendAction({String? overrideText}) async {
    try {
      textFocusNode.unfocus();
      final text = (overrideText ?? textController.text).trim();
      if (text.isEmpty || text == "") {
        Get.snackbar("發送失敗", "請輸入你的問題");
        return;
      }

      // 快照備份當前待發送的數據
      final List<XFile> imagesToDisplay = List.from(selectedImages);

      chatMessageList.add(ChatMessage(
        data: text.isNotEmpty ? text : "[已上傳圖片]",
        question: text,
        isMe: true,
        images: imagesToDisplay,
      ));

      if (overrideText == null) textController.clear();
      _updateCanSend();

      final assistant = ChatMessage(
        data: "生成中…",
        isMe: false,
        isAnswering: true,
      );
      chatMessageList.add(assistant);

      final res = await _provider.qwenBoard(
        "api/qwenboard/",
        text: text,
        imageKeys: ossImageKeys.toList(),
      );

      if (res.body?.code == "success" && res.body?.data != null) {
        final inquiryId = (res.body!.data!["inquiry_id"] ?? "").toString();
        if (inquiryId.isNotEmpty) {
          assistant.inquiryId = inquiryId;
          await _setupWebSocket(inquiryId);
          ossImageKeys.clear();
          selectedImages.clear();
          _updateCanSend();
          return;
        }
      }

      _finalizeError(assistant);
    } catch (_) {
      _finalizeError(chatMessageList.isNotEmpty ? chatMessageList.last : null);
    }
  }

  void _finalizeError(ChatMessage? msg, [String text = "服務器繁忙"]) {
    if (msg == null) return;
    msg
      ..data = text
      ..isAnswering = false;
    chatMessageList.refresh();
  }

  // =============================
  // WebSocket
  // =============================
  Future<void> _setupWebSocket(String inquiryId) async {
    try {
      await _ws?.close();
    } catch (_) {}

    _ws = await WebSocket.connect(
      "ws://8.138.246.252:8000/ws/chat_qwen_$inquiryId/",
    );
    _ws!.listen((event) {
      try {
        // ===== 正確處理 bytes / string =====
        String text;
        if (event is String) {
          text = event;
        } else if (event is List<int>) {
          text = utf8.decode(event);
        } else {
          return;
        }

        // 改這裡：用容錯 parser
        final map = WsMessageParser.parse(text);
        if (map == null) {
          debugPrint("WS parse failed: $text");
          return;
        }

        final r = map["response_data"] ?? map["response"] ?? map["data"];

        if (r is! Map) return;

        debugPrint("WS DATA: $r");
        debugPrint(
            "WS is_finished raw: ${r["is_finished"]} (${r["is_finished"]?.runtimeType})");

        final String inqId = r["inquiry_id"]?.toString() ?? "";
        final idx = chatMessageList.indexWhere(
          (m) => m.inquiryId == inqId,
        );
        if (idx == -1) return;

        final msg = chatMessageList[idx];

        final bool isFinished = r["is_finished"] == true;
        final String fragment = (r["reply_fragment"] ?? "").toString();
        final String finalContent = (r["reply_content"] ?? "").toString();

        // ===== 串流文字 =====
        if (!isFinished && fragment.isNotEmpty) {
          if (msg.data == "生成中…") msg.data = "";
          msg.data += fragment;
        }

        // ===== 完成時 =====
        if (isFinished) {
          if (finalContent.isNotEmpty) {
            msg.data = finalContent;
          }
          final sessionId = (r["session_id"] ?? "").toString();
          List<ReplyCase>? internal = (r["cases"]["internal"] as List).isEmpty
              ? null
              : (r["cases"]["internal"] as List)
                  .map((e) => ReplyCase.fromJson(e))
                  .toList();
          List<ReplyCase>? external = (r["cases"]["external"] as List).isEmpty
              ? null
              : (r["cases"]["external"] as List)
                  .map((e) => ReplyCase.fromJson(e))
                  .toList();
          msg.sessionId = sessionId;
          msg.internal = internal;
          msg.external = external;
          msg.isAnswering = false;
          msg.isFinished = true;
          chatMessageList.refresh();
          _ws?.close();
          return;
        }

        msg.isAnswering = true;
        chatMessageList.refresh();
      } catch (e, s) {
        debugPrint("WS handler error: $e");
        debugPrint("$s");
      }
    }, onError: (e) {
      debugPrint("WS error: $e");
    }, onDone: () {
      debugPrint("WS closed");
    });
  }

  // =============================
  // Voice -> text -> send
  // =============================
  Future<void> handleVoiceFile(String path, {int? durationSec}) async {
    final file = File(path);
    if (!await file.exists()) return;

    final bytes = await file.readAsBytes();
    final fileName = p.basename(path);

    final res = await _provider.wav2text(
      WAV_POST,
      bytes,
      fileName,
    );

    if (res.body?.code != "success" || res.body?.data == null) return;

    final questionText = (res.body!.data!["question"] ?? "").toString().trim();
    if (questionText.isEmpty) return;

    lastUserQuestion.value = questionText;
    await sendAction(overrideText: questionText);
  }

  // =============================
  // Text -> wav
  // =============================
  Future<void> textToWav(String text, int index) async {
    if (files.containsKey(index)) {
      if (audioplayer.playing) {
        await audioplayer.stop();
      } else {
        await audioplayer.setFilePath(files[index]!.path);
        await audioplayer.play();
      }
      return;
    }

    final result = await _provider.textToWav(
      WAV_TOTEXT_POST,
      text: text,
    );
    if (result.body?.code != "success" || result.body?.data == null) return;

    Uint8List bytes = base64.decode(result.body!.data!);
    final dir = (await getApplicationDocumentsDirectory()).path;
    final filePath = '$dir/$_dir/$index$_ext';

    final f = File(filePath);
    if (!await f.exists()) await f.create(recursive: true);
    await f.writeAsBytes(bytes);
    files[index] = f;

    await audioplayer.setFilePath(filePath);
    await audioplayer.play();
  }

  /// 點贊案例
  Future<bool> likeCase(ReplyCase replyCase, String inquiryId) async {
    final result = await _provider.caseLike(API_CASE_LIKE,
        inquiryId: inquiryId,
        caseTitle: replyCase.title ?? "",
        caseUrl: replyCase.url ?? "",
        caseSource: replyCase.source ?? "");
    if (result.body?.code == "success" &&
        result.body?.data?["is_liked"] is bool) {
      return result.body?.data?["is_liked"];
    }
    return false;
  }
}

// =============================
// Models（一定要在最外層）
// =============================
class ChatMessage {
  String data;
  String? question;
  String? inquiryId;
  bool isMe;
  bool isAnswering;
  List<ReplyMessage>? replyList;
  List<XFile>? images;

  /// 2026/01/27 version
  String? sessionId;
  List<ReplyCase>? internal;
  List<ReplyCase>? external;
  bool isFinished;
  RxBool isExpanded = false.obs;

  ChatMessage({
    required this.data,
    required this.isMe,
    this.question,
    this.inquiryId,
    this.isAnswering = false,
    this.isFinished = false,
    this.images,
    this.replyList,
  });
}

class ReplyMessage {
  String? title;
  String? comment;
  bool isExpanded;
  List<String> imageUrls;

  ReplyMessage({
    this.title,
    this.comment,
    this.isExpanded = false,
    List<String>? imageUrls,
  }) : imageUrls = imageUrls ?? [];
}

class ReplyCase {
  String? caseId;
  String? title;
  String? url;
  String? source;
  RxBool? isLiked;

  ReplyCase({
    this.caseId,
    this.title,
    this.url,
    this.source,
    this.isLiked,
  });

  factory ReplyCase.fromJson(Map<String, dynamic> json) => ReplyCase(
        caseId: json["case_id"],
        title: json["title"],
        url: json["url"],
        source: json["source"],
        isLiked:
            json["is_liked"] is bool ? RxBool(json["is_liked"]) : false.obs,
      );
}
