import 'package:skylark/app/data/models/location_model.dart';

class LoginResponseModel {
  final int? statusCode;
  final int? status;
  final LoginData? data;
  final ApiErrors? errors;
  final String? metaData;
  final String? message;

  LoginResponseModel({
    this.statusCode,
    this.status,
    this.data,
    this.errors,
    this.metaData,
    this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      statusCode: json['statusCode'],
      status: json['status'],
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      errors: json['errors'] != null ? ApiErrors.fromJson(json['errors']) : null,
      metaData: json['metaData'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'status': status,
      'data': data?.toJson(),
      'errors': errors?.toJson(),
      'metaData': metaData,
      'message': message,
    };
  }
}

class LoginData {
  final String? token;
  final String? tokenExpireTime;
  final String? userId;
  final String? name;
  final String? emailId;
  final dynamic userImage;
  final String? baseCompanyCode;
  final String? branchCode;
  final String? finYear;
  final String? city;
  final List<LocationModel>? multiLocation;
  final List<LocationModel>? coLocation;

  LoginData({
    this.token,
    this.tokenExpireTime,
    this.userId,
    this.name,
    this.emailId,
    this.userImage,
    this.baseCompanyCode,
    this.branchCode,
    this.finYear,
    this.city,
    this.multiLocation,
    this.coLocation,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'],
      tokenExpireTime: json['tokenExpireTime'],
      userId: json['userId'],
      name: json['name'],
      emailId: json['emailId'],
      userImage: json['userImage'],
      baseCompanyCode: json['baseCompanyCode'],
      branchCode: json['branchCode'],
      finYear: json['finYear'],
      city: json['city'],
      multiLocation: json['multiLocation'] != null
          ? (json['multiLocation'] as List).map((i) => LocationModel.fromJson(i)).toList()
          : null,
      coLocation: json['coLocation'] != null
          ? (json['coLocation'] as List).map((i) => LocationModel.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'tokenExpireTime': tokenExpireTime,
      'userId': userId,
      'name': name,
      'emailId': emailId,
      'userImage': userImage,
      'baseCompanyCode': baseCompanyCode,
      'branchCode': branchCode,
      'finYear': finYear,
      'city': city,
      'multiLocation': multiLocation?.map((v) => v.toJson()).toList(),
      'coLocation': coLocation?.map((v) => v.toJson()).toList(),
    };
  }
}

class MultiLocation {
  final String? locCode;
  final String? locName;

  MultiLocation({this.locCode, this.locName});

  factory MultiLocation.fromJson(Map<String, dynamic> json) {
    return MultiLocation(
      locCode: json['locCode'],
      locName: json['locName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locCode': locCode,
      'locName': locName,
    };
  }
}

class ApiErrors {
  final int? status;
  final String? message;
  final String? errors;
  final String? timeStamp;

  ApiErrors({this.status, this.message, this.errors, this.timeStamp});

  factory ApiErrors.fromJson(Map<String, dynamic> json) {
    return ApiErrors(
      status: json['status'],
      message: json['message'],
      errors: json['errors'],
      timeStamp: json['timeStamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'errors': errors,
      'timeStamp': timeStamp,
    };
  }
}
