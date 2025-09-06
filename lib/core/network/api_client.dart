import 'dart:io';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://content.guardianapis.com',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ),
          ) {
    _dio.interceptors.add(
      LogInterceptor(responseBody: false, requestBody: false),
    );
  }

  Future<Map<String, dynamic>> get(String path, { Map<String, dynamic>? query}) async
  {
    try
    {
      const apiKey = String.fromEnvironment('GUARDIAN_API_KEY');
      if (apiKey.isEmpty)
      {
        throw Exception('Missing GUARDIAN_API_KEY. Pass it via --dart-define.');
      }

      final res = await _dio.get(
        path,
        queryParameters: {'api-key': apiKey, ...?query},
        options: Options(responseType: ResponseType.json),
      );

      return res.data as Map<String, dynamic>;
    }
    on DioException catch (e)
    {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.error is SocketException)
      {
        throw Exception('NETWORK_ERROR');
      }
      throw Exception('API_ERROR');
    }
  }
}
