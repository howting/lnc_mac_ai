import 'package:get/get.dart';
import 'package:lncmacai/ai/base/base_list_controller.dart';
import 'package:lncmacai/ai/const_api.dart';
import 'package:lncmacai/ai/const_values.dart';
import 'package:lncmacai/ai/module/login/login_controller.dart';
import 'package:lncmacai/ai/module/login/login_provider.dart';
import 'package:lncmacai/ai/module/profile/profile_model.dart';
import 'package:lncmacai/ai/module/profile/profile_provider.dart';
import 'package:lncmacai/ai/utils/storage.dart';
import 'package:lncmacai/global.dart';

class ProfileController extends BaseListController<WorkOrderModel> {
  final ProfileProvider _provider;
  ProfileController(this._provider);

  ProfileModel profile = ProfileModel();
  List<HistoryQuestionModel> historyQuestions = [];

  @override
  void onInit() {
    super.onInit();
    profile = Global.profile;
  }

  @override
  Future<List<WorkOrderModel>> loadDataWithIndex({int index = 1}) async {
    var result =
        await _provider.getWorkOrderList(API_WORK_ORDER_LIST, pageIndex: index);
    if (result.body?.data != null) {
      pageCount = result.body?.data?['pagination']['total_pages'];
      return (result.body?.data?['work_orders'] as List)
          .map((e) => WorkOrderModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<void> logout() async {
    await LocalStorage().remove(STORAGE_USER_PROFILE_KEY);
    Get.lazyPut(() => LoginController(Get.find()));
    Get.lazyPut(() => LoginProvider());
    Get.offAndToNamed('/login');
  }
}
