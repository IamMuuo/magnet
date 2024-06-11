// Copyright (c) 2023 Erick Muuo. All Rights Reserved.
// Magner base.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

class Magnet {
  /// The base url to which  requests are made
  static const String _baseUrl = "https://student.daystar.ac.ke";
  Map<String, String> _header = {};
  DateTime? _lastLogin;

  final String _username;
  final String _password;
  String? _sessionId;

  Magnet(this._username, this._password);
  Future<List<dynamic>> fetchExamTimeTabale(String units,
      {bool athi = true}) async {
    // Fetch the unit specified
    try {
      var response = await http.get(Uri.parse(
          'https://exam.dita.co.ke/api/courses?courses=${units.toUpperCase().replaceAll(" ", "").trim()}&campus_choice=${athi ? 1 : 2}'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["data"];
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchContributors() async {
    try {
      var response = await http.get(Uri.parse(
          "https://api.github.com/repos/IamMuuo/academia/contributors?per_page=100"));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }
}
