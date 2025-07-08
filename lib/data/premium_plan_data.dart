import '../constants/api_mapping.dart';
import 'dio_base.dart';

class PremiumPlanData extends DioBase {

  Future<dynamic> getAllPremiumPlans({int? limit, int? offset}) async {
    try {
      final response = await super.dio.get(
        APIMapping.findAllPremiumPlans,
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      } else {
        throw response.statusCode!;
      }
    } catch (e) {
      print('Unexpected error in getAllPremiumPlans: $e');
      rethrow;
    }
  }


}