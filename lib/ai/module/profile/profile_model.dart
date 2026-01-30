import 'package:lncmacai/ai/module/boardrecommend/boardrecommendchat_controller.dart';

class ProfileModel {
  String? employeeId;
  String? userName;
  String? phoneNumber;
  int? onlineDuration;
  String? lastLoginTime;
  int? dailyTickets;
  int? monthlyTickets;
  int? yearlyTickets;

  ProfileModel(
      {this.employeeId,
      this.userName,
      this.phoneNumber,
      this.onlineDuration,
      this.lastLoginTime,
      this.dailyTickets,
      this.monthlyTickets,
      this.yearlyTickets});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    employeeId = json['employee_id'];
    userName = json['user_name'];
    phoneNumber = json['phone_number'];
    onlineDuration = json['online_duration'];
    lastLoginTime = json['last_login_time'];
    dailyTickets = json['daily_tickets'];
    monthlyTickets = json['monthly_tickets'];
    yearlyTickets = json['yearly_tickets'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['employee_id'] = employeeId;
    data['user_name'] = userName;
    data['phone_number'] = phoneNumber;
    data['online_duration'] = onlineDuration;
    data['last_login_time'] = lastLoginTime;
    data['daily_tickets'] = dailyTickets;
    data['monthly_tickets'] = monthlyTickets;
    data['yearly_tickets'] = yearlyTickets;
    return data;
  }
}

class HistoryQuestionModel {
  String? questionContent;
  String? replyContent;
  String? questionTime;
  String? replyStatus;
  bool? isLiked;
  bool? isEdited;
  bool? isPlayed;
  String? inquiryMethod;
  String? selectedMachine;
  String? selectedModel;
  String? inquiry;

  HistoryQuestionModel(
      {this.questionContent,
      this.replyContent,
      this.questionTime,
      this.replyStatus,
      this.isLiked,
      this.isEdited,
      this.isPlayed,
      this.inquiryMethod,
      this.selectedMachine,
      this.selectedModel,
      this.inquiry});

  HistoryQuestionModel.fromJson(Map<String, dynamic> json) {
    questionContent = json['question_content'];
    replyContent = json['reply_content'];
    questionTime = json['question_time'];
    replyStatus = json['reply_status'];
    isLiked = json['is_liked'];
    isEdited = json['is_edited'];
    isPlayed = json['is_played'];
    inquiryMethod = json['inquiry_method'];
    selectedMachine = json['selected_machine'];
    selectedModel = json['selected_model'];
    inquiry = json['inquiry'];
  }
}

class WorkOrderModel {
  String? workOrderId;
  String? adminEmployeeId;
  String? adminUsername;
  String? promotionUserName;
  String? promotionUserPhone;
  String? status;
  String? statusDisplay;
  String? createdAt;
  String? completedAt;
  int? totalCases;
  String? remark;
  List<LikedCase>? internal;
  List<LikedCase>? external;

  WorkOrderModel({
    this.workOrderId,
    this.adminEmployeeId,
    this.adminUsername,
    this.promotionUserName,
    this.promotionUserPhone,
    this.status,
    this.statusDisplay,
    this.createdAt,
    this.completedAt,
    this.totalCases,
    this.remark,
    this.internal,
    this.external,
  });

  WorkOrderModel.fromJson(Map<String, dynamic> json) {
    workOrderId = json['work_order_id'];
    adminEmployeeId = json['admin_employee_id'];
    adminUsername = json['admin_username'];
    promotionUserName = json['promotion_user_name'];
    promotionUserPhone = json['promotion_user_phone'];
    status = json['status'];
    statusDisplay = json['status_display'];
    createdAt = json['created_at'];
    completedAt = json['completed_at'];
    totalCases = json['total_cases'];
    remark = json['remark'];
    if (json['liked_cases']['internal'] != null &&
        json['liked_cases']['internal'].length > 0) {
      internal = <LikedCase>[];
      json['liked_cases']['internal'].forEach((v) {
        internal!.add(LikedCase.fromJson(v));
      });
    }
    if (json['liked_cases']['external'] != null &&
        json['liked_cases']['external'].length > 0) {
      external = <LikedCase>[];
      json['liked_cases']['external'].forEach((v) {
        external!.add(LikedCase.fromJson(v));
      });
    }
  }
}

class LikedCase {
  String? caseTitle;
  String? caseUrl;
  String? likedAt;

  LikedCase({
    this.caseTitle,
    this.caseUrl,
    this.likedAt,
  });

  factory LikedCase.fromJson(Map<String, dynamic> json) => LikedCase(
        caseTitle: json["case_title"],
        caseUrl: json["case_url"],
        likedAt: json["liked_at"],
      );
}
