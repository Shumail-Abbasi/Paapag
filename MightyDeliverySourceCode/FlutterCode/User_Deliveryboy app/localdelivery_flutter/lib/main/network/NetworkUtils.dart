import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:paapag/main/network/dio_wrapper.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import 'RestApis.dart';

@deprecated
Map<String, String> buildHeaderTokens() {
  Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.cacheControlHeader: 'no-cache',
    HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Origin': '*',
  };

  if (appStore.isLoggedIn) {
    header.putIfAbsent(HttpHeaders.authorizationHeader, () => 'Bearer ${getStringAsync(USER_TOKEN)}');
  }
  log(jsonEncode(header));
  return header;
}

Uri buildBaseUrl(String endPoint) {
  Uri url = Uri.parse(endPoint);
  if (!endPoint.startsWith('http')) url = Uri.parse('$mBaseUrl$endPoint');

  log('URL: ${url.toString()}');

  return url;
}

Future<Response> buildHttpResponse(String endPoint, {HttpMethod method = HttpMethod.GET, Map? request, FormData? formData}) async {
  if (await isNetworkAvailable()) {
    Uri url = buildBaseUrl(endPoint);

    try {
      Response response;

      if (method == HttpMethod.POST) {
        log('Request: $request');

        response = await DioWrapper.dio.post(url.path, data: jsonEncode(request));
      } else if (method == HttpMethod.POST_FORM) {
        response = await DioWrapper.dio.post(url.path, data: formData);
      } else if (method == HttpMethod.DELETE) {
        response = await DioWrapper.dio.delete(url.path);
      } else if (method == HttpMethod.PUT) {
        response = await DioWrapper.dio.put(url.path, data: jsonEncode(request));
      } else {
        response = await DioWrapper.dio.get(url.path);
      }

      log('Response ($method): ${url.toString()} ${response.statusCode} ${response.data}');

      return response;
    } catch (e) {
      throw errorSomethingWentWrong;
    }
  } else {
    throw errorInternetNotAvailable;
  }
}

//region Common

Future handleResponse(Response response, [bool? avoidTokenError]) async {
  if (!await isNetworkAvailable()) {
    throw errorInternetNotAvailable;
  }
  if (response.statusCode == 401) {
    if (appStore.isLoggedIn) {
      Map req = {
        'email': appStore.userEmail,
        'password': getStringAsync(USER_PASSWORD),
      };

      await logInApi(req).then((value) {
        throw '';
      }).catchError((e) {
        throw TokenException(e);
      });
    }else{
      throw '';
    }
  }

  if (response.statusCode.isSuccessful()) {
    return jsonDecode(response.data);
  } else {
    try {
      var body = jsonDecode(response.data);
      throw parseHtmlString(body['message']);
    } on Exception catch (e) {
      log(e);
      throw errorSomethingWentWrong;
    }
  }
}
enum HttpMethod { GET, POST, DELETE, PUT, POST_FORM }

class TokenException implements Exception {
  final String message;

  const TokenException([this.message = ""]);

  String toString() => "FormatException: $message";
}
