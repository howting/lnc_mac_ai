import 'dart:io';

import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lncmacai/ai/module/voice_record/customer_chat_voice_record_bar.dart';
import 'package:lncmacai/ai/module/voice_record/customer_chat_voice_record_layout.dart';
import 'package:lncmacai/ai/routes/app_pages.dart';
import 'package:lncmacai/widgets/inapp_webview_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import 'boardrecommendchat_controller.dart';

class boardrecommendChatPage extends GetView<boardrecommendChatController> {
  @override
  Widget build(BuildContext context) {
    return CustomerChatVoiceRecordLayout(
      onCompleted: (sec, path) {
        // 不在這裡判斷時間長短，交給 controller 做
        print("onCompleted: $sec, $path");
        controller.handleVoiceFile(path, durationSec: sec);
      },
      builder: (bar) => GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: AnimatedContainer(
          duration: Duration.zero,
          height: MediaQuery.of(context).viewInsets.bottom > 0
              ? Get.height - MediaQuery.of(context).viewInsets.bottom
              : Get.height,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(),
            body: Column(
              children: [
                Expanded(
                  child: ObxValue<RxList>(
                    (list) => controller.chatMessageList.isEmpty
                        ? _buildEmptyHint()
                        : _buildChatList(),
                    controller.chatMessageList,
                  ),
                ),
                buildImagePreviewBar(),
                buttonRow(bar),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= AppBar =================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: 50.h,
            width: 90.w,
            child: Image.asset(
              "assets/images/aisalelogo.png",
            ),
          ),
          Expanded(
            child: Text(
              "LNCMac AI Home",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: () => Get.toNamed(Routes.PROFILE),
            child: const Icon(
              Icons.person,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ================= 主畫面 =================

  Widget _buildEmptyHint() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      margin: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        "想要哪種類型家居設計風格",
        style: TextStyle(
          color: Colors.black26,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return Container(
      padding: EdgeInsets.only(top: 12.h),
      margin: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListView.builder(
        itemCount: controller.chatMessageList.length,
        itemBuilder: (_, index) {
          final message = controller.chatMessageList[index];
          return message.isMe
              ? rightbubble(message)
              : leftbubble(
                  message,
                  index,
                  isAnswering: message.isAnswering,
                );
        },
      ),
    );
  }

  // ================= Bubble =================

  Widget leftbubble(
    ChatMessage message,
    int index, {
    bool isAnswering = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: Get.width * 0.8,
                minWidth: 40.w,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 8.h,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: (isAnswering &&
                        (message.data.trim().isEmpty || message.data == "生成中…"))
                    ? _buildTyping()
                    : _buildMessageBody(message),
              ),
            ),
          ],
        ),
        _buildTtsButton(message, index, isAnswering),
      ],
    );
  }

  // Widget rightbubble(String text) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.end,
  //     children: [
  //       Container(
  //         constraints: BoxConstraints(maxWidth: Get.width * 0.7),
  //         margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
  //         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
  //         decoration: const BoxDecoration(
  //           color: Color(0xFFDFF5E1),
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(15),
  //             bottomLeft: Radius.circular(15),
  //             bottomRight: Radius.circular(15),
  //           ),
  //         ),
  //         child: Text(text, style: const TextStyle(fontSize: 16)),
  //       ),
  //     ],
  //   );
  // }

  Widget rightbubble(ChatMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 1. 文字氣泡
        if (message.data.isNotEmpty && message.data != "(圖片消息)")
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: Get.width * 0.7),
                padding: EdgeInsets.all(10.h),
                margin: EdgeInsets.only(right: 12.w, bottom: 4.h),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(message.data,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              ),
            ],
          ),

