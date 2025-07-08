import 'package:dio/dio.dart';

import '../constants/api_mapping.dart';
import '../constants/app_secure_storage.dart';

class DioBase{

  static final BaseOptions options=BaseOptions(
    baseUrl: APIMapping.hostName,
    connectTimeout: 10000,
    receiveTimeout: 30000,
  );

  final Dio dio=Dio(options);

  DioBase() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {

        // Chỉ thêm Authorization cho các endpoint cần token
        if (APIMapping.requiresAuth(options.path)) {
          final token = await AppStorage.getUserToken();
          if (token != null && token.isNotEmpty) {
            // options.headers['Authorization'] = 'Bearer $token';
          } else {
            throw DioError(
              requestOptions: options,
              error: 'Unauthorized: No token available',
            );
          }
        }
        handler.next(options);
      },
      onError: (DioError error, handler) {
        // Xử lý lỗi cơ bản, ví dụ: 401 Unauthorized
        if (error.response?.statusCode == 401) {
          throw DioError(
            requestOptions: error.requestOptions,
            error: 'Unauthorized: Invalid or expired token',
          );
        }
        handler.next(error);
      },
    ));
  }
}


