import 'package:get/get.dart';
import 'package:lncmacai/ai/base/base_provider.dart';
import 'package:lncmacai/ai/base/base_response.dart';
import 'package:lncmacai/global.dart';

class ProfileProvider extends BaseProvider {
  Future<Response<MapResponse>> getProfile(
    String path, {
    required String? employeeid,
  }) async {
    final result = await post(
      path,
      {
        "employeeId": employeeid,
      },
      decoder: (data) => MapResponse.fromJson(data),
    );
    return result;
  }

  Future<Response<MapResponse>> getWorkOrderList(String path,
      {required int pageIndex}) async {
    final result = await get(
      path,
      query: {
        "employee_id": Global.profile.employeeId,
        "page": pageIndex.toString(),
        "page_size": "10",
        "case_page": "1",
        "case_page_size": "30",
      },
      decoder: (data) => MapResponse.fromJson(data),
    );
    return result;
  }
}
