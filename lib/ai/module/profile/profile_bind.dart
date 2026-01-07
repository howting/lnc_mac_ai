import 'package:get/get.dart';
import 'package:lncmacai/ai/module/profile/profile_controller.dart';
import 'package:lncmacai/ai/module/profile/profile_provider.dart';

class ProfileBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController(Get.find()));
    Get.lazyPut(() => ProfileProvider());
  }
}
