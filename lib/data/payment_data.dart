import 'package:dio/dio.dart';
import 'package:ebook_tuh/constants/app_secure_storage.dart';

import '../constants/api_mapping.dart';
import 'dio_base.dart';

class PaymentData extends DioBase {

  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
    required String planId,
    String? userId,
  }) async {
    try {

      String? token=await AppStorage.getUserToken();

      final response = await super.dio.post(
        APIMapping.createPremiumPaymentIntent,
        data: {
          'amount': amount,
          'currency': currency,
          'planId': planId,
          'userId': userId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
      );

      if (response.statusCode == 200 && response.data['status']['code'] == 200) {
        return response.data['contents'] as Map<String, dynamic>;
      } else {
        throw DioError(
          requestOptions: response.requestOptions,
          response: response,
          error: response.data['status']['message'] ?? 'Failed to create payment intent',
        );
      }
    }catch (e) {
      print('An unexpected error occurred during createPaymentIntent: $e');
      rethrow;
    }
  }
}