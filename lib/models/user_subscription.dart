import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart'; // Đảm bảo bạn đã import Uuid nếu dùng trong toJson

class UserSubscription extends Equatable {
  final String userSubscriptionId;
  final String userId;
  final String planId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? transactionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserSubscription({
    required this.userSubscriptionId,
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.transactionId,
    required this.createdAt, // createdAt is required
    required this.updatedAt, // updatedAt is required
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      // Ưu tiên camelCase, sau đó là snake_case
      userSubscriptionId: json['userSubscriptionId'] as String? ?? json['user_subscription_id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String,
      planId: json['planId'] as String? ?? json['plan_id'] as String,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.parse(json['start_date'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : DateTime.parse(json['end_date'] as String),
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool,
      transactionId: json['transactionId'] as String? ?? json['transaction_id'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    // Xuất ra camelCase (giả sử backend của bạn mong đợi camelCase khi gửi đi)
    return {
      'userSubscriptionId': userSubscriptionId.isEmpty ? const Uuid().v4() : userSubscriptionId, // Đổi từ 'user_subscription_id'
      'userId': userId, // Đổi từ 'user_id'
      'planId': planId, // Đổi từ 'plan_id'
      'startDate': startDate.toIso8601String(), // Đổi từ 'start_date'
      'endDate': endDate.toIso8601String(), // Đổi từ 'end_date'
      'isActive': isActive, // Đổi từ 'is_active'
      'transactionId': transactionId, // Đổi từ 'transaction_id'
      'createdAt': createdAt?.toIso8601String(), // Đổi từ 'created_at' (và sửa thành non-nullable DateTime)
      'updatedAt': updatedAt?.toIso8601String(), // Đổi từ 'updated_at' (và sửa thành non-nullable DateTime)
    };
  }

  UserSubscription copyWith({
    String? userSubscriptionId,
    String? userId,
    String? planId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSubscription(
      userSubscriptionId: userSubscriptionId ?? this.userSubscriptionId,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    userSubscriptionId,
    userId,
    planId,
    startDate,
    endDate,
    isActive,
    transactionId,
    createdAt,
    updatedAt,
  ];
}