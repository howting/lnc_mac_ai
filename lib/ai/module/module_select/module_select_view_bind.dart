import 'package:get/get.dart';
import 'package:lncmacai/ai/module/module_select/module_select_view_controller.dart';
import 'package:lncmacai/ai/module/module_select/module_select_view_provider.dart';

class ModuleSelectViewBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ModuleSelectViewController(Get.find()));
    Get.lazyPut(() => ModuleSelectViewProvider());
  }
}
