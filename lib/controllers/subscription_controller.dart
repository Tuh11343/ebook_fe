import 'package:ebook_tuh/models/user_subscription.dart';

import '../data/app_data.dart';

class UserSubscriptionController {

  Future<UserSubscription> getActiveSubscription(String userId) async {
    try {
      final result = await AppData().userSubscription.getActiveSubscription(userId);
      return UserSubscription.fromJson(result);
    } catch (e) {
      print('Error fetching all Subscriptions: $e');
      rethrow;
    }
  }
}