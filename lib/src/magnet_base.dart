import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:magnet/src/auth/auth.dart';
import 'package:magnet/src/repository/repository.dart';

/// Copyright (c) 2023 Erick Muuo. All Rights Reserved.
/// Academia's portal scraping engine
/// Distributed under the GNU public license
// You are free to use it as deemed fit

/// Academia's student portal scraping engine
class Magnet {
  String? _admno;
  String? _password;
  String? _token;

  /// Private constructor to prevent external instantiation.
  Magnet._internal();

  /// The singleton instance of the [Magnet] class.
  static final Magnet _instance = Magnet._internal();

  /// Factory constructor for creating a single instance of [Magnet].
  /// Takes [admission] and [password] as parameters.
  factory Magnet(String admission, String password) {
    _instance._admno = admission;
    _instance._password = password;

    return _instance;
  }

  /// Attempts to authenticate a user
  Future<Either<Exception, String>> login() async {
    return Auth.fetchSessionToken()
        .then((value) => value.fold((l) => left(l), (r) {
              return Auth.login(r, _instance._admno!, _instance._password!)
                  .then((value) => value.fold((l) => left(l), (r) {
                        _instance._token = r;
                        return right(r);
                      }));
            }));
  }

  Repository get repositories => Repository();

  /// Retrieves the admission number.
  String get admission => _admno!;

  /// Retrieves the admission number.
  String get token => _token!;

  /// Retrieves the password.
  String get password => _password!;

  // New function to fetch catering token using the stored token
  Future<Either<Exception, Map<String, dynamic>>> fetchCateringToken() async {
    return Repository.fetchCateringToken(_token!);
  }

  // New function to fetch academic calendar using the stored token
  Future<Either<Exception, List<Map<String, dynamic>>>>
      fetchAcademicCalendar() async {
    return Repository.fetchAcademicCalendar(_token!);
  }

  // New function to fetch transcript using the stored token
  Future<Either<Exception, List<String>>> fetchTranscript() async {
    return Repository.fetchTranscript(_token!);
  }

  // New function to fetch student audit using the stored token
  Future<Either<Exception, List<String>>> fetchStudentAudit() async {
    return Repository.fetchStudentAudit(_admno!);
  }

  // New function to fetch fee statement using the stored token
  Future<Either<Exception, List<Map<String, dynamic>>>>
      fetchFeeStatement() async {
    return Repository.fetchFeeStatement(_token!);
  }

  // New function to fetch user class attendance using the stored token
  Future<Either<Exception, List<Map<String, int>>>>
      fetchUserClassAttendance() async {
    return Repository.fetchUserClassAttendance(_token!);
  }

  // New function to fetch user details using the stored token
  Future<Either<Exception, Map<String, String>>> fetchUserDetails() async {
    return Repository.fetchUserDetails(_token!);
  }

  // New function to fetch user timetable using the stored token
  Future<Either<Exception, List<Map<String, String>>>>
      fetchUserTimeTable() async {
    return Repository.fetchUserTimeTable(_token!);
  }

  // New function to fetch timetable using the stored token
  Future<Either<Exception, List<Map<String, String>>>> fetchTimeTable() async {
    return Repository.fetchTimeTable(_token!);
  }
}
