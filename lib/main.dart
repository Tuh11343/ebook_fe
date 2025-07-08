import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'constants/app_constant.dart';
import 'constants/app_secure_storage.dart';
import 'firebase_options.dart';
import 'navigation/app_navigation.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  // Firebase.initializeApp() là hàm quan trọng nhất để thiết lập Firebase SDK.
  // options: DefaultFirebaseOptions.currentPlatform sẽ sử dụng cấu hình
  // được tạo tự động cho nền tảng hiện tại.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppStorage.init();
  Stripe.publishableKey = AppConstants.stripePublishableKey;

  runApp(const MyApp());

}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EBook',
      debugShowCheckedModeBanner: false,
      routerConfig: AppNavigation.router,
    );
  }
}

