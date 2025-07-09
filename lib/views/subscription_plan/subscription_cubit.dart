import 'package:ebook_tuh/constants/app_secure_storage.dart';
import 'package:ebook_tuh/controllers/app_controller.dart';
import 'package:ebook_tuh/data/dummy.dart';
import 'package:ebook_tuh/models/premium_plans.dart';
import 'package:ebook_tuh/views/subscription_plan/subscription_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:uuid/uuid.dart';

import '../../models/user.dart';
import '../../models/user_subscription.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit() : super(const SubscriptionState());

  Future<void> fetchSubscriptionData() async {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    try {
      User? user = await AppStorage.getUser();
      if (user == null) {
        emit(state.copyWith(
          status: SubscriptionStatus.loaded, // Vẫn là loaded nhưng có lỗi
          errorMessage: 'Không có thông tin tài khoản',
        ));
        return;
      }
      UserSubscription? userSubscription = await AppControllers()
          .userSubscription
          .getActiveSubscription(user.userId);
      final availablePlans =
          await AppControllers().premiumPlan.fetchAllPremiumPlans();
      emit(state.copyWith(
        status: SubscriptionStatus.loaded,
        currentUserSubscription: userSubscription,
        availablePremiumPlans: availablePlans,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.loaded, // Vẫn là loaded nhưng có lỗi
        errorMessage: 'Không thể tải dữ liệu gói đăng ký: ${e.toString()}',
      ));
    }
  }

  Future<void> purchasePlan(PremiumPlan plan) async {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    try {
      String? userId = await AppStorage.getUserId();
      if (userId == null) {
        emit(state.copyWith(
          status: SubscriptionStatus.paymentFailure,
          errorMessage: 'Không có thông tin người dùng',
        ));
        return;
      }

      final responseData =
          await AppControllers().payment.createPremiumPaymentIntent(
                amount: plan.price.toInt(),
                currency: 'VND',
                planId: plan.planId,
                userId: userId,
              );

      final String? clientSecret = responseData['clientSecret'];
      final String? paymentIntentId = responseData['paymentIntentId'];
      final String? currencyFromBackend =
          responseData['currency'];

      if (clientSecret == null || paymentIntentId == null) {
        emit(state.copyWith(
          status: SubscriptionStatus.paymentFailure,
          errorMessage: 'Thiếu clientSecret hoặc paymentIntentId từ server.',
        ));
        return;
      }

      if (clientSecret == null || paymentIntentId == null) {
        emit(state.copyWith(
          status: SubscriptionStatus.paymentFailure,
          errorMessage: 'Thiếu clientSecret hoặc paymentIntentId từ server.',
        ));
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'ETuh',
          // Thay đổi tên cửa hàng
          // customerEphemeralKeySecret và customerId chỉ cần thiết nếu bạn quản lý khách hàng qua Stripe Customer Object
          // customerEphemeralKeySecret: contents['ephemeralKey'],
          // customerId: contents['customerId'],
          allowsDelayedPaymentMethods: true,
          style: ThemeMode.light,
        ),
      );

      // Lưu clientSecret và paymentIntentId vào state khi đang chuẩn bị thanh toán
      emit(state.copyWith(
        status: SubscriptionStatus.paymentProcessing,
        clientSecretForPayment: clientSecret,
        paymentIntentId: paymentIntentId,
      ));

      // Tiếp tục luồng xử lý Payment Sheet ở UI (presentPaymentSheet)
      // Sau đó UI sẽ gọi handlePaymentResult để xác nhận thanh toán
    } on StripeException catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.paymentFailure,
        errorMessage: 'Lỗi Stripe: ${e.error.message ?? "Không xác định"}',
        clientSecretForPayment: null, // Xóa giá trị lỗi
        paymentIntentId: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.paymentFailure,
        errorMessage: 'Đã xảy ra lỗi: ${e.toString()}',
        clientSecretForPayment: null, // Xóa giá trị lỗi
        paymentIntentId: null,
      ));
    }
  }

  Future<void> handlePaymentResult() async {
    if (state.status == SubscriptionStatus.paymentProcessing &&
        state.paymentIntentId != null) {
      try {
        String? userId = await AppStorage.getUserId();
        if (userId == null) {
          emit(state.copyWith(
            status: SubscriptionStatus.paymentFailure,
            errorMessage: 'Không có thông tin người dùng',
            clientSecretForPayment: null,
            paymentIntentId: null,
          ));
          return;
        }

        // Đợi một chút để đảm bảo thanh toán đã được xử lý hoàn toàn
        await Future.delayed(const Duration(milliseconds: 500));

        UserSubscription? updatedSubscription = await AppControllers()
            .userSubscription
            .getActiveSubscription(userId);

        if(updatedSubscription==null){
          emit(state.copyWith(
            status: SubscriptionStatus.paymentFailure,
            errorMessage: 'Lỗi thanh toán',
            clientSecretForPayment: null,
            paymentIntentId: null,
          ));
          return;
        }

        emit(state.copyWith(
          status: SubscriptionStatus.paymentSuccess,
          successMessage: 'Thanh toán thành công và đã được xác nhận!',
          currentUserSubscription: updatedSubscription,
          clientSecretForPayment: null,
          paymentIntentId: null,
        ));

        await fetchSubscriptionData();
      } catch (e) {
        emit(state.copyWith(
          status: SubscriptionStatus.paymentFailure,
          errorMessage: 'Lỗi xác nhận thanh toán: ${e.toString()}',
          clientSecretForPayment: null,
          paymentIntentId: null,
        ));
      }
    } else {
      emit(state.copyWith(
        status: SubscriptionStatus.paymentFailure,
        errorMessage: 'Trạng thái không hợp lệ để xác nhận thanh toán.',
      ));
    }
  }

  void clearMessages() {
    emit(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }
}
