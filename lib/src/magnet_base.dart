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
        'Content-type': 'application/json',
        'Cookie': response.headers["set-cookie"].toString().split(" ")[0],
      };

      _sessionId = _header['Cookie'];

      // print("fetch session: $_header");
      // var cookie = Cookie.fromSetCookieValue(_header!["set-cookie"]);
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
      // _header.remove("content-length");
      // Send a request
      var response = await http.post(
        Uri.parse("$_baseUrl/Login/LoginUser"),
        headers: _header,
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
          'Content-type': 'application/json',
          'Cookie': '$_sessionId ${response.headers["set-cookie"]}',
        };
        // print("login headers: $_header");
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

  /// Attemot to parse the content
  Future<Map> fetchUserData() async {
    if (await login()) {
      // print("fetch user data: $_header");
      // fetch user details
      var response = await http.get(
        Uri.parse("$_baseUrl/Dashboard/Dashboard"),
        headers: _header,
      );

      if (response.statusCode != 200) {
        throw Exception("Error fetching student data");
      }
      // print(response.body);
      final document = parser.parse(response.body);

      // Select all div elements with class "row mb-X"

      final dataBlocks = document.querySelectorAll('div[class^="row mb-"]');
      var data = {};

      for (final dataBlock in dataBlocks) {
        final labelElement = dataBlock.querySelector('label');
        final valueElement = dataBlock.querySelector('.badge');

        if (labelElement != null && valueElement != null) {
          final key = labelElement.text.trim();
          final value = valueElement.text.trim();

          data[key
              .toLowerCase()
              .trim()
              .replaceAll(".", "")
              .replaceAll(" ", "")] = value.toLowerCase().trim();
        }
      }
      final elements = document.getElementsByClassName('rounded-circle');

      if (elements.isNotEmpty) {
        final imgElement = elements[0];
        final src = imgElement.attributes['src'];
        data["profile"] = src;
      }
      // print(dat/* a) */;
      return data;
    }
    return {};
  }

  Future<List<Map<dynamic, dynamic>>> fetchTimeTable() async {
    if (await login()) {
      var response = await http.get(
        Uri.parse("$_baseUrl/Course/StudentTimetable"),
        headers: _header,
      );

      if (response.statusCode != 200) {
        throw Exception(
            "Error fetching student data, please check your internet connection");
      }

      // print(response.body);
      final document = parser.parse(response.body);
      final table = document.querySelector('table.table.table-hover');

      var tbody = table!.querySelector("tbody");
      var rows = tbody!.querySelectorAll("tr");

      final List<Map<String, String>> dataList = [];
      for (int i = 1; i < rows.length; i++) {
        final cells = rows[i].querySelectorAll("td");
        final unit = cells[0].text.trim();
        final section = cells[1].text.trim();
        final dayOfWeek = cells[2].text.trim();
        final period = cells[3].text.trim();
        final campus = cells[4].text.trim();
        final lectureRoom = cells[5].text.trim();
        final lecturer = cells[6].text.trim();

        dataList.add({
          'Unit': unit,
          'Section': section,
          'Day of Week': dayOfWeek,
          'Period': period,
          'Campus': campus,
          'Lecture Room': lectureRoom,
          'Lecturer': lecturer,
        });
      }
      return dataList;
    }
    return [{}];
  }

  Future<List<Map<dynamic, dynamic>>> fetchAllCourses() async {
    if (await login()) {
      var response = await http.get(
        Uri.parse("$_baseUrl/Course/StudentTimetable"),
        headers: _header,
      );

      if (response.statusCode != 200) {
        throw Exception(
            "Error fetching student data, please check your internet connection");
      }

      // print(response.body);
      final document = parser.parse(response.body);
      final table = document.querySelector('table.table.table-hover');

      var tbody = table!.querySelectorAll("tbody");
      var rows = tbody[1].querySelectorAll("tr");

      final List<Map<String, String>> dataList = [];
      for (int i = 1; i < rows.length; i++) {
        final cells = rows[i].querySelectorAll("td");
        final unit = cells[0].text.trim();
        final section = cells[1].text.trim();
        final dayOfWeek = cells[2].text.trim();
        final period = cells[3].text.trim();
        final campus = cells[4].text.trim();
        final lectureRoom = cells[5].text.trim();
        final lecturer = cells[6].text.trim();

        dataList.add({
          'Unit': unit,
          'Section': section,
          'Day of Week': dayOfWeek,
          'Period': period,
          'Campus': campus,
          'Lecture Room': lectureRoom,
          'Lecturer': lecturer,
        });
      }
      return dataList;
    }
    return [{}];
  }

  Future<Map<String, dynamic>> fetchCateringToken() async {
    if (await login()) {
      var response = await http.post(
        Uri.parse("$_baseUrl/Dashboard/GenerateNewCateringToken"),
        headers: _header,
      );

      if (response.statusCode != 200) {
        throw Exception(
            "Error fetching catering token, please check your internet connection");
      } else {
        return json.decode(response.body);
      }
    }
    return {};
  }

  // Fetches the user's class attendance
  Future<List<Map<String, int>>> fetchUserClassAttendance() async {
    if (await login()) {
      var response = await http.post(
        Uri.parse("$_baseUrl/Dashboard/GetUnitsClassAttendance"),
        headers: _header,
      );

      if (response.statusCode == 200) {
        // Parse the response
        var document = parser.parse(response.body);

        var tableRows = document.querySelectorAll("table tr td div.col-12");

        var unitsList = <Map<String, int>>[];

        for (var row in tableRows) {
          unitsList.add({
            row.children[0].innerHtml: int.parse(
                row.children[1].children[0].attributes["aria-valuenow"] ?? "0")
          });
        }
        return unitsList;
      } else {
        throw Exception(
            "Error fetching catering token, please check your internet connection");
      }
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> fetchFeeStatement() async {
    if (await login()) {
      var response = await http.get(
        Uri.parse("$_baseUrl/Financial/FeeStatement"),
        headers: _header,
      );

      if (response.statusCode != 200) {
        throw Exception(
          "Error fetching fee statement, please check your connection and try again",
        );
      }

      var html = response.body;
      final statements = <Map<String, dynamic>>[];

      final document = parser.parse(html);
      final tableRows =
          document.querySelectorAll("table.table.table-striped tbody tr");

      for (var row in tableRows) {
        var content = {
          "posting_date": row.children[0].innerHtml,
          "ref": row.children[1].innerHtml,
          "description": row.children[2].innerHtml,
          "debit": row.children[3].innerHtml,
          "credit": row.children[4].innerHtml,
          "running_balance": row.children[5].innerHtml,
        };
        statements.add(content);
      }
      return statements;
    } else {
      throw Exception(
          "Error fetching fee statement, please check your connection and try again");
    }
  }

  // Fetch Academic Calendar
  Future<List<Map<String, dynamic>>> fetchAcademicCalendar() async {
    if (await login()) {
      var response = await http.get(
        Uri.parse("$_baseUrl/Dashboard/Dashboard"),
        headers: _header,
      );

      if (response.statusCode != 200) {
        throw Exception("Error fetching semester");
      }

      var dashboard = response.body;
      var document = parser.parse(dashboard);

      final content =
          document.querySelector("button.btn.btn-sm.btn-success.form-control");

      var sem = content?.attributes["onclick"]
          ?.replaceRange(0, 16, "")
          .replaceAll("(", "")
          .replaceAll(")", "")
          .replaceAll(";", "")
          .replaceAll("'", "");

      // Attempt to fetch the String
      response = await http.post(
          Uri.parse("$_baseUrl/Common/GetAcademicCalender/"),
          body: json.encode({"Sem": sem}),
          headers: _header);

      if (response.statusCode != 200) {
        throw Exception("Error fetching Academic Calendar");
      }

      var html = parser.parse(response.body);
      var table = html.querySelectorAll("tbody tr");

      var events = <Map<String, dynamic>>[];

      for (var row in table) {
        events.add({
          "name": row.children[0].innerHtml,
          "start": row.children[1].innerHtml,
          "stop": row.children[2].innerHtml,
        });
      }

      return events;
    } else {
      throw Exception(
          "Error Acecessing Session token, please ensure you have internet connection and try again");
    }
  }

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

  Future<Uint8List> fetchTranscript(String admno) async {
    try {
      var response = await http.get(Uri.parse(
          "${_baseUrl.replaceFirst("https", "http")}/Downloads/PROVISIONAL%20RESULTS-$admno.pdf"));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      throw Exception(
          "Could not fetch transcript check details and try again otherwise try later");
    } catch (e) {
      rethrow;
    }
  }

  Future<Uint8List> fetchStudentAudit(String admno) async {
    try {
      var response = await http.get(Uri.parse(
          "${_baseUrl.replaceFirst("https", "http")}/Downloads/STDAUDIT-$admno.pdf"));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      throw Exception(
          "Could not fetch audit check details and try again otherwise try later");
    } catch (e) {
      rethrow;
    }
  }
}
