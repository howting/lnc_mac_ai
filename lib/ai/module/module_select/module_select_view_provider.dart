import 'package:get/get.dart';
import 'package:lncmacai/ai/base/base_provider.dart';
import 'package:lncmacai/ai/base/base_response.dart';
import 'package:lncmacai/global.dart';

class ModuleSelectViewProvider extends BaseProvider {
  Future<Response<MapMessageResponse>> createWorkOrder(
    String path, {
    required String promotionUserName,
    required String promotionUserPhone,
    required String remark,
  }) async {
    final result = await post(
      path,
      {
        "employee_id": Global.profile.employeeId,
        "promotion_user_name": promotionUserName,
        "promotion_user_phone": promotionUserPhone,
        "remark": remark,
      },
      decoder: (data) => MapMessageResponse.fromJson(data),
    );
    return result;
  }
}
