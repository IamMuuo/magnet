import 'dart:convert';

import 'package:magnet/magnet.dart';

import 'package:http/http.dart' as http;

extension MagnetExamExtension on Magnet {
  static const String _backendUrl = "http://academia.erick.serv00.net";
  Future<List<Map<String, dynamic>>> fetchExam() async {
    try {
      final res = await http.post(
        Uri.parse("$_backendUrl/timetables/exams/"),
      );

      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(res.body));
      }
      throw Exception("Failed to fetch exam timetable");
    } catch (e) {
      rethrow;
    }
  }
}
