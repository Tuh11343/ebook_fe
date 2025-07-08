import 'package:equatable/equatable.dart';

import '../../models/premium_plans.dart';
import '../../models/user_subscription.dart';

enum SubscriptionStatus {
  initial,
  loading,        // Đang tải dữ liệu ban đầu hoặc xử lý hành động chung
  loaded,         // Dữ liệu đã tải thành công
  paymentProcessing, // Đang trong quá trình xử lý thanh toán (trước khi presentPaymentSheet)
  paymentSuccess, // Thanh toán thành công
  paymentFailure, // Thanh toán thất bại
}

class SubscriptionState extends Equatable {
  final SubscriptionStatus status;
  final UserSubscription? currentUserSubscription;
  final List<PremiumPlan> availablePremiumPlans;
  final String? errorMessage;
  final String? successMessage;
  final String? clientSecretForPayment; // Chỉ lưu khi cần cho payment
  final String? paymentIntentId;        // Chỉ lưu khi cần cho payment

  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.currentUserSubscription,
    this.availablePremiumPlans = const [],
    this.errorMessage,
    this.successMessage,
    this.clientSecretForPayment,
    this.paymentIntentId,
  });

  // Sử dụng copyWith để tạo các trạng thái mới dựa trên trạng thái hiện tại
  SubscriptionState copyWith({
    SubscriptionStatus? status,
    UserSubscription? currentUserSubscription,
    List<PremiumPlan>? availablePremiumPlans,
    String? errorMessage,
    String? successMessage,
    String? clientSecretForPayment,
    String? paymentIntentId,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      currentUserSubscription: currentUserSubscription ?? this.currentUserSubscription,
      availablePremiumPlans: availablePremiumPlans ?? this.availablePremiumPlans,
      errorMessage: errorMessage, // Reset lỗi khi có trạng thái mới
      successMessage: successMessage, // Reset thông báo thành công
      clientSecretForPayment: clientSecretForPayment ?? this.clientSecretForPayment,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentUserSubscription,
    availablePremiumPlans,
    errorMessage,
    successMessage,
    clientSecretForPayment,
    paymentIntentId,
  ];
}