// Copyright (c) 2023 Erick Muuo. All Rights Reserved.
// Magner base.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class Magnet {
  /// The base url to which  requests are made
  static const String _baseUrl = "https://student.daystar.ac.ke";
  Map? _header;
  DateTime? _lastLogin;

  /// Attempts to login a user onto the portal, sets the necessary headers,
  //. for subsequent requests
  Future<bool> login(String username, password) async {
    if (_lastLogin == null ||
        _lastLogin!.isAfter(_lastLogin!.add(Duration(hours: 3)))) {
      // Send a request
      var response = await http.post(
        Uri.parse("$_baseUrl/Login/LoginUser"),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(
          {"Username": username, "Password": password},
        ),
      );

      if (response.statusCode == 200) {
        var body = json.decode(response.body);

        // If user is not authorized
        if (!body["success"]) {
          return false;
        }
        // Set headers
        _header = response.headers;

        // Set the last login time
        _lastLogin = DateTime.now();

        return true;
      } else {
        throw Exception("Error response not 200!");
      }
    } else {
      return true;
    }
  }
}
