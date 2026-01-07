import 'package:get/get.dart';
import 'package:lncmacai/ai/base/base_provider.dart';
import 'package:lncmacai/ai/base/base_response.dart';

class LoginProvider extends BaseProvider {
  Future<Response<MapResponse>> login(String path,
      {required String? employeeid, required String? password}) async {
    final result = await post(
      path,
      {
        "employee_id": employeeid,
        "password": password,
      },
      decoder: (data) => MapResponse.fromJson(data),
    );
    return result;
  }
}
