import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:lncmacai/ai/base/base_response.dart';
import 'package:lncmacai/ai/base/base_provider.dart';
import 'package:lncmacai/global.dart';
import 'dart:convert';

class boardrecommendChatProvider extends BaseProvider {
  Future<Response<MapResponse>> qwenBoard(
    String url, {
    required String text,
    List<String> imageKeys = const [],
  }) {
    return post<MapResponse>(
      url,
      {
        "employeeId": Global.profile.employeeId,
        "input_value": text,
        if (imageKeys.isNotEmpty) "base64Images": imageKeys,
      },
      contentType: "application/json",
      decoder: (obj) {
        // GetConnect 有時候會把 JSON 當 Map，有時候當 String
        if (obj == null) {
          return MapResponse.fromJson({
            "code": "error",
            "message": "Empty response",
            "data": null,
          });
        }

        if (obj is String) {
          return MapResponse.fromJson(jsonDecode(obj) as Map<String, dynamic>);
        }

        if (obj is Map) {
          return MapResponse.fromJson(Map<String, dynamic>.from(obj));
        }

        return MapResponse.fromJson({
          "code": "error",
          "message": "Invalid response type: ${obj.runtimeType}",
          "data": null,
        });
      },
    );
  }

  Future<Response<BaseWavResponse>> wav2text(
      String path, List<int> data, String filename) async {
    final audio = MultipartFile(data, filename: filename);
    final result = await post(
      path,
      FormData({
        'audio': audio,
        "employeeId": Global.profile.employeeId,
        "images": [],
        "board_app": "true",
      }),
      decoder: (data) => BaseWavResponse.fromJson(data),
    );
    return result;
  }

  Future<Response<BasefeedResponse>> modifyReply(
      String path, Map<String, dynamic> data) async {
    final result = await post(
      path,
      data,
      decoder: (data) => BasefeedResponse.fromJson(data),
    );
    return result;
  }

  /// 按讚意見回饋
  Future<Response<BasefeedResponse>> likeReply(
      String path, Map<String, dynamic> data) async {
    final result = await post(
      path,
      data,
      decoder: (json) => BasefeedResponse.fromJson(json),
    );
    return result;
  }

  Future<Response<BaseResponse>> textToWav(String path,
      {required String? text}) async {
    final result = await post(
      path,
      {
        "input_value": text,
      },
      decoder: (data) => BaseResponse.fromJson(data),
    );
    return result;
  }

  Future<Response<MapMessageResponse>> caseLike(
    String path, {
    required String inquiryId,
    required String caseTitle,
    required String caseUrl,
    required String caseSource,
  }) async {
    final result = await post(
      path,
      {
        "employee_id": Global.profile.employeeId,
        "inquiry_id": inquiryId,
        "case_title": caseTitle,
        "case_url": caseUrl,
        "case_source": caseSource,
      },
      decoder: (data) => MapMessageResponse.fromJson(data),
    );
    return result;
  }
}
