import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:logger/logger.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/data/services/storage_service.dart';

class ApiService {
  late Dio _dio;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final storageService = Get.find<StorageService>();
        final token = storageService.getToken();
        
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        _logger.i('🚀 API Request: [${options.method}] ${options.uri}'
            '\nHeaders: ${options.headers}'
            '\nParams: ${options.queryParameters}'
            '\nBody: ${options.data}');
            
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i('✅ API Response: [${response.statusCode}] ${response.requestOptions.uri}'
            '\nData: ${response.data}');
            
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        _logger.e('❌ API Error: [${e.response?.statusCode}] ${e.requestOptions.uri}'
            '\nMessage: ${e.message}'
            '\nData: ${e.response?.data}');

        return handler.next(e);
      },
    ));
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
