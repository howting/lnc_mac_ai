import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lncmacai/ai/module/module_select/module_select_view_controller.dart';
import 'package:lncmacai/global.dart';
import 'package:lncmacai/providers/recorn.dart';

class ModuleSelectView extends GetView<ModuleSelectViewController> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 可选：退出前清理
        Global.recorn.clearTestingConnection();
        Global.recorn.disconnect();
        Global.recorn.cleanIsolate();
        return true; // 允许系统执行返回（在根路由上=退出App）
      },
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 80.h),

            // AI售服
            Expanded(
              child: GestureDetector(
                onTap: () => Get.dialog(workOrderDialog()),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.3),
                          offset: const Offset(1.5, 3),
                          blurRadius: 5,
                          spreadRadius: 0.0,
                        )
                      ],
                      border: Border.all(width: .2, color: Colors.transparent),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.support_agent,
                            color: Color(0xFF00ABB3), size: 33),
                        SizedBox(height: 10),
                        Text(
                          "LNCMac AI Home",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  /// 创建工单dialog
  Widget workOrderDialog() {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          height: Get.height,
          width: Get.width,
          color: Colors.transparent,
          child: Column(
            children: [
              SizedBox(height: Get.height * .12),
              GestureDetector(
                onTap: () =>
                    FocusScope.of(Get.context!).requestFocus(FocusNode()),
                child: Container(
                  height: Get.height * .65,
                  width: Get.width - 60,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("客戶名稱",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.black)),
                      ExtendedTextField(
                        controller: controller.customerNameCtl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '客戶名稱',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 211, 210, 210))),
                      ),
                      const SizedBox(height: 25),
                      const Text("客戶手機號",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.black)),
                      ExtendedTextField(
                        controller: controller.customerMobieCtl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '客戶手機號',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 211, 210, 210))),
                      ),
                      const SizedBox(height: 25),
                      const Text("備註",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.black)),
                      ExtendedTextField(
                        controller: controller.remarkCtl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '備註',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 211, 210, 210))),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.white),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              child: const Text("取消",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                      color: Colors.black)),
                              onPressed: () => Get.back()),
                          const SizedBox(width: 16),
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      const Color(0xFF00ABB3)),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              child: const Text("確定",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                      color: Colors.white)),
                              onPressed: () => controller.submitOrderAction()),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
