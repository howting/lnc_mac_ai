import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class OssSignature {
  final String uploadUrl;
  final String objectKey;
  final String? accessUrl;
  final Map<String, String> headers;

  OssSignature({
    required this.uploadUrl,
    required this.objectKey,
    this.accessUrl,
    this.headers = const {},
  });

  factory OssSignature.fromJson(Map<String, dynamic> json) {
    return OssSignature(
      uploadUrl: json['upload_url'],
      objectKey: json['object_key'],
      accessUrl: json['access_url'],
      headers: (json['headers'] is Map)
          ? Map<String, String>.from(json['headers'])
          : const {},
    );
  }
}

class OssUploader {
  final String signatureEndpoint;

  OssUploader(this.signatureEndpoint);

  /// 获取 OSS 上传签名
  Future<OssSignature> getSignature(String filename) async {
    final uri = Uri.parse(signatureEndpoint)
        .replace(queryParameters: {'filename': filename});

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('获取签名失败：${res.statusCode}');
    }

    final body = jsonDecode(res.body);
    if (body['code'] != 200) {
      throw Exception(body['message'] ?? '签名接口错误');
    }

    return OssSignature.fromJson(body['data']);
  }

  /// PUT 上传（一次性 bytes，100% 兼容）
  Future<OssSignature> uploadXFile(XFile file, String filename) async {
    final sign = await getSignature(filename);

    final contentType =
        lookupMimeType(file.path) ?? 'application/octet-stream';

    final bytes = await File(file.path).readAsBytes();

    final req = http.Request('PUT', Uri.parse(sign.uploadUrl));

    req.headers.addAll(sign.headers);
    req.headers['Content-Type'] = contentType;
    req.headers['Content-Length'] = bytes.length.toString();

    req.bodyBytes = bytes;

    final client = http.Client();
    final resp = await client.send(req);
    client.close();

    if (resp.statusCode != 200 && resp.statusCode != 204) {
      final err = await resp.stream.bytesToString();
      throw Exception('OSS 上传失败 ${resp.statusCode}: $err');
    }

    return sign;
  }
}