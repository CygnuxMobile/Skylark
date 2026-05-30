import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/data/models/location_model.dart';
import 'package:skylark/app/data/models/login_response_model.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Future<void> saveUser(LoginData user) async {
    await _prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
    await _prefs.setBool(AppConstants.isLoggedKey, true);
  }

  LoginData? getUser() {
    String? userStr = _prefs.getString(AppConstants.userDataKey);
    if (userStr != null) {
      return LoginData.fromJson(jsonDecode(userStr));
    }
    return null;
  }

  Future<void> saveLocation(LocationModel location) async {
    await _prefs.setString(AppConstants.selectedLocationKey, jsonEncode(location.toJson()));
  }

  LocationModel? getLocation() {
    String? locStr = _prefs.getString(AppConstants.selectedLocationKey);
    if (locStr != null) {
      return LocationModel.fromJson(jsonDecode(locStr));
    }
    return null;
  }

  bool isLoggedIn() {
    return _prefs.getBool(AppConstants.isLoggedKey) ?? false;
  }

  Future<void> clearStorage() async {
    await _prefs.clear();
  }
}