        // 2. 圖片預覽 (緊跟在文字下方)
        if (message.images != null && message.images!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(right: 12.w, bottom: 8.h),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: message.images!.map((xfile) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(xfile.path),
                    width: 120.w,
                    height: 120.w,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  final RegExp _urlRegex = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);

  String? _extractFirstUrl(String text) {
    final m = _urlRegex.firstMatch(text);
    return m?.group(0);
  }

  Widget _buildMaybeImage(ChatMessage message) {
    return GestureDetector(
      onLongPress: () async {
        final url = _extractFirstUrl(message.data);
        if (url == null) return;

        final ctx = Get.context;
        if (ctx == null) return;

        final action = await showModalBottomSheet<String>(
          context: ctx,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.open_in_browser),
                  title: const Text("在浏览器打开"),
                  onTap: () => Navigator.pop(context, "open"),
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text("复制链接"),
                  onTap: () => Navigator.pop(context, "copy"),
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text("取消"),
                  onTap: () => Navigator.pop(context, "cancel"),
                ),
              ],
            ),
          ),
        );

        if (action == "open") {
          final uri = Uri.tryParse(url);
          if (uri != null) {
            final ok =
                await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (!ok) Fluttertoast.showToast(msg: "无法打开链接");
          }
        } else if (action == "copy") {
          await Clipboard.setData(ClipboardData(text: url));
          Fluttertoast.showToast(msg: "已复制链接");
        }
      },
      // child: Text(text, style: const TextStyle(fontSize: 16)),
      child: Column(
        children: [
          Markdown(
            shrinkWrap: true,
            onTapLink: (text, href, title) {
              print("$text , $href , $title ");
              Get.to(() => InappWebviewWidget(text));
            },
            physics: const NeverScrollableScrollPhysics(),
            data: message.data,
          ),
        ],
      ),
    );
  }

  Widget buildCasePanel(ChatMessage message) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (message.internal != null && message.internal!.isNotEmpty)
        ...message.internal!.map((replyCase) {
          InlineSpan span = TextSpan(children: [
            TextSpan(
                text: "${replyCase.title} : ",
                style: const TextStyle(color: Colors.black)),
            TextSpan(
                text: replyCase.url,
                recognizer: TapGestureRecognizer()
                  ..onTap = () =>
                      Get.to(() => InappWebviewWidget(replyCase.url ?? "")),
                style: const TextStyle(
                  color: Colors.blue,
                )),
          ]);
          return Row(
            children: [
              Expanded(child: Text.rich(span)),
              const SizedBox(width: 10.0),
              ObxValue<RxBool>(
                  (like) => InkWell(
                        onTap: () async {
                          final result = await controller.likeCase(
                              replyCase, message.inquiryId ?? "");
                          replyCase.isLiked!(result);
                        },
                        child: Icon(Icons.thumb_up,
                            color: replyCase.isLiked!.value
                                ? Colors.red
                                : Colors.grey,
                            size: 16),
                      ),
                  replyCase.isLiked!),
              const SizedBox(width: 5.0),
            ],
          );
        }).toList()
      else
        const Text("暫無更多模板"),
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 5.0, bottom: 10.0),
          child: InkWell(
            onTap: () => message.isExpanded.toggle(),
            child: const Text("展開更多",
                style: TextStyle(
                  color: Colors.blue,
                )),
          ),
        ),
      ),
      ObxValue<RxBool>((expanded) {
        return Offstage(
          offstage: !expanded.value,
          child: (message.external != null && message.external!.isNotEmpty)
              ? Column(
                  children: message.external!.map((replyCase) {
                    InlineSpan span = TextSpan(children: [
                      TextSpan(
                          text: "${replyCase.title} : ",
                          style: const TextStyle(color: Colors.black)),
                      TextSpan(
                          text: replyCase.url,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Get.to(
                                () => InappWebviewWidget(replyCase.url ?? "")),
                          style: const TextStyle(
                            color: Colors.blue,
                          )),
                    ]);
                    return Row(
                      children: [
                        Expanded(child: Text.rich(span)),
                        const SizedBox(width: 10.0),
                        ObxValue<RxBool>(
                            (like) => InkWell(
                                  onTap: () async {
                                    final result = await controller.likeCase(
                                        replyCase, message.inquiryId ?? "");
                                    replyCase.isLiked!(result);
                                  },
                                  child: Icon(Icons.thumb_up,
                                      color: replyCase.isLiked!.value
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 16),
                                ),
                            replyCase.isLiked!),
                        const SizedBox(width: 5.0),
                      ],
                    );
                  }).toList(),
                )
              : const Text("暫無更多外部模板"),
        );
      }, message.isExpanded)
    ]);
  }

  Widget buildPanel(List<ReplyMessage> replies, String question) {
    // 先做最小版本：把 title/comment 列出
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: replies.map((r) {
        final title = (r.title ?? "").trim();
        final comment = (r.comment ?? "").trim();
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              if (comment.isNotEmpty) Text(comment),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTyping() {
    return const Row(
      key: ValueKey('typing'),
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 8),
        Text('生成中…', style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildMessageBody(ChatMessage message) {
    if (message.isFinished) {
      return buildCasePanel(message);
    }
    if (message.replyList == null) {
      return KeyedSubtree(
        key: const ValueKey('text_body'),
        child: _buildMaybeImage(message),
      );
    }

    return SingleChildScrollView(
      key: const ValueKey('panel_body'),
      child: buildPanel(
        message.replyList!,
        (message.question?.trim().isNotEmpty ?? false)
            ? message.question!
            : controller.lastUserQuestion.value,
      ),
    );
  }

  Widget _buildTtsButton(
    ChatMessage message,
    int index,
    bool isAnswering,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, bottom: 6.h),
      child: ObxValue<RxMap>(
        (_) => Offstage(
          offstage: isAnswering,
          child: InkWell(
            onTap: () => controller.textToWav(
              message.data,
              index,
            ),
            child: controller.files.containsKey(index)
                ? const Icon(
                    Icons.play_circle,
                    color: Colors.brown,
                  )
                : const Icon(
                    Icons.download_for_offline,
                    color: Colors.brown,
                  ),
          ),
        ),
        controller.files,
      ),
    );
  }

  Widget buildImagePreviewBar() {
    return Obx(() {
      if (controller.selectedImages.isEmpty) return const SizedBox.shrink();
      return Container(
        height: 90.h,
        width: Get.width,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.selectedImages.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 12.w, top: 8.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(controller.selectedImages[index].path),
                      width: 70.h,
                      height: 70.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // 右上角刪除按鈕
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      controller.selectedImages.removeAt(index);
                      if (index < controller.ossImageKeys.length) {
                        controller.ossImageKeys.removeAt(index);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  // ================= Input Bar =================

  Widget buttonRow(CustomerChatVoiceRecordBar bar) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 16.w,
      ),
      height: 55.h,
      child: Row(
        children: [
          Expanded(child: inputWidget()),
          sendButton(),
          addButton(),
          bar,
          cameraButton(),
        ],
      ),
    );
  }

  Widget inputWidget() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(22.5),
      ),
      child: ExtendedTextField(
        controller: controller.textController,
        focusNode: controller.textFocusNode,
        minLines: 1,
        maxLines: 4,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "输入你的消息...",
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget sendButton() => _iconButton(
        Icons.near_me,
        controller.sendAction,
      );

  Widget addButton() => _iconButton(
        Icons.add,
        () => Fluttertoast.showToast(msg: "功能开发中"),
      );

  Widget _iconButton(
    IconData icon,
    VoidCallback onTap, {
    bool alwaysEnabled = false,
  }) {
    return InkWell(
      onTap: () => (alwaysEnabled || controller.canSend.value) ? onTap() : null,
      child: Container(
        height: 36.h,
        width: 36.h,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          color: const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(36.h),
        ),
        child: Icon(icon, color: Colors.brown, size: 20),
      ),
    );
  }

  Widget cameraButton() => _iconButton(
        Icons.photo_camera,
        () async {
          final ctx = Get.context;
          if (ctx == null) return;

          final source = await showModalBottomSheet<ImageSource>(
            context: ctx,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text("拍照"),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text("相册"),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ),
          );

          if (source == null) return;

          await controller.pickImage(source: source);
          // if (controller.ossImageKeys.isNotEmpty) {
          //   await controller.sendAction();
          // }
        },
        alwaysEnabled: true,
      );

// ================= Helper =================
// 下面 image / url / panel helper
//（你原本邏輯已經很完整，僅排版，未改）
}
