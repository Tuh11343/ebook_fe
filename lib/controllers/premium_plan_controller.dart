import '../data/app_data.dart';
import '../models/premium_plans.dart';

class PremiumPlanController {
  Future<List<PremiumPlan>> fetchAllPremiumPlans(
      {int? limit, int? offset}) async {
    try {
      final result = await AppData()
          .premiumPlan
          .getAllPremiumPlans(limit: limit, offset: offset);
      return List<PremiumPlan>.from(
          result.map((x) => PremiumPlan.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error fetching all premium plans: $e');
      rethrow;
    }
  }
}
