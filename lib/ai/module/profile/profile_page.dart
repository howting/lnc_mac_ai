import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lncmacai/ai/base/base_appbar_view.dart';
import 'package:lncmacai/ai/module/profile/profile_controller.dart';
import 'package:lncmacai/ai/module/profile/profile_model.dart';
import 'package:lncmacai/widgets/inapp_webview_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfilePage extends BaseAppBarView<ProfileController> {
  @override
  Widget body(BuildContext context) {
    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: buildProfile(),
            )
          ];
        },
        body: controller.obx(
            (state) => SmartRefresher(
                  controller: controller.refreshCtl,
                  onRefresh: controller.onRefresh,
                  onLoading: controller.onLoading,
                  enablePullUp: true,
                  header: const WaterDropMaterialHeader(
                      backgroundColor: Color(0xFF00ABB3)),
                  footer: CustomFooter(
                    loadStyle: LoadStyle.ShowWhenLoading,
                    builder: (BuildContext context, LoadStatus? mode) {
                      if (mode == LoadStatus.noMore) {
                        return const SizedBox(
                          height: 60.0,
                          child: Center(
                              child: Text(
                            '沒有更多數據啦。',
                            style: TextStyle(color: Color(0xFFB2B2B2)),
                          )),
                        );
                      }
                      return const SizedBox(
                        height: 55.0,
                        child: Center(child: CupertinoActivityIndicator()),
                      );
                    },
                  ),
                  child: ListView.builder(
                    itemCount: controller.data.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return buildWorkOrderList(controller.data[index]);
                    },
                  ),
                ),
            onLoading: const Center(child: CupertinoActivityIndicator())));
  }

  Widget buildProfile() {
    return Container(
      width: Get.width - 40.w,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      padding: EdgeInsets.symmetric(vertical: 19.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          rowTextWidget("用戶名 : ", controller.profile.userName),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () => Get.defaultDialog(
              titlePadding: const EdgeInsets.all(12.0),
              titleStyle: TextStyle(fontSize: 19.sp),
              middleTextStyle: TextStyle(fontSize: 16.sp),
              title: "確定要退出當前賬號嗎?",
              middleText: "",
              onConfirm: () async => controller.logout(),
              onCancel: () {},
              cancelTextColor: Colors.black,
              confirmTextColor: Colors.white,
            ),
            child: Container(
              height: 45.h,
              width: Get.width - 64.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "退出賬號",
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget rowTextWidget(String leftText, String? rightText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(children: [
        Text(
          leftText,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        Text(
          rightText ?? "",
          maxLines: 3,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp),
        )
      ]),
    );
  }

  Widget buildWorkOrderList(WorkOrderModel workOrder) {
    return InkWell(
      onTap: () => Get.dialog(checkLikedCaseDialog(
          workOrder.internal ?? [], workOrder.external ?? [])),
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichText(
              // maxLines: 20,
              text: TextSpan(
                text: "姓名: ",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: workOrder.promotionUserName ?? "",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9.h),
            RichText(
              // maxLines: 20,
              text: TextSpan(
                text: "手機號: ",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: workOrder.promotionUserPhone ?? "",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9.h),
            RichText(
              maxLines: 2,
              text: TextSpan(
                text: "創建時間: ",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: workOrder.createdAt ?? "",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9.h),
            RichText(
              maxLines: 2,
              text: TextSpan(
                text: "備註: ",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: workOrder.remark ?? "",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9.h),
            RichText(
              maxLines: 2,
              text: TextSpan(
                text: "工單處理狀態: ",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: workOrder.statusDisplay ?? "",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ])),
    );
  }

  /// 查看收藏案例 dialog
  Widget checkLikedCaseDialog(
      List<LikedCase> internalLikedCases, List<LikedCase> externalLikedCases) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          height: Get.height,
          width: Get.width,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Container(
            height: Get.height * .8,
            width: Get.width - 60,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    if (internalLikedCases.isNotEmpty)
                      Text(
                        '內部案例(${internalLikedCases.length})',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    if (internalLikedCases.isNotEmpty)
                      ...internalLikedCases.map((likedcase) {
                        return InkWell(
                          onTap: () => Get.to(() =>
                              InappWebviewWidget(likedcase.caseUrl ?? "")),
                          child: caseItem(likedcase, true),
                        );
                      }).toList(),
                    const SizedBox(height: 20),
                    if (externalLikedCases.isNotEmpty)
                      Text(
                        '外部案例(${externalLikedCases.length})',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    if (externalLikedCases.isNotEmpty)
                      ...externalLikedCases.map((likedcase) {
                        return InkWell(
                          onTap: () => Get.to(() =>
                              InappWebviewWidget(likedcase.caseUrl ?? "")),
                          child: caseItem(likedcase, false),
                        );
                      }).toList(),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget caseItem(LikedCase likecase, bool isInternal) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.link,
            color: isInternal ? Colors.blueAccent : Colors.greenAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                likecase.caseTitle ?? "",
                style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
              ),
              const SizedBox(
                height: 2.0,
              ),
              Text(
                "點贊時間: ${likecase.likedAt ?? ""}",
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ))
        ],
      ),
    );
  }

  @override
  String get title => "个人中心";
}
