import 'dart:io';

import 'package:dio/dio.dart';

class SignUpRequestModel {
  const SignUpRequestModel({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.profileImagePath,
  });

  final String firstName;
  final String lastName;
  final String userName;
  final String email;
  final String password;
  final String phoneNumber;
  final String? profileImagePath;

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'FirstName': firstName,
      'LastName': lastName,
      'UserName': userName,
      'PhoneNumber': phoneNumber,
      'Email': email,
      'Password': password,
    };

    if (profileImagePath != null && profileImagePath!.isNotEmpty) {
      map['ProfileImage'] = await MultipartFile.fromFile(
        profileImagePath!,
        filename: profileImagePath!.split(Platform.pathSeparator).last,
      );
    }

    return FormData.fromMap(map);
  }
}
