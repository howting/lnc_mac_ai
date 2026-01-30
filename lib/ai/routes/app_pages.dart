import 'package:get/get.dart';
import 'package:lncmacai/ai/module/boardrecommend/boardrecommendchat_bind.dart';
import 'package:lncmacai/ai/module/boardrecommend/boardrecommendchat_page.dart';
import 'package:lncmacai/ai/module/login/login_page.dart';
import 'package:lncmacai/ai/module/module_select/module_select_view.dart';
import 'package:lncmacai/ai/module/module_select/module_select_view_bind.dart';
import 'package:lncmacai/ai/module/profile/profile_bind.dart';
import 'package:lncmacai/ai/module/profile/profile_page.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Paths.LOGIN, page: () => LoginPage()),
    GetPage(
        name: Paths.BOARD,
        page: () => boardrecommendChatPage(),
        binding: boardrecommendChatBind()),
    GetPage(
        name: Paths.MODULE_SELECT,
        page: () => ModuleSelectView(),
        binding: ModuleSelectViewBind()),
    GetPage(
        name: Paths.PROFILE, page: () => ProfilePage(), binding: ProfileBind()),
//  GetPage(
//      name: Paths.MACHINE_CHAT,
//      page: () => MachineChatPage(),
//      binding: MachineChatBind()),
//  GetPage(
//    name: Paths.MANUAL_CHAT,
//    page: () => ManualChatPage(),
//    binding: ManualChatBind(),
//  ),
//  GetPage(
//    name: Paths.SHOUFU_CHAT,
//    page: () => ShoufuChatPage(),
//    binding: ShoufuChatBind(),
//  ),
//  GetPage(name: Paths.MAH_HOME, page: () => const MainLayout(), children: [
//    GetPage(
//        name: Paths.CREATE_IP,
//        page: () => const CreateMahcineIP(),
//        children: [
//          GetPage(
//              name: Paths.CREATE_NAME,
//              page: () => CreateMachineName(
//                    ip: Get.arguments['ip'],
//                  ),
//              children: [
//                GetPage(
//                    name: Paths.CREATE_DONE,
//                    page: () => const CreateMachineDone()),
//              ]),
//        ]),
//  ]),
//  GetPage(
//      name: Paths.MAH_MACHINE_MAIN,
//      page: () => MachineMainScreen(
//            ip: Get.arguments['ip'],
//            machineName: Get.arguments['machineName'],
//          )),
//  GetPage(
//      name: Paths.MAH_MACHINE_DETECT, page: () => const MachineScanScreen()),
  ];
}
