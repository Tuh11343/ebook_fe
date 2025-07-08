import 'package:dio/dio.dart';

import '../constants/api_mapping.dart';
import '../constants/app_secure_storage.dart';
import 'dio_base.dart';

class SubscriptionData extends DioBase {
  Future<dynamic> getActiveSubscription(String userId) async {
    try {
      String? token = await AppStorage.getUserToken();

      final response = await super.dio.get(APIMapping.getActiveSubscription,
          queryParameters: {'userId': userId},
          options: Options(
            headers: {
              'Authorization': 'Bearer $token', // <-- THÊM BEARER TOKEN VÀO ĐÂY
              'Content-Type':
                  'application/json', // Thường là JSON cho POST request
            },
          ));

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    } catch (ex) {
      print('Unexpected error get active subscription: $ex');
      rethrow;
    }
  }
}
