import 'dart:io';
import 'dart:async';
import 'Session.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:dio/dio.dart' as dio_;
import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:elite_tiers/UI/widgets/ApiException.dart';

class ApiBaseHelper {
  final dio_.Dio dio = dio_.Dio();

  Future<void> downloadFile(
      {required String url,
      required dio_.CancelToken cancelToken,
      required String savePath,
      required Function updateDownloadedPercentage}) async {
    try {
      final dio_.Dio dio = dio_.Dio();
      await dio.download(url, savePath, cancelToken: cancelToken,
          onReceiveProgress: ((count, total) {
        updateDownloadedPercentage((count / total) * 100);
      }));
    } on dio_.DioException catch (e) {
      if (e.type == dio_.DioExceptionType.connectionError) {
        throw ApiException('No Internet connection');
      }

      throw ApiException('Failed to download file');
    } catch (e) {
      throw Exception('Failed to download file');
    }
  }

  Future<dynamic> postAPICall(Uri url, Map param) async {
    var responseJson;
    try {
      final response = await post(url,
              body: param.isNotEmpty ? param : null, headers: headers)
          .timeout(const Duration(seconds: timeOut));
      print("param****$param****$url");
      print("respon****${response.statusCode}");

      responseJson = _response(response);
      print("respon****${responseJson.toString()}");
      log("responjson** ${url} $param ----**$responseJson");
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw FetchDataException('Something went wrong, try again later');
    }

    return responseJson;
  }

  Future<dynamic> postDioCall(String url, Map<String, dynamic> param) async {
    print("API Request to $url with param: $param");

    try {
      final response = await dio.post(
        url,
        data: param,
        options: dio_.Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
          headers: headers, // Optional: add headers if any
        ),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.data}");

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 302) {
        final redirectUrl = response.headers.value('location');
        throw FetchDataException('302 Redirected to $redirectUrl');
      } else if (response.statusCode == 400) {
        throw BadRequestException(response.data.toString());
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw UnauthorisedException(response.data.toString());
      } else {
        throw FetchDataException(
            'Unexpected status: ${response.statusCode} - ${response.statusMessage}');
      }
    } on dio_.DioException catch (e) {
      if (e.type == dio_.DioExceptionType.connectionError) {
        throw FetchDataException('No Internet connection');
      } else if (e.type == dio_.DioExceptionType.connectionTimeout ||
          e.type == dio_.DioExceptionType.receiveTimeout) {
        throw FetchDataException('Connection timed out');
      } else {
        throw FetchDataException('Something went wrong: ${e.message}');
      }
    } catch (e) {
      throw FetchDataException('Unexpected error: $e');
    }
  }

  dynamic _response(Response response) {
    switch (response.statusCode) {
      case 200:
        print("Reponse is ${getToken()}");
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      case 302:
        var location = response.headers['location'];
        print("Redirect Location: $location");
        throw FetchDataException('302 Redirect received. Location: $location');
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode: ${response.statusCode}');
    }
  }
}

class CustomException implements Exception {
  final _message;
  final _prefix;

  CustomException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends CustomException {
  InvalidInputException([message]) : super(message, "Invalid Input: ");
}
