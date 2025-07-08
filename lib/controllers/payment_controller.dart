import '../data/app_data.dart';

class PaymentController {

  Future<Map<String, dynamic>> createPremiumPaymentIntent({
    required int amount,
    required String currency,
    required String planId,
    String? userId,
  }) async {
    try {
      final result = await AppData().payment.createPaymentIntent(
        amount: amount,
        currency: currency,
        planId: planId,
        userId: userId,
      );
      return result;
    } catch (e) {
      print('Error creating premium payment intent: $e');
      rethrow;
    }
  }
}