import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:gauge_haus/shared/url_constants.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'dart:io';

class DioHelper {
  static Dio? dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: UrlConstants.baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add SSL certificate handling for HTTP client
    (dio!.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    addInterceptors();
  }

  static void addInterceptors() {
    if (dio != null) {
      dio!.interceptors.clear(); // Clear existing interceptors
      dio!.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
        ),
      );
    }
  }

  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? query,
    required dynamic data,
    Map<String, dynamic>? headers,
    String lang = 'en',
    String? token,
  }) async {
    if (dio == null) {
      init();
    }

    var response = await dio!.post(url,
        queryParameters: query,
        data: data,
        options: token != null
            ? Options(
                method: 'POST',
                followRedirects: false,
                validateStatus: (status) {
                  return status! < 500;
                },
                headers: headers ??
                    {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                      'Authorization': 'Bearer $token',
                    })
            : Options(
                method: 'POST',
                headers: headers ??
                    {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                    }));
    return response;
  }

  static Future<Response> postFormData({
    required String url,
    Map<String, dynamic>? query,
    required FormData data,
    Map<String, dynamic>? headers,
    String? token,
  }) async {
    if (dio == null) {
      init();
    }

    var response = await dio!.post(
      url,
      queryParameters: query,
      data: data,
      options: Options(
        method: 'POST',
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
        headers: token != null
            ? {
                'Authorization': 'Bearer $token',
                ...?headers,
              }
            : headers,
      ),
    );
    return response;
  }

  static Future<Response> getData({
    required String url,
    String? token,
    required Map<String, dynamic> query,
    Map<String, dynamic>? header,
  }) async {
    var headers = header ??
        {
          'Authorization': 'Bearer $token',
          'Cookie': token,
        };
    return await dio!.get(
      url,
      queryParameters: query,
      options: token != null
          ? Options(
              method: 'GET',
              headers: headers,
            )
          : null,
    );
  }

  static Future<Response> delete({
    required String url,
    required String token,
  }) async {
    var headers = {'Authorization': 'Bearer $token'};
    return dio!.request(
      url,
      options: Options(
        method: 'DELETE',
        headers: headers,
      ),
    );
  }

  static Future<Response> patch({
    required String url,
    required String token,
    required Map<String, dynamic> data,
  }) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Cookie': token,
    };
    return dio!.request(
      url,
      options: Options(
        method: 'PATCH',
        headers: headers,
      ),
      data: data,
    );
  }

  static Future<Response> patchFormData({
    required String url,
    Map<String, dynamic>? query,
    required FormData data,
    Map<String, dynamic>? headers,
    String? token,
  }) async {
    if (dio == null) {
      init();
    }

    var response = await dio!.patch(
      url,
      queryParameters: query,
      data: data,
      options: Options(
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
        headers: token != null
            ? {
                'Authorization': 'Bearer $token',
                ...?headers,
              }
            : headers,
      ),
    );
    return response;
  }
}
