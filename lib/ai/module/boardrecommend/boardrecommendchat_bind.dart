import 'package:get/get.dart';
import 'package:lncmacai/ai/module/boardrecommend/boardrecommendchat_controller.dart';
import 'package:lncmacai/ai/module/boardrecommend/boardrecommendchat_provider.dart';

class boardrecommendChatBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => boardrecommendChatController(Get.find()));
    Get.lazyPut(() => boardrecommendChatProvider());
  }
}
