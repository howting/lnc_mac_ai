import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lncmacai/ai/const_api.dart';
import 'package:lncmacai/ai/module/module_select/module_select_view_provider.dart';
import 'package:lncmacai/ai/routes/app_pages.dart';

class ModuleSelectViewController extends GetxController {
  ModuleSelectViewController(this._provider);
  final ModuleSelectViewProvider _provider;

  // RegExp: ip address regx
  RegExp ipExp = RegExp(
      r"^(?!0)(?!.*\.$)((1?\d?\d|25[0-5]|2[0-4]\d)(\.|$)){4}$",
      caseSensitive: false,
      multiLine: false);

  /// work-order
  TextEditingController customerNameCtl = TextEditingController();
  TextEditingController customerMobieCtl = TextEditingController();
  TextEditingController remarkCtl = TextEditingController();

  Future<void> submitOrderAction() async {
    if (customerNameCtl.text.isEmpty || customerNameCtl.text == "") {
      Fluttertoast.showToast(msg: "請輸入客戶名稱", gravity: ToastGravity.CENTER);
      return;
    }
    if (customerMobieCtl.text.isEmpty || customerMobieCtl.text == "") {
      Fluttertoast.showToast(msg: "請輸入客戶手機號", gravity: ToastGravity.CENTER);
      return;
    }
    if (remarkCtl.text.isEmpty || remarkCtl.text == "") {
      Fluttertoast.showToast(msg: "請輸入備註", gravity: ToastGravity.CENTER);
      return;
    }
    Get.back();

    EasyLoading.show(status: '工單生成中...', dismissOnTap: true);
    final result = await _provider.createWorkOrder(API_WORK_ORDER_CREATE,
        promotionUserName: customerNameCtl.text,
        promotionUserPhone: customerMobieCtl.text,
        remark: remarkCtl.text);
    EasyLoading.dismiss();
    if (result.body?.code == "success" && result.body?.data != null) {
      final workOrderId =
          (result.body!.data!["work_order_id"] ?? "").toString();
      Get.toNamed(Routes.BOARD, arguments: {"workOrderId": workOrderId});
    }

    customerNameCtl.clear();
    customerMobieCtl.clear();
    remarkCtl.clear();
  }
}
