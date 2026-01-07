import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lncmacai/ai/routes/app_pages.dart';
import 'package:lncmacai/global.dart';
import 'package:lncmacai/providers/recorn.dart';



class ModuleSelectView extends StatefulWidget {
  const ModuleSelectView({super.key});

  @override
  State<ModuleSelectView> createState() => _ModuleSelectViewState();
}

class _ModuleSelectViewState extends State<ModuleSelectView> {
  // RegExp: ip address regx
  RegExp ipExp = RegExp(
      r"^(?!0)(?!.*\.$)((1?\d?\d|25[0-5]|2[0-4]\d)(\.|$)){4}$",
      caseSensitive: false,
      multiLine: false);
  TextEditingController textCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

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
                onTap: () => Get.toNamed(Routes.BOARD),
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
                        Icon(Icons.support_agent, color: Color(0xFF00ABB3),
                            size: 33),
                        SizedBox(height: 10),
                        Text(
                          "LNCMac AI Home",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18,
                              fontWeight: FontWeight.w600),
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
}