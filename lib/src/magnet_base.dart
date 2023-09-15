// Copyright (c) 2023 Erick Muuo. All Rights Reserved.
// Magner base.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Magnet {
  /// The base url to which  requests are made
  static const String _baseUrl = "https://student.daystar.ac.ke";
  Map<String, String>? _header;
  DateTime? _lastLogin;

  final String _username;
  final String _password;
  String? _sessionId;

  Magnet(this._username, this._password);

  /// Pings the home page and extract the token
  Future<void> fetchSessionToken() async {
    if (_lastLogin == null ||
        _lastLogin!.isAfter(_lastLogin!.add(Duration(hours: 3))) ||
        _sessionId == null) {
      var response = await http.get(Uri.parse("$_baseUrl/"));

      if (response.statusCode != 200) {
        throw Exception("Could not fetch token");
      }

      // get the session _sessionId
      _header = {
        "Cookie": response.headers["set-cookie"],
      };

      print("fetch session: $_header");
      // var cookie = Cookie.fromSetCookieValue(_header!["set-cookie"]);
      // _sessionId = cookie.toString().replaceAll("Path=/;", "");
      // print(_sessionId);
    }
    return;
  }

  /// Attempts to login a user onto the portal, sets the necessary headers,
  //. for subsequent requests
  Future<bool> login() async {
    if (_lastLogin == null ||
        _lastLogin!.isAfter(_lastLogin!.add(Duration(hours: 3)))) {
      await fetchSessionToken();
      _header!.remove("content-length");
      // Send a request
      var response = await http.post(
        Uri.parse("$_baseUrl/Login/LoginUser"),
        headers: _header as Map<String, dynamic>,
        body: json.encode(
          {"Username": _username, "Password": _password},
        ),
      );

      if (response.statusCode == 200) {
        var body = json.decode(response.body);

        // If user is not authorized
        if (!body["success"]) {
          throw Exception("Something went wrong: ${body["message"]}");
        }
        // Set headers
        _header = {
          "Cookie": response.headers["set-cookie"],
        };
        print("login headers: $_header");

        // Set the last login time
        _lastLogin = DateTime.now();
        await fetchUserData();

        return true;
      } else {
        throw Exception("Error response not 200!");
      }
    } else {
      return true;
    }
  }

  /// Attemot to parse the content
  Future<Map> fetchUserData() async {
    if (await login()) {
      // var headers = {
      //   "Cookie":
      //       "${_header!["set-cookie"].toString().replaceAll("$_sessionId", "")}"
      // };

      print("fetch user data: $_header");
      // fetch user details
      var response = await http.get(
        Uri.parse("$_baseUrl/Dashboard/Dashboard"),
        headers: _header as Map<String, String>,
      );

      if (response.statusCode != 200) {
        throw Exception("Error fetching student data");
      }
      // print(response.headers);
      print(response.body);
    }
    return {};
  }
}
