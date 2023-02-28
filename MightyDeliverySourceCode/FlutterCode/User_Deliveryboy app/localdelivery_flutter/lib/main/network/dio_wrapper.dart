import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paapag/main/network/dio_interceptor.dart';
import 'package:paapag/main/utils/Constants.dart';

class DioWrapper extends ApiConnector {
  static DioWrapper? _instance;

  DioWrapper._();

  static DioWrapper get i {
    _instance ??= DioWrapper._();
    return _instance!;
  }

 static Dio get dio => i.client._dio;
}

abstract class ApiConnector {
  late Dio _dio;

  late ApiClient _apiClient;

  ApiClient get client => _apiClient;

  ApiConnector() {
    _dio = Dio();
    _dio.interceptors.add(CustomInterceptors(dio: _dio));
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (value) {
        if (kDebugMode) {
          log('LogInterceptor => $value');
          if (value is FormData) {
            value.fields.forEachIndexed((element, index) {
              log('LogInterceptor => Field[$index]: ${element.key}:${element.value}');
            });
            value.files.forEachIndexed((element, index) {
              log('LogInterceptor => File[$index]: ${element.key}:${element.value.filename}');
            });
          }
        }
      },
    ));
    _apiClient = ApiClient(_dio, mBaseUrl);
  }
}

class ApiClient {
  final Dio _dio;
  final String baseUrl;

  ApiClient(this._dio, this.baseUrl) {
    _dio.options = BaseOptions(
      receiveTimeout: const Duration(seconds: 20),
      connectTimeout: const Duration(seconds: 20),
      contentType: 'application/json',
    );
  }
}
