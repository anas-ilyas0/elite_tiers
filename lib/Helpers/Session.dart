import 'dart:async';
import 'package:elite_tiers/App/languages.dart';
import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:elite_tiers/Models/language_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/app_Localization.dart';
import 'String.dart';
import 'package:http/http.dart' as http;

Future<void> setPrefrence(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

Future<String?> getPrefrence(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<void> removePrefrence(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}

setPrefrenceBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

Future<bool> getPrefrenceBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}

Future<bool> isDemoUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(IS_DEMO) ?? true;
}

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<bool> isNetworkAvailable() async {
  try {
    final response = await http.get(Uri.parse('https://www.google.com'));
    if (response.statusCode == 200) {
      print('Internet is available.');
      return true;
    }
    print('Google responded with status: ${response.statusCode}');
    return false;
  } catch (e) {
    print('Error in HTTP request: $e');
    return false;
  }
}

Future<Locale> getLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode =
      prefs.getString(LAGUAGE_CODE) ?? Languages().defaultLanguageCode;
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  List<Language> supportedLanguages = Languages().supported();

  Language language = supportedLanguages.firstWhere(
    (element) => element.code == languageCode,
    orElse: () {
      return Languages().getDefaultLanguage();
    },
  );
  return Locale(language.code);
}

String? getTranslated(BuildContext context, String key) {
  return AppLocalization.of(context)!.translate(key) ?? key;
}

getToken() {
  // final claimSet = JwtClaim(
  //     issuer: issuerName,
  //     // maxAge: const Duration(minutes: 1),
  //     maxAge: const Duration(days: tokenExpireTime),
  //     issuedAt: DateTime.now().toUtc());
  //
  // String token = issueJwtHS256(claimSet, Hive);
  // print("token is $token");
  //return HiveUtils.getJWT() ?? "";
}

Map<String, String> get headers => {
      "Authorization": 'Bearer ${getToken()}',
    };
